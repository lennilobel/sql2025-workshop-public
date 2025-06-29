/* =================== ISJSON Object vs. Array =================== */

-- Testing for valid JSON object versus array with the enhanced ISJSON function

DECLARE @JsonObject AS varchar(max) = '{ "Color": "Red" }'
DECLARE @JsonArray AS varchar(max) = '[{ "Color": "Red", "Color": "Blue"}]'

SELECT
	IsObjectAValue		= ISJSON(@JsonObject, VALUE),
	IsObjectAnObject	= ISJSON(@JsonObject, OBJECT),
	IsObjectAnArray		= ISJSON(@JsonObject, ARRAY),
	IsArrayAValue		= ISJSON(@JsonArray, VALUE),
	IsArrayAnObject		= ISJSON(@JsonArray, OBJECT),
	IsArrayAnArray		= ISJSON(@JsonArray, ARRAY)

GO
