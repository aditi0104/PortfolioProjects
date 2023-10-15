select * from NashvilleHousing

-- standadize date format

select SaleDate, convert(Date, SaleDate)
from NashvilleHousing


-- this should work but doesnt so trying alter table
UPDATE NashvilleHousing
SET SaleDate = convert(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = convert(Date, SaleDate)

select SaleDateConverted, convert(Date, SaleDate)
from NashvilleHousing

-- Populate property address data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- replace the property address which is null for a parcelID by another entry for the same parcelID's Propertyaddress

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as PropertyAddressConverted
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking the address into individual values (address, state, city)
select PropertyAddress
from NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyAddressSplit nvarchar(255)

UPDATE NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertyAddressCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select *
from NashvilleHousing

-- doing the same thing for owner address

select OwnerAddress
from NashvilleHousing

--we will not use the substring again, instead we will use parsename
--parsename spilts the value backwords
select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerAddressCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerAddressState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from NashvilleHousing

--Changing the Sold as vacant column to (yes,no)

Select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant


select SoldAsVacant,
CASE when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashvilleHousing

UPDATE NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashvilleHousing

--remove duplicates
with rownumcte as (
select *,
ROW_NUMBER () Over (
Partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by UniqueID) row_num
from NashvilleHousing
--order by ParcelID
)
select * from rownumcte
where row_num > 1

-- delete unused columns
select * from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

