/* =================== JSON_OBJECT and JSON_ARRAY =================== */

USE MyDB
GO

-- Constructing JSON with the JSON_OBJECT and JSON_ARRAY functions

DROP TABLE IF EXISTS Customer

CREATE TABLE Customer (
	CustomerId int IDENTITY PRIMARY KEY,
	FirstName varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	Ranking varchar(10) NULL,
	IsTopTier bit NULL,
	Phone1 varchar(20) NULL,
	Phone2 varchar(20) NULL,
	Phone3 varchar(20) NULL
)

INSERT INTO Customer
 (FirstName,	LastName,		Ranking,	IsTopTier,	Phone1,			Phone2,			Phone3) VALUES
 ('Ken',		'Sanchez',		'Platinum',	1,			'123-456-7890',	NULL,			NULL),
 ('Terri',		'Duffy',		'',			0,			'123-456-7890',	'234-567-8901',	'345-678-9012'),
 ('Roberto',	'Tamburello',	NULL,		1,			NULL,			'234-567-8901',	NULL),
 ('Rob',		'Walters',		'Silver',	NULL,		'123-456-7890',	'234-567-8901',	NULL),
 ('Gail',		'Erickson',		'Gold',		1,			'123-456-7890',	'234-567-8901',	'345-678-9012')

-- Use JSON_OBJECT to construct a valid JSON object
SELECT
    CustomerId,
	JSON_OBJECT(
		'firstName': FirstName,
		'lastName': LastName,
		'ranking': Ranking,
		'isTopTier': IsTopTier
	) AS JsonObject
FROM
	Customer
ORDER BY
	CustomerId

-- Before 2022, we had to use string concatenation...
SELECT
    CustomerId,
	CONCAT('
        {
            "firstName": "', FirstName, '",
            "lastName": "', LastName, '",
            "ranking": "', Ranking, '",
            "isTopTier": ', IsTopTier, '
        }
	') AS JsonObject
FROM
	Customer
ORDER BY
	CustomerId

-- But is it valid and accurate?
SELECT
    CustomerId,
	ISJSON(CONCAT('
		{
			"firstName": "', FirstName, '",
			"lastName": "', LastName, '",
			"ranking": "', Ranking, '",
			"isTopTier": ', IsTopTier, '
		}
	')) AS IsValidJsonObject
FROM
	Customer
ORDER BY
	CustomerId

-- Extra measures are required with string concatenation to achieve 100% validity and accuracy (nulls, booleans, escaped values, date/time formats, etc)
SELECT
    CustomerId,
	CONCAT('
        {
            "firstName": "', FirstName, '",
            "lastName": "', LastName, '",
            "ranking": ', IIF(Ranking IS NULL, 'null', CONCAT('"', Ranking, '"')), ',
            "isTopTier": ', CASE WHEN IsTopTier IS NULL THEN 'null' WHEN IsTopTier = 0 THEN 'false' ELSE 'true' END, '
        }
	') AS JsonObject
FROM
	Customer
ORDER BY
	CustomerId

-- Now it's valid and accurate (but still carries unneeded whitespace)
SELECT
    CustomerId,
	ISJSON(CONCAT('
		{
			"firstName": "', FirstName, '",
			"lastName": "', LastName, '",
			"ranking": ', IIF(Ranking IS NULL, 'null', CONCAT('"', Ranking, '"')), ',
			"isTopTier": ', CASE WHEN IsTopTier IS NULL THEN 'null' WHEN IsTopTier = 0 THEN 'false' ELSE 'true' END, '
		}
	')) AS IsValidJsonObject
FROM
	Customer
ORDER BY
	CustomerId

-- Use JSON_ARRAY to construct a valid JSON array
SELECT
    CustomerId,
	FirstName,
	LastName,
	JSON_ARRAY(
		Ranking,
		IsTopTier
			NULL ON NULL		-- default is ABSENT ON NULL
	) AS Tier
FROM
	Customer
ORDER BY
	CustomerId

-- Can nest JSON_ARRAY or JSON_OBJECT functions
SELECT
    CustomerId,
	JSON_OBJECT(
		'firstName': FirstName,
		'lastName': LastName,
		'tier': JSON_ARRAY(
			Ranking,
			IsTopTier
				NULL ON NULL		-- default is ABSENT ON NULL
		)
	) AS JsonObject
FROM
	Customer
ORDER BY
	CustomerId

-- Create variable-length phone numbers array
SELECT
    CustomerId,
	JSON_OBJECT(
		'firstName': FirstName,
		'lastName': LastName,
		'tier': JSON_ARRAY(
			Ranking,
			IsTopTier
				NULL ON NULL		-- default is ABSENT ON NULL
		)
	) AS JsonObject,
	JSON_ARRAY (
		Phone1,
		Phone2,
		Phone3
	) AS JsonArray
FROM
	Customer
ORDER BY
	CustomerId


-- Cleanup
DROP TABLE IF EXISTS Customer
