--Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------
--Standardized Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------
--Populate Property Adress Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
--Checks to see isnull and populates it with a value
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a
JOIN PortfolioProject.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------
--Breaking out Adress into Individual Columns (Adress, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
--Way more usable data now
Select *
From PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select 
 PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)
 ,PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)
 ,PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)


--Check Work
Select *
From PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

-----------------------------------------------------------------------------------------------------
--Remove Duplicates--Not Standard Practice in SQL
--Creates temporary table RowNumCTE and we call from it
With RowNumCTE AS (
Select *,
	ROW_NUMBER() Over (
	PARTITION By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress

------------------------------------------------------------------------------------------------

--The columns we created are much more usable and friendly
