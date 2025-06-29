/* =================== Base64 Encoding =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/functions/base64-encode-transact-sql?view=azuresqldb-current&viewFallbackFrom=sql-server-ver17
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/base64-decode-transact-sql?view=azuresqldb-current

USE MyDB
GO

-- Base64 encoding is a method of converting binary data into an ASCII string format by translating
-- it into a radix-64 representation. Base64 decoding is the reverse process, converting an ASCII
-- string back into binary data. Encoding is often used to safely transmit binary data over text-based
-- protocols, such as HTTP or email, though note that encoding binary data increases its size by
-- approximately 33%.

SELECT StandardEncoded	= BASE64_ENCODE(0xCAFECAFE)		-- Note the / in the encoded string; unsafe for URLs
SELECT StandardDecoded	= BASE64_DECODE('yv7K/g==')		-- Decodes back to 0xCAFECAFE

SELECT UrlSafeEncoded	= BASE64_ENCODE(0xCAFECAFE, 1)	-- Note the encoded string is safe for URLs
SELECT UrlSafeDecoded	= BASE64_DECODE('yv7K_g')		-- Both URL-safe and URL-unsafe encodings decode to the same binary data
SELECT InvalidBase64	= BASE64_DECODE('qQ!!')			-- Causes an error due to invalid Base64 characters


-- Constructing a JSON object with an embedded image (also suitable for HTML or XML)

DECLARE @ProductId int = 6
DECLARE @ProductImage varbinary(max) = 0xCAFECAFE89504E470D0A1A0A0000000D49484452

SELECT
    ProductJson = JSON_OBJECT(
        'productId' : @ProductId,
        'thumbnail' : 'data:image/png;base64,' || BASE64_ENCODE(@ProductImage)
    )

GO


-- Constructing a binary token for use in a URL

DECLARE @Token varbinary(max) = CAST('user1|expiry=2025-12-31' as varbinary)
SELECT @Token

DECLARE @UrlSafeEncodedToken varchar(max) = BASE64_ENCODE(@Token, 1)
SELECT @UrlSafeEncodedToken

DECLARE @Url varchar(max) = 'https://api.myapp.com/download?token=' || @UrlSafeEncodedToken
SELECT @Url

