select *
from portfolio_project3..Sheet1$


--standardise date format----------
select saledateconverted,convert(date, SaleDate)
from portfolio_project3..Sheet1$

update Sheet1$
set SaleDate = convert(date, SaleDate)

alter table Sheet1$
add saledateconverted date

update Sheet1$
set saledateconverted = convert(date, SaleDate)

--populate property address data---------
select *
from portfolio_project3..Sheet1$
where PropertyAddress is null
--self join
select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress
from portfolio_project3..Sheet1$ a
join portfolio_project3..Sheet1$ b
on a.ParcelID = b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
--populating values using isnull

select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from portfolio_project3..Sheet1$ a
join portfolio_project3..Sheet1$ b
on a.ParcelID = b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--update the value

update a
set PropertyAddress =isnull(a.PropertyAddress,b.PropertyAddress)
from portfolio_project3..Sheet1$ a
join portfolio_project3..Sheet1$ b
on a.ParcelID = b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

----breaking out address into individual columns----

select PropertyAddress
from portfolio_project3..Sheet1$

 --using substring

 select 
 SUBSTRING(PropertyAddress,1 ,CHARINDEX(',',PropertyAddress)-1) as address1, ---charindex is used just for the index
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress) )as address2
from portfolio_project3..Sheet1$


---add column and update
alter table Sheet1$
add propertysplitaddress nvarchar(255)

update Sheet1$
set propertysplitaddress = SUBSTRING(PropertyAddress,1 ,CHARINDEX(',',PropertyAddress)-1)

alter table Sheet1$
add propertysplitcity nvarchar(255)

update Sheet1$
set propertysplitcity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress) )

select *
from portfolio_project3..Sheet1$
---owner adress in parsename method
select OwnerAddress
from portfolio_project3..Sheet1$

select 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from portfolio_project3..Sheet1$

--add column and update
alter table portfolio_project3..Sheet1$
add ownersplitaddress nvarchar(255)

update portfolio_project3..Sheet1$
set ownersplitaddress = parsename(replace(OwnerAddress,',','.'),3)

alter table portfolio_project3..Sheet1$
add ownersplitcity nvarchar(255)

update portfolio_project3..Sheet1$
set ownersplitcity = parsename(replace(OwnerAddress,',','.'),2)

alter table portfolio_project3..Sheet1$
add ownersplitstate nvarchar(255)

update portfolio_project3..Sheet1$
set ownersplitstate = parsename(replace(OwnerAddress,',','.'),1)

select *
from portfolio_project3..Sheet1$

----change Y and N to yes and no in sold as vacant field------
select distinct(SoldAsVacant)
from  portfolio_project3..Sheet1$

--use case statement
select SoldAsVacant,
case 
when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant= 'N' then'No'
else  SoldAsVacant
end as updatedSoldasvacant
from  portfolio_project3..Sheet1$
 --update it
 update portfolio_project3..Sheet1$
 set SoldAsVacant = case 
when SoldAsVacant ='Y' then 'Yes'
when SoldAsVacant= 'N' then'No'
else  SoldAsVacant
end 

-----remove duplicates----------

select *,
row_number() over (partition by ParcelID,
                                PropertyAddress,
								SaleDate,
								SalePrice,
								LegalReference
								order by uniqueId) as rownum

from portfolio_project3..Sheet1$
order by ParcelID

---cte
with rownumcte as(
select *,
row_number() over (partition by ParcelID,
                                PropertyAddress,
								SaleDate,
								SalePrice,
								LegalReference
								order by uniqueId) as rownum

from portfolio_project3..Sheet1$
)

delete
from rownumcte
where rownum >1
 
 -------delete unused columns ------------
 select *
 from portfolio_project3..Sheet1$

 alter table portfolio_project3..Sheet1$
 drop column PropertyAddress,SaleDate,OwnerAddress