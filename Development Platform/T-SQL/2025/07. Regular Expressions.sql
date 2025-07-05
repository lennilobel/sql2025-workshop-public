/* =================== Regular Expressions =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/functions/regular-expressions-functions-transact-sql?view=sql-server-ver17

USE MyDB
GO

CREATE TABLE Review(
  ReviewId    int IDENTITY PRIMARY KEY,
  Name        varchar(50) NOT NULL,
  Email       varchar(150),
  Phone       varchar(20),
  ReviewText  varchar(1000)
)
GO

INSERT INTO Review
 (Name,                     Email,                      Phone,          ReviewText) VALUES
 ('John Doe',               'john@contoso.com',         '123-4567890',  'This product is excellent! I really like the build quality and design. #excellent #quality'),
 ('Alice Smith',            'alice@fabrikam@com',       '234-567-81',   'Good value for money, but the software is terrible.'),
 ('Mary Jo Anne Erickson',  'mary.jo.anne@acme.co.uk',  '456-789-1234', 'Poor battery life,   bad camera performance,   and poor build quality. #poor'),
 ('Max Wong',               'max@fabrikam.com',         NULL,           'Excellent service from the support team, highly recommended!' || char(9) || '#goodservice #recommended'),
 ('Bob Johnson',            'bob.fabrikam.net',         '345-678-9012', 'The product is good, but delivery was delayed.' || char(13) || char(10) || 'Overall, decent experience.'),
 ('Terri S Duffy',          'terri.duffy@acme.com',     '678-901-2345', 'Battery life is weak, camera quality is poor. #aweful'),
 ('Eve Jones',              NULL,                       '456-789-0123', 'I love this product, it''s great! #fantastic #amazing'),
 ('Charlie Brown',          'charlie@contoso.co.in',    '587-890-1234', 'I hate this product, it''s terrible!')

-- Get all rows
SELECT * FROM Review


----------------------------------------------------------------------------------------
-- *** REGEXP_LIKE ***

-- Get rows with valid email addresses
SELECT
  ReviewId,
  Name,
  Email
FROM
  Review
WHERE
  REGEXP_LIKE(
    Email,
    '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
/*
    ^                    Start of string
    [a-zA-Z0-9._%+-]+    One or more letters, digits, dot, underscore, percent, plus, or hyphen
    @                    Literal @ before the domain
    [a-zA-Z0-9.-]+       One or more letters, digits, dot, or hyphen for the domain name
    \.                   Literal . before the top-level domain
    [a-zA-Z]{2,}         At least two letters for the top-level domain (e.g., com, org, co, uk)
    $                    End of string
*/
  )

-- Get rows with valid email addresses that end with .com
SELECT
  ReviewId,
  Name,
  Email
FROM
  Review
WHERE
  REGEXP_LIKE(
    Email,
    '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.com$'
/*
    ^                    Start of string
    [a-zA-Z0-9._%+-]+    One or more letters, digits, dot, underscore, percent, plus, or hyphen
    @                    Literal @ before the domain
    [a-zA-Z0-9.-]+       One or more letters, digits, dot, or hyphen for the domain name
    \.com                Literal . before the top-level domain which must be "com"
    $                    End of string
*/
  )

-- Get rows with valid phone numbers
SELECT
  ReviewId,
  Name,
  Phone
FROM
  Review
WHERE
  REGEXP_LIKE(
    Phone,
    '^(\d{3})-(\d{3})-(\d{4})$'
/*
    ^           Start of string
    (\d{3})     Match exactly 3 digits (area code)
    -           Literal hyphen
    (\d{3})     Match exactly 3 digits (first part of the phone number)
    -           Literal hyphen
    (\d{4})     Match exactly 4 digits (second part of the phone number)
    $           End of string
*/
    )


----------------------------------------------------------------------------------------
-- *** REGEXP_COUNT ***

-- Indicate valid/invalid email addresses and phone numbers (must use REGEXP_COUNT, because REGEXP_LIKE can only be used in the WHERE clause)
SELECT
  ReviewId,
  Name,
  Email,
  IsEmailValid  = CASE WHEN REGEXP_COUNT(Email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') = 1 THEN 1 ELSE 0 END,
  Phone,
  IsPhoneValid  = CASE WHEN REGEXP_COUNT(Phone, '^(\d{3})-(\d{3})-(\d{4})$') = 1 THEN 1 ELSE 0 END
FROM
  Review

-- Count the number of vowels in each name
SELECT
  Name,
  VowelCount = REGEXP_COUNT(
    Name,
    '[AEIOU]',  -- match any single vowel
    1,      -- start position
    'i'     -- case insensitive flag (match uppercase or lowercase vowels)
  )  
FROM
  Review

-- Count specific "sentiment" words from the review
SELECT
  Name,
  ReviewText,
  GoodSentimentWordCount = REGEXP_COUNT(
    ReviewText,
    '\b(excellent|great|good|love|like)\b',
/*
    \b                                  start of word boundary
    (excellent|great|good|love|like)    match any of the words in the parentheses
    \b                                  end of word boundary            
*/
    1,    -- start position
    'i'   -- case insensitive flag (match uppercase or lowercase words)
  ),
  BadSentimentWordCount = REGEXP_COUNT(
    ReviewText,
    '\b(bad|poor|terrible|hate)\b',
/*
    \b                          start of word boundary
    (bad|poor|terrible|hate)    match any of the words in the parentheses
    \b                          end of word boundary            
*/
    1,    -- start position
    'i'   -- case insensitive flag (match uppercase or lowercase words)
  )
FROM
  Review


----------------------------------------------------------------------------------------
-- *** CHECK constraints ***

IF 1 = 0 BEGIN
  -- Cannot add check constraints to ensure valid email addresses and phone numbers
  ALTER TABLE Review 
   ADD CONSTRAINT CK_ValidEmail CHECK (Email IS NULL OR REGEXP_LIKE(Email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'))

  ALTER TABLE Review 
   ADD CONSTRAINT CK_ValidPhone CHECK (Phone IS NULL OR REGEXP_LIKE(Phone, '^(\d{3})-(\d{3})-(\d{4})$'))
END

-- Delete rows with invalid email addresses and phone numbers
DELETE FROM Review
WHERE
  (Email IS NOT NULL AND NOT REGEXP_LIKE(Email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')) OR
  (Phone IS NOT NULL AND NOT REGEXP_LIKE(Phone, '^(\d{3})-(\d{3})-(\d{4})$'))

SELECT * FROM Review

-- Add check constraints to ensure valid email addresses and phone numbers
ALTER TABLE Review 
 ADD CONSTRAINT CK_ValidEmail CHECK (Email IS NULL OR REGEXP_LIKE(Email, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'))

ALTER TABLE Review 
 ADD CONSTRAINT CK_ValidPhone CHECK (Phone IS NULL OR REGEXP_LIKE(Phone, '^(\d{3})-(\d{3})-(\d{4})$'))

IF 1 = 0 BEGIN
  -- Try and fail to insert an invalid email address or phone number
  INSERT INTO Review VALUES
   ('Invalid Email', 'invalid-email@com', '123-456-7890', 'Review')

  INSERT INTO Review VALUES
   ('Invalid Phone', 'valid-email@gmail.com', '234-342-INVALID', 'Review')
END

-- But valid values will succeed
INSERT INTO Review
 (Name,             Email,                          Phone,          ReviewText) VALUES
 ('John Doe',       'john@fabrikam.com',            '123-456-7890', 'This product is excellent! I really like the build quality and design. #excellent #quality'),
 ('Alice Smith',    'alice.smith@fabrikam.co.uk',   '234-567-8195', 'Good value for money, but the software is terrible.'),
 ('Bob Johnson',    'bob@fabrikam.com',             '345-678-9012', 'The product is good, but delivery was delayed. Overall, decent experience.'),
 ('Stuart Green',   'stuart.green@acme.com',        '456-789-0123', 'Pretty good product, I am enjoying it!')

SELECT * FROM Review


----------------------------------------------------------------------------------------
-- *** REGEXP_SUBSTR ***

-- Extract the domain name of each valid email address
SELECT
  ReviewId,
  Name,
  Email,
  DomainName = REGEXP_SUBSTR(
    Email,
    '@(.+)$',   -- @ = literal at-symbol; (.+)$ = capture everything after the at-symbol
    1,          -- start position
    1,          -- return the first occurrence
    'c',        -- enable capture group indexing
    1)          -- return the first capture group, which is the domain name
FROM
  Review

-- Show how many email addresses there are for each domain
;WITH DomainNameCte AS (
  SELECT 
    DomainName = REGEXP_SUBSTR(
      Email,
      '@(.+)$',   -- @ = literal at-symbol; (.+)$ = capture everything after the at-symbol
      1,          -- start position
      1,          -- return the first occurrence
      'c',        -- enable capture group indexing
      1)          -- return the first capture group, which is the domain name
  FROM
    Review
)
SELECT
  DomainName,
  DomainCount = COUNT(*)
FROM
  DomainNameCte
GROUP BY
  DomainName
ORDER BY
  DomainName


----------------------------------------------------------------------------------------
-- *** REGEXP_INSTR ***

-- Find the position of the @ character and the first . character after the @ character in the email address
SELECT
  ReviewId,
  Name,
  Email,
  At          = REGEXP_INSTR(Email, '@'),   -- match the at-symbol; simple scenario (could also achieve with CHARINDEX)
  DotAfterAt  = REGEXP_INSTR(Email,
    '@[^@]*?(\.)',  -- @ = match the at-symbol; [^@]*? = match everything after the at-symbol until the first dot; (\.) = capture the first dot after the at-symbol
    1,              -- start position
    1,              -- return the first occurrence
    0,              -- return the position of the match (not the psition after it)
    'c',            -- enable capture group indexing
    1               -- return the position of the first capture group, which is the dot
  )
FROM
  Review

/*
                      1         2
             12345678901234567890123456
    Example: alice.smith@fabrikam.co.uk
                        ^        ^
                        |        |
                        |        +-- match first dot after @ = 21
                        +-- match starts at @
*/

----------------------------------------------------------------------------------------
-- *** REGEXP_REPLACE ***

-- Strip middle names
SELECT
  ReviewId,
  Name,
  ShortName = REGEXP_REPLACE(
    Name,                   -- scan the Name column
    '^(\S+)\s+.*\s+(\S+)$', -- ^(\S+) = capture the first word; .* = match everything in the middle; (\S+)$ = capture the last word
    '\1 \2',                -- replace the whole name with first + last
    1,                      -- start position
    1,                      -- replace only the first occurrence
    'i'                     -- case insensitive flag (optional, but safe to include)
  )
FROM
  Review


----------------------------------------------------------------------------------------
-- *** REGEXP_MATCHES ***


-- Extract words starting with 'A' followed by any two characters
SELECT *
FROM REGEXP_MATCHES(
  'ATE ABOVE ACT',
  '\b(A)(..)\b'   -- \b = word boundary; (A) = the letter A; (..) = any two characters after A
)

-- Extract hashtags from text
SELECT *
FROM REGEXP_MATCHES(
  'Learning #AzureSQL #AzureSQLDB',
  '#([A-Za-z0-9_]+)'  -- # = hash symbol; ([A-Za-z0-9_]+) = followed by 1 or more characters or underscores
)

-- Extract hashtags from the review text in the database
SELECT
  r.ReviewId,
  r.ReviewText,
  m.*
FROM
  Review AS r
  CROSS APPLY REGEXP_MATCHES(r.ReviewText, '#([A-Za-z0-9_]+)') AS m


----------------------------------------------------------------------------------------
-- *** REGEXP_SPLIT_TO_TABLE ***

-- Extract individual words from text, using any white space as the delimiter
SELECT *
FROM
  REGEXP_SPLIT_TO_TABLE(
    'the quick brown    fox jumped' || char(9) || 'over the lazy' || char(13) || char(10) || 'dog',
    '\s+'   -- \s+ = match one or more whitespace characters (spaces, tabs, newlines)
  )    

-- Extract individual words from the review text in the database
SELECT
  r.ReviewId,
  r.ReviewText,
  WordText        = s.value,
  WordPosition    = s.ordinal
FROM
  Review AS r
  CROSS APPLY REGEXP_SPLIT_TO_TABLE(r.ReviewText, '\s+') AS s

SELECT
  r.ReviewId,
  r.ReviewText,
  WordText        = REGEXP_REPLACE(s.value, '[^\w]', '', 1, 0, 'i'),
  WordPosition    = s.ordinal
FROM
  Review AS r
  CROSS APPLY REGEXP_SPLIT_TO_TABLE(r.ReviewText, '\s+') AS s

-- Clean up
DROP TABLE IF EXISTS Review
