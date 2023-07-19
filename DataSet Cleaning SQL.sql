/*
Cleaning data in SQL-->
*/

SELECT SaleDate
FROM PortfolioProject..Housing



----------------------------------------------------------------------------------------------

--Standardize the date format-->
 SELECT SaleDateConverted, CONVERT(Date,SaleDate)
 FROM PortfolioProject..Housing

 UPDATE PortfolioProject..Housing
 SET Saledate = CONVERT(Date,Saledate)

 ALTER TABLE PortfolioProject..Housing
 ADD SaleDateConverted Date;
  
 UPDATE PortfolioProject..Housing
 SET SaleDateConverted = CONVERT(Date,Saledate)




----------------------------------------------------------------------------------------------

--Data regarding populate property address
 SELECT PropertyAddress 
 FROM PortfolioProject..Housing

 SELECT h1.ParcelID,h1.PropertyAddress,h2.ParcelID,h2.PropertyAddress,ISNULL(h1.PropertyAddress,h2.PropertyAddress)
 From PortfolioProject..Housing h1
 JOin PortfolioProject..Housing h2
     ON h1.ParcelID = h2.ParcelID
	 AND h1.[UniqueID ]<>h2.[UniqueID ]
WHERE h1.PropertyAddress is null

UPDATE h1
SET PropertyAddress = ISNULL(h1.PropertyAddress,h2.PropertyAddress)
From PortfolioProject..Housing h1
 JOin PortfolioProject..Housing h2
     ON h1.ParcelID = h2.ParcelID
	 AND h1.[UniqueID ]<>h2.[UniqueID ]
WHERE h1.PropertyAddress is null

----------------------------------------------------------------------------------------------

--Breaking out address into Indivisual columns(Address,city and state)
SELECT PropertyAddress 
 FROM PortfolioProject..Housing

 SELECT
 SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
 ,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as address

 FROM PortfolioProject..Housing

 ALTER TABLE PortfolioProject..Housing
 ADD PropSplitAdd nvarchar(255);

 UPDATE PortfolioProject..Housing
 SET PropSplitAdd =  SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

 ALTER TABLE PortfolioProject..Housing
 ADD PropSplitCity nvarchar(255);
  
 UPDATE PortfolioProject..Housing
 SET PropSplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
 
 --Using parsename-->
   
 SELECT OwnerAddress
 FROM PortfolioProject..Housing
 
 SELECT
 PARSENAME(REPLACE( OwnerAddress,',','.') , 3)
 ,PARSENAME(REPLACE( OwnerAddress,',','.') , 2)
 ,PARSENAME(REPLACE( OwnerAddress,',','.') , 1)
  FROM PortfolioProject..Housing

  
 ALTER TABLE PortfolioProject..Housing
 ADD OwnerSplitAdd nvarchar(255);

 UPDATE PortfolioProject..Housing
 SET  OwnerSplitAdd =  PARSENAME(REPLACE( OwnerAddress,',','.') , 3)

 ALTER TABLE PortfolioProject..Housing
 ADD  OwnerSplitCity nvarchar(255);
  
 UPDATE PortfolioProject..Housing
 SET  OwnerSplitCity =  PARSENAME(REPLACE( OwnerAddress,',','.') , 2)

 ALTER TABLE PortfolioProject..Housing
 ADD  OwnerSplitState nvarchar(255);
  
 UPDATE PortfolioProject..Housing
 SET  OwnerSplitState =  PARSENAME(REPLACE( OwnerAddress,',','.') , 1)

 SELECT *
 FROM PortfolioProject..Housing



-----------------------------------------------------------------------------------------------

--Changing 'Y' and 'N' into 'YES' and 'NO' in 'Sold as Vacant' field

SELECT distinct(SoldasVacant),Count(SoldasVacant)
FROM PortfolioProject..Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldasVacant
,  CASE WHEN SoldasVacant = 'Y' THEN 'Yes' 
       WHEN SoldasVacant = 'N' THEN 'No' 
	   ELSE SoldasVacant
	   END
FROM PortfolioProject..Housing

UPDATE PortfolioProject..Housing
SET SoldAsVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes' 
					WHEN SoldasVacant = 'N' THEN 'No' 
					ELSE SoldasVacant
					END

-----------------------------------------------------------------------------------------------

--Remove Duplicates 
WITH RowNumCTE As(
SELECT *, 
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				     UniqueID
	                ) row_num

FROM PortfolioProject..Housing
--ORDER BY ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1

-----------------------------------------------------------------------------------------------

--Delete Unused columns
--NOTE--> Not reccomended for using on raw data consult the data provider before hand deleting the data.

SELECT *
FROM PortfolioProject..Housing

ALTER TABLE PortfolioProject..Housing
DROP COLUMN SaleDate