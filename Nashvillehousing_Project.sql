-- Import dataset into SQL database
-- View dataset

SELECT *
FROM housing_project

-- Cleaning begins 
-- "" used because of uppercase letters in dataset column names
-- Clean up date format 

SELECT "SaleDate" AS Date, CAST ("SaleDate" AS date)  
FROM housing_project

UPDATE housing_project
SET "SaleDate" = CAST ("SaleDate" AS date)

-- Populate property address

SELECT "PropertyAddress"
FROM housing_project
WHERE "PropertyAddress" IS NULL
-- 29 null rows 

SELECT *
FROM housing_project
WHERE "PropertyAddress" IS NULL
-- Property address is highly likely not to change but other columns can. 

SELECT "ParcelID", "PropertyAddress"
FROM housing_project
--WHERE "PropertyAddress" IS NULL
ORDER BY "ParcelID"
-- Parcel Ids with the same code have the same property addresses

-- Self Join 

SELECT *
FROM housing_project AS a
JOIN housing_project AS b
ON a."ParcelID" = b."ParcelID"
AND a."UniqueID " <> b."UniqueID "


SELECT a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress"
FROM housing_project AS a
JOIN housing_project AS b
ON a."ParcelID" = b."ParcelID"
AND a."UniqueID " <> b."UniqueID "
WHERE a."PropertyAddress" IS NULL
-- This shows the null property addresses in one column and the populated ones in another property adress column. It gives the addresses we need to populate the null columns.


SELECT a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress", COALESCE (a."PropertyAddress", b."PropertyAddress")
FROM housing_project AS a
JOIN housing_project AS b
ON a."ParcelID" = b."ParcelID"
AND a."UniqueID " <> b."UniqueID "
WHERE a."PropertyAddress" IS NULL

-- Update table with populated data

UPDATE housing_project 
SET "PropertyAddress" =  COALESCE (a."PropertyAddress", b."PropertyAddress")
FROM housing_project AS a
JOIN housing_project AS b
ON a."ParcelID" = b."ParcelID"
AND a."UniqueID " <> b."UniqueID "
WHERE a."PropertyAddress" IS NULL

-- Run previous queries to clarify that there are no null values

-- Breaking out the adresses into individual columns (Address, City, State)
-- Property address first

SELECT "PropertyAddress"
FROM housing_project

SELECT 
SUBSTRING("PropertyAddress", 1, STRPOS("PropertyAddress", ',')-1) AS Address,
SUBSTRING("PropertyAddress", STRPOS("PropertyAddress", ',')+1, LENGTH("PropertyAddress")) AS Address
FROM housing_project

-- Update table with new columns

ALTER TABLE housing_project
Add "PropertysplitAddress" varchar (300)

ALTER TABLE housing_project
Add "Propertycity" varchar (300)

UPDATE housing_project
SET "PropertysplitAddress" =  
SUBSTRING("PropertyAddress", 1, STRPOS("PropertyAddress", ',')-1) 

UPDATE housing_project
SET "Propertycity" =  
SUBSTRING("PropertyAddress", STRPOS("PropertyAddress", ',')+1, LENGTH("PropertyAddress")) 

-- Owner address

SELECT "OwnerAddress"
FROM housing_project

SELECT Split_part("OwnerAddress",',',1),
Split_part("OwnerAddress",',',2),
Split_part("OwnerAddress",',',3)
FROM housing_project

ALTER TABLE housing_project
Add "OwnersplitAddress" varchar (300)

UPDATE housing_project
SET "OwnersplitAddress" =  
Split_part("OwnerAddress",',',1)

ALTER TABLE housing_project
Add "Ownercity" varchar (300)

UPDATE housing_project
SET "Ownercity" =  
Split_part("OwnerAddress",',',2)

ALTER TABLE housing_project
Add "Ownerstate" varchar (300)

UPDATE housing_project
SET "Ownerstate" =  
Split_part("OwnerAddress",',',3)

-- SoldAsVacant column. Change N to No and Y to Yes using case statement

SELECT DISTINCT "SoldAsVacant"
FROM housing_project

SELECT DISTINCT "SoldAsVacant", COUNT ("SoldAsVacant")
FROM housing_project
GROUP BY "SoldAsVacant"
ORDER BY 2

SELECT "SoldAsVacant",
CASE WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
    WHEN "SoldAsVacant" = 'N' THEN 'No'
    ELSE "SoldAsVacant"
    END
FROM housing_project

UPDATE housing_project
SET "SoldAsVacant" =
CASE WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
    WHEN "SoldAsVacant" = 'N' THEN 'No'
    ELSE "SoldAsVacant"
    END
	
-- Remove Duplicates

SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY "ParcelID",
    "PropertyAddress",
    "SalePrice",
    "SaleDate",
    "LegalReference"
    ORDER BY "UniqueID "
    ) row_num
FROM housing_project


WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY "ParcelID",
    "PropertyAddress",
    "SalePrice",
    "SaleDate",
    "LegalReference"
    ORDER BY "UniqueID "
    ) row_num
FROM housing_project
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY "ParcelID",
    "PropertyAddress",
    "SalePrice",
    "SaleDate",
    "LegalReference"
    ORDER BY "UniqueID "
    ) row_num
FROM housing_project
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete unused columns 

ALTER TABLE housing_project
DROP COLUMN "OwnerAddress"
