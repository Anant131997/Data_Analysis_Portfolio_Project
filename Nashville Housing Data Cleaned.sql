/*
CREATING DATA IN SQL QUERIES
*/

SELECT * 
FROM NashvilleHousing

---------------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT

SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)


-----------------------------------------------------------------------------------
-- POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--------------------------------------------------------------------------------
-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS ADDRESS,
--CHARINDEX(',',PropertyAddress)
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS CITY
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress varchar(50)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCityAddress varchar(50)

UPDATE NashvilleHousing 
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT * 
FROM NashvilleHousing

SELECT OwnerAddress 
FROM NashvilleHousing

-- USING PARSENAME TO SEPERATE SENTENCE

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2) , 
PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress varchar(50)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity varchar(50)

UPDATE NashvilleHousing 
SET PropertySplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState varchar(50)

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

--EXEC sp_rename 'NashvilleHousing.OwnerCityAddress', 'PropertySplitCity', 'COLUMN';

---Change Y and N to YES and NO in 'Sold as Vacant' 

Select Distinct(SoldAsVacant) , count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant


select SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'N' THEN 'NO'
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	ELSE SoldAsVacant
END
from NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'N' THEN 'NO'
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	ELSE SoldAsVacant
END


--- REMOVE DUPLICATES (USING CTE)

WITH RowNumCTE as(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
					PropertyAddress, 
					SalePrice, 
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) as row_num
FROM NashvilleHousing
)
--order by ParcellID
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress


--- DELETE UNUSED COLUMNS

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate



