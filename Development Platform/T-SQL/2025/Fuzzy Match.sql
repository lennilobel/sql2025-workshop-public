/* =================== Fuzzy Match =================== */

-- https://learn.microsoft.com/en-us/sql/relational-databases/fuzzy-string-match/overview?view=azuresqldb-current&viewFallbackFrom=sql-server-ver17

CREATE DATABASE MyDB
GO

USE MyDB
GO

--------------------------------------------------------------------------------------------------
-- Basic Fuzzy String Match Example

DROP TABLE IF EXISTS WordPairs

CREATE TABLE WordPairs (
	WordId int IDENTITY PRIMARY KEY,
	Word1 varchar(50),
	Word2 varchar(50)
)
GO

INSERT INTO WordPairs VALUES
 ('Colour',		'Color'),
 ('Flavour',	'Flavor'),
 ('Centre',		'Center'),
 ('Theatre',	'Theater'),
 ('Theatre',	'Theatrics'),
 ('Theatre',	'Theatrical'),
 ('Organise',	'Organize'),
 ('Analyse',	'Analyze'),
 ('Catalogue',	'Catalog'),
 ('Programme',	'Program'),
 ('Metre',		'Meter'),
 ('Honour',		'Honor'),
 ('Neighbour',	'Neighbor'),
 ('Travelling',	'Traveling'),
 ('Grey',		'Gray'),
 ('Green',		'Greene'),
 ('Green',		'Greener'),
 ('Green',		'Greenery'),
 ('Green',		'Greenest'),
 ('Defence',	'Defense'),
 ('Practise',	'Practice'),
 ('Practice',	'Practice'),    -- exact
 ('Aluminium',	'Aluminum'),
 ('Cheque',		'Check'),
 ('Orange',		'Purple')

SELECT
	*,
    -- New 2025 functions
	LevenshteinDistance     = EDIT_DISTANCE(Word1, Word2),
	LevenshteinSimilarity   = EDIT_DISTANCE_SIMILARITY(Word1, Word2),
	JaroWrinklerDistance    = JARO_WINKLER_DISTANCE(Word1, Word2),
	JaroWrinklerSimilarity  = JARO_WINKLER_SIMILARITY(Word1, Word2),
    -- Old 2000 functions
	Soundex1                = SOUNDEX(Word1),
	Soundex2                = SOUNDEX(Word2),
	Difference              = DIFFERENCE(Word1, Word2)
FROM
	WordPairs
ORDER BY 
    LevenshteinSimilarity DESC

GO

--------------------------------------------------------------------------------------------------
-- Customer name and address fuzzy matching example

DROP TABLE IF EXISTS Customer

CREATE TABLE Customer (
    CustomerId int IDENTITY PRIMARY KEY,
    FirstName varchar(50),
    LastName varchar(50),
    Address varchar(100)
)
GO

-- Insert mix of dissimilar, similar, and exact names and addresses
INSERT INTO Customer VALUES
 ('Johnathan',  'Smith',    '123 North Main Street'),
 ('Jonathan',   'Smith',    '123 N Main St.'),
 ('Johnathan',  'Smith',    '456 Ocean View Blvd'),
 ('Johnathan',  'Smith',    '123 North Main Street'),
 ('Daniel',     'Smith',    '123 N. Main St.'),
 ('Danny',      'Smith',    '123 N. Main St.'),
 ('John',       'Smith',    '123 Main Street'),
 ('Jonathon',   'Smyth',    '123 N Main St'),
 ('Jon',        'Smith',    '123 N Main St.'),
 ('Johnny',     'Smith',    '124 N Main St'),
 ('Ethan',      'Goldberg', '742 Evergreen Terrace'),
 ('Carlos',     'Rivera',   '456 Ocean View Boulevard'),
 ('Carlos',     'Rivera',   '456 Ocean View Blvd'),
 ('Carl',       'Rivera',   '456 Ocean View Boulevard'),
 ('Carlos',     'Rivera',   '456 Ocean View Boulevard')

-- Analyze first names for similarity
;WITH PairwiseSimilarity AS (
    SELECT
        CustomerId1         = c1.CustomerId,
        CustomerId2         = c2.CustomerId,
        FirstName1          = c1.FirstName,
        FirstName2          = c2.FirstName,
        FirstNameSimilarity = JARO_WINKLER_SIMILARITY(c1.FirstName, c2.FirstName)
    FROM
        Customer AS c1
        INNER JOIN Customer AS c2 ON c2.CustomerId < c1.CustomerId
)
SELECT
    CustomerId1,
    CustomerId2,
    FirstName1,
    FirstName2,
    FirstNameSimilarity,
    FirstNameQuality = CASE
        WHEN FirstNameSimilarity = 1    THEN 'Exact'
        WHEN FirstNameSimilarity >= .85 THEN 'Very Strong'
        WHEN FirstNameSimilarity >= .75 THEN 'Strong'
        WHEN FirstNameSimilarity >= .4  THEN 'Weak'
                                        ELSE 'Very Weak'
    END
FROM
    PairwiseSimilarity
ORDER BY
    FirstNameSimilarity DESC,
    FirstName1,
    FirstName2

-- Analyze last names for similarity
;WITH PairwiseSimilarity AS (
    SELECT
        CustomerId1         = c1.CustomerId,
        CustomerId2         = c2.CustomerId,
        LastName1           = c1.LastName,
        LastName2           = c2.LastName,
        LastNameSimilarity  = JARO_WINKLER_SIMILARITY(c1.LastName,  c2.LastName)
    FROM
        Customer AS c1
        INNER JOIN Customer AS c2 ON c2.CustomerId < c1.CustomerId
)
SELECT
    CustomerId1,
    CustomerId2,
    LastName1,
    LastName2,
    LastNameSimilarity,
    LastNameQuality = CASE
        WHEN LastNameSimilarity = 1     THEN 'Exact'
        WHEN LastNameSimilarity >= .85  THEN 'Very Strong'
        WHEN LastNameSimilarity >= .75  THEN 'Strong'
        WHEN LastNameSimilarity >= .4   THEN 'Weak'
                                        ELSE 'Very Weak'
    END
FROM
    PairwiseSimilarity
ORDER BY
    LastNameSimilarity DESC,
    LastName1,
    LastName2

-- Analyze addresses for similarity
;WITH PairwiseSimilarity AS (
    SELECT
        CustomerId1         = c1.CustomerId,
        CustomerId2         = c2.CustomerId,
        Address1            = c1.Address,
        Address2            = c2.Address,
        AddressSimilarity   = JARO_WINKLER_SIMILARITY(c1.Address,   c2.Address)
    FROM
        Customer AS c1
        INNER JOIN Customer AS c2 ON c2.CustomerId < c1.CustomerId
)
SELECT
    CustomerId1,
    CustomerId2,
    Address1,
    Address2,
    AddressSimilarity,
    AddressQuality = CASE
        WHEN AddressSimilarity = 1      THEN 'Exact'
        WHEN AddressSimilarity >= .85   THEN 'Very Strong'
        WHEN AddressSimilarity >= .75   THEN 'Strong'
        WHEN AddressSimilarity >= .4    THEN 'Weak'
                                        ELSE 'Very Weak'
    END
FROM
    PairwiseSimilarity
ORDER BY
    AddressSimilarity DESC,
    Address1,
    Address2

-- Combine all three analyses into a single result set based on a combined score of first name, last name, and address similarities
;WITH PairwiseSimilarity AS (
    SELECT
        CustomerId1         = c1.CustomerId,
        CustomerId2         = c2.CustomerId,
        FirstName1          = c1.FirstName,
        FirstName2          = c2.FirstName,
        FirstNameSimilarity = JARO_WINKLER_SIMILARITY(c1.FirstName, c2.FirstName),
        LastName1           = c1.LastName,
        LastName2           = c2.LastName,
        LastNameSimilarity  = JARO_WINKLER_SIMILARITY(c1.LastName,  c2.LastName),
        Address1            = c1.Address,
        Address2            = c2.Address,
        AddressSimilarity   = JARO_WINKLER_SIMILARITY(c1.Address,   c2.Address)
    FROM
        Customer AS c1
        INNER JOIN Customer AS c2 ON c2.CustomerId < c1.CustomerId
)
SELECT
    CustomerId1,
    CustomerId2,
    FirstName1,
    FirstName2,
    FirstNameSimilarity,
    LastName1,
    LastName2,
    LastNameSimilarity,
    Address1,
    Address2,
    AddressSimilarity,
    FinalCombinedScore = (FirstNameSimilarity + LastNameSimilarity + AddressSimilarity) / 3.0,
    FinalQuality = CASE
        WHEN (FirstNameSimilarity + LastNameSimilarity + AddressSimilarity) / 3.0 = 1 THEN 'Exact'
        WHEN (FirstNameSimilarity + LastNameSimilarity + AddressSimilarity) / 3.0 >= .85 THEN 'Very Strong'
        WHEN (FirstNameSimilarity + LastNameSimilarity + AddressSimilarity) / 3.0 >= .75 THEN 'Strong'
        WHEN (FirstNameSimilarity + LastNameSimilarity + AddressSimilarity) / 3.0 >= .4 THEN 'Weak'
        ELSE 'Very Weak'
    END
FROM
    PairwiseSimilarity
ORDER BY
    FinalCombinedScore DESC
