
-- Cleaning data in SQL
select *
from [Portfolio Projects]..[NashvillHousing]

-------------------------------------------------------------------------------------

-- Standardize Date Format


alter table [PORTFOLIO Project ]..Nashvillhousing 
add [Sale Date] date;

update [PORTFOLIO Project ]..Nashvillhousing 
set [Sale Date] = Convert(Date,SaleDate)

Select [Sale Date]
from [PORTFOLIO Project ]..Nashvillhousing  


-------------------------------------------------------------------------------------------------

-- Populate Property Address Data 

Select *
from [PORTFOLIO Project ]..Nashvillhousing
--where PropertyAddress is null
order by ParcelID

Select A.ParcelID,A.PropertyAddress,B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
from [PORTFOLIO Project ]..Nashvillhousing A
JOIN [PORTFOLIO Project ]..Nashvillhousing B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
Where A.PropertyAddress is null

update A
set propertyaddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from [PORTFOLIO Project ]..Nashvillhousing A
JOIN [PORTFOLIO Project ]..Nashvillhousing B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <>B.UniqueID

--------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)

Select PropertyAddress
from [Portfolio Project]..NashvillHousing

select 
substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,charindex(',',PropertyAddress)+1, len(PropertyAddress))as Address
from [Portfolio Project]..NashvillHousing



alter table [PORTFOLIO Project ]..Nashvillhousing 
add [Property_Split Address] nvarchar (255);

update [PORTFOLIO Project ]..Nashvillhousing 
set [Property_Split Address] = substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1)


alter table [PORTFOLIO Project ]..Nashvillhousing 
add [Property_Split City] nvarchar(255);

update [PORTFOLIO Project ]..Nashvillhousing 
set [Property_Split City] = substring(PropertyAddress,charindex(',',PropertyAddress) +1, len(PropertyAddress))


Select [Property_Split City],[Property Split Address]
from [PORTFOLIO Project ]..Nashvillhousing 



SELECT *
FROM [PORTFOLIO Project ]..Nashvillhousing


Select ownerAddress
from [PORTFOLIO Project ]..Nashvillhousing


select 
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)
FROM [PORTFOLIO Project ]..Nashvillhousing

alter table [PORTFOLIO Project ]..Nashvillhousing 
add [Owner_Split Address] nvarchar (255);

update [PORTFOLIO Project ]..Nashvillhousing 
set [Owner_Split Address] = PARSENAME(REPLACE(OwnerAddress,',', '.') ,3)


alter table [PORTFOLIO Project ]..Nashvillhousing 
add [Owner_Split City] nvarchar(255);

update [PORTFOLIO Project ]..Nashvillhousing 
set [Owner_Split City] = PARSENAME(REPLACE(OwnerAddress,',', '.') ,2)

alter table [PORTFOLIO Project ]..Nashvillhousing 
add [Owner_Split State] nvarchar(255);

update [PORTFOLIO Project ]..Nashvillhousing 
set [Owner_Split State] = PARSENAME(REPLACE(OwnerAddress,',', '.') ,1)


--Alter table [PORTFOLIO Project ]..Nashvillhousing 
--drop column [Owner_Split Address]


------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes And NO in'Sold in vacant' field


select distinct(soldasvacant),count(soldasvACANT)
from [PORTFOLIO Project ]..Nashvillhousing  
GROUP BY SOLDASVACANT
ORDER BY 2


SELECT SOLDASVACANT,
	CASE 
		when soldasvacant ='Y' Then 'Yes'
		When soldasvacant = 'N' Then 'No'
		Else 
		SoldAsVacant
	END
from  [PORTFOLIO Project ]..Nashvillhousing 


UPDATE NashvillHousing
set SoldAsVacant = 	CASE 
		when soldasvacant ='Y' Then 'Yes'
		When soldasvacant = 'N' Then 'No'
		Else 
		SoldAsVacant
	END


	--------------------------------------------------------------------------------------------------------------

-- Remove Duplicates




WITH ROW_NUM_CTE AS(
select *, 
		ROW_NUMBER() OVER (
		PARTITION BY PARCELID,
					 PROPERTYaDDRESS,
					 SALEPRICE,
					 SALEDATE,
					 LegalReference
					 order by 
						UniqueID
						) ROW_NUM


from  [PORTFOLIO Project ]..Nashvillhousing
--ORDER BY PARCELID
)
DELETE 
FROM ROW_NUM_CTE
WHERE ROW_NUM> 1
--ORDER BY PROPERTYADDRESS

------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

select *
from  [PORTFOLIO Project ]..Nashvillhousing 

alter table [PORTFOLIO Project ]..Nashvillhousing 
DROP COLUMN owneraddress, TaxDistrict, PropertyAddress


alter table [PORTFOLIO Project ]..Nashvillhousing 
drop column SaleDate

