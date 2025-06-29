/* =================== JSON_PATH_EXISTS =================== */

-- Testing for properties with the JSON_PATH_EXISTS function

DECLARE @JsonData AS varchar(max) = '
	{
		"OrderId": 5,
		"CustomerId": 6,
		"OrderDate": "2015-10-10T14:22:27.25-05:00",
		"OrderAmount": 25.9
	}
'

SELECT
	JSON_PATH_EXISTS(@JsonData, '$.CustomerId')	AS '$.CustomerId',
	JSON_PATH_EXISTS(@JsonData, '$.Discount')	AS '$.Discount'

GO

DECLARE @JsonData AS varchar(max) = '
[
	{
		"OrderId": 5,
		"CustomerId": 6,
		"OrderDate": "2015-10-10T14:22:27.25-05:00",
		"OrderAmount": 25.9
	},
	{
		"OrderId": 29,
		"CustomerId": 76,
		"OrderDate": "2015-12-10T11:02:36.12-08:00",
		"OrderAmount": 350.25,
		"Discount": 0.1
	}
]'

SELECT
	JSON_PATH_EXISTS(@JsonData, '$[0].CustomerId')	AS '$[0].CustomerId',	-- 1 | First object has CustomerId property
	JSON_PATH_EXISTS(@JsonData, '$[0].Discount')	AS '$[0].Discount',		-- 0 | First object has no Discount property
	JSON_PATH_EXISTS(@JsonData, '$[1].CustomerId')	AS '$[1].CustomerId',	-- 1 | Second object has CustomerId property
	JSON_PATH_EXISTS(@JsonData, '$[1].Discount')	AS '$[1].Discount',		-- 1 | Second object has Discount property
	JSON_PATH_EXISTS(@JsonData, '$[2].CustomerId')	AS '$[2].CustomerId'	-- 0 | There is no third object

GO
