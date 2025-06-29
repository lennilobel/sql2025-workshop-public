/* AI: Recipes: Vectorize Database - Create Recipes Database */

USE master
GO

CREATE DATABASE RecipesDB
GO

USE RecipesDB
GO

-- Allow SQL Server to call external REST endpoints
sp_configure 'external rest endpoint enabled', 1
RECONFIGURE
GO

-- Create the Recipe and related tables
CREATE TABLE Recipe(
	RecipeId int NOT NULL,
	RecipeName varchar(50) NOT NULL,
	PrepTimeMinutes int,
	CookTimeMinutes int,
	Servings int,
	Difficulty varchar(50),
	Cuisine varchar(50),
	CaloriesPerService int,
	Rating decimal(18, 9),
	ReviewCount int,
	CONSTRAINT PK_Recipe PRIMARY KEY CLUSTERED (RecipeId),
)

CREATE TABLE Ingredient(
	IngredientId int NOT NULL IDENTITY,
	RecipeId int NOT NULL,
	IngredientIndex int NOT NULL,
	IngredientName varchar(50) NOT NULL,
	CONSTRAINT PK_Ingredient PRIMARY KEY CLUSTERED  (IngredientId),
	CONSTRAINT FK_Recipe_Ingredient FOREIGN KEY(RecipeId) REFERENCES Recipe (RecipeId),
)

CREATE TABLE Instruction(
	InstructionId int NOT NULL IDENTITY,
	RecipeId int NOT NULL,
	InstructionIndex int NOT NULL,
	InstructionText varchar(200) NOT NULL,
	CONSTRAINT PK_Instruction PRIMARY KEY CLUSTERED (InstructionId),
	CONSTRAINT FK_Recipe_Instruction FOREIGN KEY(RecipeId) REFERENCES Recipe (RecipeId),
)

CREATE TABLE MealType(
	MealTypeId int NOT NULL IDENTITY,
	RecipeId int NOT NULL,
	MealTypeName varchar(50) NOT NULL,
	CONSTRAINT PK_MealType PRIMARY KEY CLUSTERED (MealTypeId),
	CONSTRAINT FK_Recipe_MealType FOREIGN KEY(RecipeId) REFERENCES Recipe (RecipeId),
)

CREATE TABLE Tag(
	TagId int IDENTITY(1,1) NOT NULL,
	RecipeId int NOT NULL,
	TagName varchar(50) NOT NULL,
	CONSTRAINT PK_Tag PRIMARY KEY CLUSTERED (TagId),
	CONSTRAINT FK_Recipe_Tag FOREIGN KEY(RecipeId) REFERENCES Recipe (RecipeId),
)
