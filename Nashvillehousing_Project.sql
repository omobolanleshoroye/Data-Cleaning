-- Import dataset into SQL database
-- View dataset

select *
from housing_project

-- Cleaning begins 
-- "" used because of uppercase letters in dataset column names
-- Clean up date format 

SELECT "SaleDate" as Date, CAST ("SaleDate" as date)  
FROM housing_project

Update housing_project
SET "SaleDate" = CAST ("SaleDate" as date)

-- Populate property address

select "PropertyAddress"
from housing_project
Where "PropertyAddress" is null
-- 29 null rows 

select *
from housing_project
Where "PropertyAddress" is null
-- Property address is highly likely not to change but other columns can. 

select "ParcelID", "PropertyAddress"
from housing_project
--Where "PropertyAddress" is null
order by "ParcelID"
-- Parcel Ids with the same code have the same property addresses

-- Self Join 

select *
from housing_project a
join housing_project b
on a."ParcelID" = b."ParcelID"
and a."UniqueID " <> b."UniqueID "


select a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress"
from housing_project a
join housing_project b
on a."ParcelID" = b."ParcelID"
and a."UniqueID " <> b."UniqueID "
where a."PropertyAddress" is null
-- This shows the null property addresses in one column and the populated ones in another property adress column. It gives the addresses we need to populate the null columns.


select a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress", COALESCE (a."PropertyAddress", b."PropertyAddress")
from housing_project a
join housing_project b
on a."ParcelID" = b."ParcelID"
and a."UniqueID " <> b."UniqueID "
where a."PropertyAddress" is null

-- Update table with populated data

update housing_project 
set "PropertyAddress" =  COALESCE (a."PropertyAddress", b."PropertyAddress")
from housing_project a
join housing_project b
on a."ParcelID" = b."ParcelID"
and a."UniqueID " <> b."UniqueID "
where a."PropertyAddress" is null

-- Run previous queries to clarify that there are no null values

-- Breaking out the adresses into individual columns (Address, City, State)
-- Property address first

select "PropertyAddress"
from housing_project

SELECT 
SUBSTRING("PropertyAddress", 1, STRPOS("PropertyAddress", ',')-1) AS Address,
SUBSTRING("PropertyAddress", STRPOS("PropertyAddress", ',')+1, LENGTH("PropertyAddress")) AS Address
FROM housing_project

-- Update table with new columns

Alter table housing_project
Add "PropertysplitAddress" varchar (300)

Alter table housing_project
Add "Propertycity" varchar (300)

Update housing_project
SET "PropertysplitAddress" =  
SUBSTRING("PropertyAddress", 1, STRPOS("PropertyAddress", ',')-1) 

Update housing_project
SET "Propertycity" =  
SUBSTRING("PropertyAddress", STRPOS("PropertyAddress", ',')+1, LENGTH("PropertyAddress")) 

-- Owner address

select "OwnerAddress"
from housing_project

SELECT Split_part("OwnerAddress",',',1),
Split_part("OwnerAddress",',',2),
Split_part("OwnerAddress",',',3)
from housing_project

Alter table housing_project
Add "OwnersplitAddress" varchar (300)

Update housing_project
SET "OwnersplitAddress" =  
Split_part("OwnerAddress",',',1)

Alter table housing_project
Add "Ownercity" varchar (300)

Update housing_project
SET "Ownercity" =  
Split_part("OwnerAddress",',',2)

Alter table housing_project
Add "Ownerstate" varchar (300)

Update housing_project
SET "Ownerstate" =  
Split_part("OwnerAddress",',',3)

-- SoldAsVacant column. Change N to No and Y to Yes using case statement

select distinct "SoldAsVacant"
from housing_project

select distinct "SoldAsVacant", count("SoldAsVacant")
from housing_project
group by "SoldAsVacant"
order by 2

select "SoldAsVacant",
case when "SoldAsVacant" = 'Y' then 'Yes'
    when "SoldAsVacant" = 'N' then 'No'
    else "SoldAsVacant"
    end
FROM housing_project

Update housing_project
Set "SoldAsVacant" =
case when "SoldAsVacant" = 'Y' then 'Yes'
    when "SoldAsVacant" = 'N' then 'No'
    else "SoldAsVacant"
    end
	
-- Remove Duplicates

select *,
    row_number() over(
    partition by "ParcelID",
    "PropertyAddress",
    "SalePrice",
    "SaleDate",
    "LegalReference"
    Order by "UniqueID "
    ) row_num
FROM housing_project


WITH RowNumCTE as(
select *,
    row_number() over(
    partition by "ParcelID",
    "PropertyAddress",
    "SalePrice",
    "SaleDate",
    "LegalReference"
    Order by "UniqueID "
    ) row_num
FROM housing_project
)

select *
from RowNumCTE
where row_num > 1

with RowNumCTE as(
select *,
    row_number() over(
    partition by "ParcelID",
    "PropertyAddress",
    "SalePrice",
    "SaleDate",
    "LegalReference"
    Order by "UniqueID "
    ) row_num
FROM housing_project
)

delete
from RowNumCTE
where row_num > 1


-- Delete unused columns 

alter table housing_project
drop column "OwnerAddress"
