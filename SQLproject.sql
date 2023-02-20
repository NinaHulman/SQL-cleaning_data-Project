--Creating new database to host our data table

USE master;
GO

IF NOT EXISTS (
      SELECT name
      FROM sys.databases
      WHERE name = N'HousingData'
      )
   CREATE DATABASE [HousingData];

SELECT *
from [dbo].[Housing Data ]

--
Clean the sale date column 

SELECT SaleDate
from[dbo].[Housing Data ]

SELECT SaleDate CONVERT(date, SaleDate,23)
from [dbo].[Housing Data]


--Populate property address data 

Select PropertyAddress
from [dbo].[Housing Data ]

--We want to check if there are any null VALUES


Select PropertyAddress
From [dbo].[Housing Data ]
Where PropertyAddress is null
order by ParcelID

--by looking at data we realised that there are some PropertyAddress 
--data missing but the ParcelID is the same so it is the same property 
--we want to populate it with the right PropertyAddress joining the table on PropertyID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[Housing Data ] AS a
JOIN [dbo].[Housing Data ] AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[Housing Data ] AS a
JOIN [dbo].[Housing Data ] AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--The ISNULL function in SQL is used to replace NULL values with a specified replacement value. 
--The ISNULL function takes two parameters - the first parameter is the expression to be evaluated for NULL, 
--and the second parameter is the value to replace NULL with if the expression evaluates to NULL.
--The syntax for using ISNULL function is: ISNULL(expression, replacement_value)


-- Now we want to break PropertyAddress into Individual Columns (Address, City, State)

Select PropertyAddress
From [dbo].[Housing Data ]

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS address
FROM [dbo].[Housing Data] 

SELECT 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress + 1 ), LEN(PropertyAddress)) as City
From [dbo].[Housing Data ]

--when there might be missing commas this is the altered query

SELECT 
  CASE
    WHEN CHARINDEX(',', PropertyAddress) > 0 
    THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
    ELSE PropertyAddress
  END AS address
FROM [dbo].[Housing Data]

SELECT 
  CASE
    WHEN CHARINDEX(',', PropertyAddress) > 0 
    THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress + 1), LEN(PropertyAddress))
    ELSE ''
  END AS City
FROM [dbo].[Housing Data]

-- now lets update our table and create to extra columns

ALTER TABLE [dbo].[Housing Data ]
Add PropertySplitAddress Nvarchar(255);

Update [dbo].[Housing Data ]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [dbo].[Housing Data ]
Add PropertySplitCity Nvarchar(255);

Update [dbo].[Housing Data ]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--Let's change the owner address column now, we will do the same as in previouse exercise but with diffrent function

SELECT OwnerAddress
From [dbo].[Housing Data ]

--PARSENAME function can be used to extract any of the four parts of the object name. it uses '.' instead of ','
--that's why we changed ',' to '.' with replace function
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [dbo].[Housing Data ]



ALTER TABLE [dbo].[Housing Data ]
Add OwnerSplitAddress Nvarchar(255);

Update [dbo].[Housing Data ]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [dbo].[Housing Data ]
Add OwnerSplitCity Nvarchar(255);

Update [dbo].[Housing Data ]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [dbo].[Housing Data ]
Add OwnerSplitState Nvarchar(255);

Update [dbo].[Housing Data ]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM [dbo].[Housing Data ]

-- CHANGE Y AND N TO YES AND NO IN SoldAsVacant
SELECT DISTINCT (SOldAsVacant)
FROM [dbo].[Housing Data ]

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [dbo].[Housing Data ]
Group by SoldAsVacant
order by 2

-- I found out by looking at the column I have fault rows there and I want to get rid of them

DELETE FROM [dbo].[Housing Data ]
WHERE SoldAsVacant = '142  SCENIC VIEW RD, OLD HICKORY, TN'
OR SoldAsVacant ='144  SCENIC VIEW RD, OLD HICKORY, TN'
OR SoldASVacant='0  COUCHVILLE PIKE, HERMITAGE, TN'
OR SoldAsVacant IS NULL;

--now it looks fine and I can unify the data by changing Y to yes and N to no

 
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [dbo].[Housing Data ]


Update [dbo].[Housing Data ]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END[dbo].[Housing Data ]

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [dbo].[Housing Data ]
Group by SoldAsVacant
order by 2              -- checking if it worked

-- REMOVING DUPLICATES


SELECT *
from [dbo].[Housing Data ] 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [dbo].[Housing Data ]
--order by ParcelID
)
DELETE --to delete duplicates that we found by doing ROW_NUMBER funtion
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--DELETING UNUSED COLUMNS

ALTER TABLE [dbo].[Housing Data ]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress --we don't need this columns,because we already created new columns by spliting the information in these columns
