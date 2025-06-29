/* =================== JSON_CONTAINS =================== */

-- https://learn.microsoft.com/en-us/sql/t-sql/functions/json-contains-transact-sql?view=sql-server-ver17

-- Search for an integer value in a JSON path
DECLARE @JsonData json = '{
  "customerId": 1001,
  "customerId": 2002,
  "basket": {
    "totalItems": 4,
    "labels": ["fragile"]
  },
  "items": [1, 3, {"quantities": [89]}, false],
  "discount": null,
  "preferred": true
}'
SELECT Found =
    JSON_CONTAINS(
        @JsonData,      -- Scan this JSON content
        1001,           -- Search for this value
        '$.customerId'     -- In a root-level property named "customerId"
    )
GO

-- Search for a string value in a JSON path
DECLARE @JsonData json = '{
  "customerId": 1001,
  "customerId": 2002,
  "basket": {
    "totalItems": 4,
    "labels": ["fragile"]
  },
  "items": [1, 3, {"quantities": [89]}, false],
  "discount": null,
  "preferred": true
}'
SELECT Found =
    JSON_CONTAINS(
        @JsonData,              -- Scan this JSON content
        'fragile',              -- Search for this value
        '$.basket.labels[*]'    -- In all elements in the "labels" array inside the "basket" object
    )
GO

-- Search for a bit (boolean) value in a JSON array
DECLARE @JsonData json = '{
  "customerId": 1001,
  "customerId": 2002,
  "basket": {
    "totalItems": 4,
    "labels": ["fragile"]
  },
  "items": [1, 3, {"quantities": [89]}, true],
  "discount": null,
  "preferred": true
}'
SELECT Found =
    JSON_CONTAINS(
        @JsonData,          -- Scan this JSON content
        CAST(1 AS bit),     -- Search for this value (true)
        '$.items[*]'        -- In all elements in the "items" array
    )
GO

-- Search for an integer value contained within a nested JSON array
DECLARE @JsonData json = '{
  "customerId": 1001,
  "customerId": 2002,
  "basket": {
    "totalItems": 4,
    "labels": ["fragile"]
  },
  "items": [1, 3, {"quantities": [89]}, false],
  "discount": null,
  "preferred": true
}'
SELECT Found =
    JSON_CONTAINS(
        @JsonData,                  -- Scan this JSON content
        89,                         -- Search for this value
        '$.items[*].quantities[*]'  -- In all values inside "quantities" arrays found in any object within the "items" array
    )
GO

-- Search for an integer value contained within a JSON object in a JSON array
DECLARE @JsonData json = '[
  {"customerId": 1001, "customerId": 2002, "priority": 1},
  {"customerId": 329, "customerId": 1343, "priority": 1},
  {"customerId": 1056, "customerId": 80, "priority": 3},
  {"customerId": 871, "customerId": 232, "priority": 2}
]';
SELECT Found =
    JSON_CONTAINS(
        @JsonData,      -- Scan this JSON content
        1056,           -- Search for this value
        '$[*].customerId'  -- In the "customerId" field in every object in the root-level array
    )
GO
