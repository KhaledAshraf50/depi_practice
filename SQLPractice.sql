use AdventureWorks2022

/*
1.1 List all employees hired after January 1, 2012, showing their ID,first name, last name, and hire date, ordered by hire date descending.
*/
select e.BusinessEntityID,CONCAT(FirstName,MiddleName,LastName) as full_name,HireDate from HumanResources.Employee e join Person.Person p 
on e.BusinessEntityID = p.BusinessEntityID
where HireDate > '1/1/2012'
order by HireDate desc

/*1.2 List products with a list price between $100 and $500,
showing product ID, name, list price, and product number, ordered by list price ascending.*/
	select ProductID,name,ListPrice,ProductNumber 
	from Production.Product where ListPrice between 100 and 500  order by ListPrice

---1.3 List customers  the cities 'Seattle' or 'Portland',
--showing customer ID, first name, last name, and city, using appropriate joins.
select CustomerID ,FirstName ,LastName,City as customer from 
Person.BusinessEntityAddress ba
join Person.Person p on p.BusinessEntityID =ba.BusinessEntityID 
join Person.Address a on a.AddressID =ba.AddressID
join Sales.Customer c on c.CustomerID= p.BusinessEntityID 
where a.City='Seattle' or  a.City='Portland'

/*
1.4 List the top 15 most expensive products currently being sold, showing name, list price, product number,
and category name, excluding discontinued products.
*/
select top 15 c.Name,ListPrice,ProductNumber from Production.Product p join Production.ProductSubcategory sc
on p.ProductSubcategoryID = sc.ProductSubcategoryID  join Production.ProductCategory c 
on sc.ProductCategoryID = c.ProductCategoryID

  /*2.1 List products whose name contains 'Mountain' and color is 'Black',
  showing product ID, name, color, and list price.*/
select p.Name,color,ProductID,ListPrice 
from Production.Product p where name like ('Mountain%') and  Color ='Black'

---2.2 List employees born between January 1, 1970, and December 31, 1985, 
--showing full name, birth date, and age in years.
 
 select FirstName+' '+LastName as fullname , BirthDate,YEAR(getdate())-YEAR(BirthDate)as age
 from HumanResources.Employee e
 join Person.Person p on e.BusinessEntityID =p.BusinessEntityID

 /*
2.3 List orders placed in the fourth quarter of 2013,
showing order ID, order date, customer ID, and total due.
*/
select SalesOrderID,OrderDate,CustomerID,TotalDue from Sales.SalesOrderHeader
where year(OrderDate)=2013 and Month(OrderDate) in (10,11,12) 

/*2.4 List products with a null weight but a non-null size, showing product ID,
name, weight, size, and product number.*/
select ProductID, name ,Weight,Size ,ProductNumber from Production.Product
where size is not null and Weight is null

---3.1 Count the number of products by category, ordered by count descending.
select pc.ProductCategoryID ,count(*) as count_products from Production.Product p
join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID 
join Production.ProductCategory pc on pc.ProductCategoryID = psc.ProductCategoryID
group by pc.ProductCategoryID
order by COUNT(*)desc

/*
3.2 Show the average list price by product subcategory,
including only subcategories with more than five products.
*/
select sc.Name, AVG(ListPrice)avr_price from Production.ProductSubcategory sc join Production.Product p 
on sc.ProductSubcategoryID = p.ProductSubcategoryID
group by sc.Name
having count(ProductID)>5

/*3.3 List the top 10 customers by total order count, including customer name.*/
select top 10  p.FirstName,count(*) as totalOrderCount from sales.Customer c join Person.Person p
on c.PersonID=p.BusinessEntityID join Sales.Store s on c.StoreID=s.BusinessEntityID
join Sales.SalesOrderHeader SOH on soh.CustomerID=c.CustomerID 
group by c.CustomerID ,p.FirstName

---3.4 Show monthly sales totals for 2013, displaying the month name and total amount.

select MONTH(ModifiedDate) as month,count(SalesOrderDetailID) from [Sales].[SalesOrderDetail]
where YEAR(ModifiedDate)=2013
group by MONTH(ModifiedDate)
order by month

/*
4.1 Find all products launched in the same year as 'Mountain-100 Black, 42'.
Show product ID, name, sell start date, and year.
*/
select ProductID,Name,SellStartDate,year(SellStartDate)  AS SellYear
from Production.Product 
where YEAR(SellStartDate) =(select YEAR(SellStartDate)
from Production.Product where Name = 'Mountain-100 Black, 42')

/*4.2 Find employees who were hired on the same date as someone else.
Show employee names, shared hire date, and the count of employees hired that day.*/
select e.HireDate ,p.FirstName +' '+p.LastName as "Name",
count(*) over(partition by e.HireDate) EmployeesHiredThatDay
from HumanResources.Employee e join Person.Person p 
on p.BusinessEntityID=e.BusinessEntityID 
where e.HireDate in 
(select HireDate from HumanResources.Employee group by HireDate having count(*)>1)
order by HireDate

/*
5.1 Create a table named Sales.ProductReviews with columns for review ID, product ID,
customer ID, rating, review date, review text, verified purchase flag, and helpful votes.
Include appropriate primary key, foreign keys, check constraints,
defaults, and a unique constraint on product ID and customer ID.
*/

create table Sales.ProductReviews (
review_ID int primary key  ,
product_ID int Unique ,
customer_ID int Unique ,
ratting int  check (ratting >=0 and ratting<6),
review_date date Default  getdate(),
review_text text,
verified_purchase_flag bit default 0,
helpful_votes  int 
   constraint FK_Product Foreign key (product_ID) references production.product(productID),
   constraint fK_customer Foreign key (customer_ID) references sales.customer (customerid),
   constraint UQ_product_customer UNIQUE (product_ID, customer_ID)
)
/*
6.1 Add a column named LastModifiedDate to the Production.Product table,
with a default value of the current date and time.
*/
alter table production.product 
add  LastModifiedDate datetime default getdate();

/*6.2 Create a non-clustered index on the LastName column of the Person.Person table, including FirstName and MiddleName.*/
create nonclustered index ix_person_lastname
on person.person (lastname)
include (FirstName,middlename);
--6.3 Add a check constraint to the Production.
--Product table to ensure that ListPrice is greater than StandardCost.
Alter table Production.Product
add constraint  listprice_greater_StandardCost
check (listprice>standardcost)
/*
7.1 Insert three sample records into Sales.ProductReviews using existing product and customer IDs,
with varied ratings and meaningful review text.
*/
CREATE TABLE Sales.ProductReviews (
ReviewID int identity primary key,
ProductID int foreign KEY REFERENCES Production.Product(ProductID),
CustomerID int foreign KEY REFERENCES Sales.Customer(CustomerID),
Rating int check (Rating BETWEEN 1 AND 5),
ReviewText NVARCHAR(500),
ReviewDate DATETIME DEFAULT GETDATE()
);
INSERT INTO Sales.ProductReviews (ProductID, CustomerID, Rating, ReviewText)
VALUES 
(316, 71, 5, 'Excellent product, highly recommended!'),
(319, 106, 3, 'Average quality, expected better.'),
(3, 281, 1, 'Very disappointed, not worth the price.');

/*7.2 Insert a new product category named 'Electronics' and a corresponding product subcategory 
named 'Smartphones' under Electronics.*/
select * from Production.ProductCategory
insert into Production.ProductCategory (Name)
values ('Electronics')
declare @category_id int = scope_identity();
insert into Production.ProductSubcategory(ProductCategoryID ,Name)
values (@category_id,'Smartphones')

--7.3 Copy all discontinued products (where SellEndDate is not null) 
--into a new table named Sales.DiscontinuedProducts.
create table Sales.DiscontinuedProducts(
ProductID int ,
name nvarchar(50),
DiscontinuedDate datetime 
)
insert into Sales.DiscontinuedProducts
select ProductID,Name,SellEndDate from Production.Product where SellEndDate is not null
select * from Sales.DiscontinuedProducts

/*8.1 Update the ModifiedDate to the current date for all products 
where ListPrice is greater than $1000 and SellEndDate is null.
*/

update Production.Product set ModifiedDate= GETDATE() where ListPrice > 1000 and SellEndDate is null
select * from Production.Product
/*8.2 Increase the ListPrice by 15% for all products in the 'Bikes' category and update the ModifiedDate.*/
select*from Production.Product
update Production.Product  
set ListPrice = (ListPrice+(ListPrice*0.15)) , ModifiedDate= getdate()
where ProductSubcategoryID in 
(select ps.ProductSubcategoryID from Production.ProductCategory pc join Production.ProductSubcategory ps on
ps.ProductCategoryID=pc.ProductCategoryID 
where pc.Name='Bikes')

--8.3 Update the JobTitle to 'Senior' plus the existing 
--job title for employees hired before January 1, 2010.
select * from HumanResources.Employee
update HumanResources.Employee set JobTitle= 'senior '+ JobTitle
where year(HireDate)<2010
	/*
	9.1 Delete all product reviews with a rating of 1 and helpful votes equal to 0.
	*/
	alter table sales.ProductReviews 
	add HelpfulVotes int default 0;

	delete from Sales.ProductReviews 
	where Rating = 1 and HelpfulVotes =0 

	select * from  Sales.ProductReviews 
	/*9.2 Delete products that have never been ordered, 
	using a NOT EXISTS condition with Sales.SalesOrderDetail.*/

DELETE FROM Production.Product
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales.SalesOrderDetail SOD
    WHERE SOD.ProductID = Production.Product.ProductID
)
--9.3 Delete all purchase orders from vendors that are no longer active.

select * from Purchasing.Vendor
select * from Purchasing.ProductVendor

delete e from Purchasing.ProductVendor e
join Purchasing.Vendor v on  e.BusinessEntityID= v.BusinessEntityID
where v.ActiveFlag=0
/*
10.1 Calculate the total sales amount by year from 2011 to 2014,
showing year, total sales, average order value, and order count.
*/
select YEAR(OrderDate), sum(UnitPrice*OrderQty)AS TotalSalesAmount,
AVG(UnitPrice*OrderQty)AS AvgOrderValu,count(distinct oh.SalesOrderID) AS OrderCount from sales.SalesOrderDetail od join sales.SalesOrderHeader oh 
on od.SalesOrderID = oh.SalesOrderID where year(OrderDate) between 2011 and 2014
group by YEAR(OrderDate)

/*10.2 For each customer, show customer ID, total orders, 
total amount, average order value, first order date, and last order date.*/
select c.CustomerID,COUNT(distinct soh.SalesOrderID)AS total_orders,
sum(UnitPrice*OrderQty*(1-UnitPriceDiscount))as "total orders amount" ,
(sum(UnitPrice*OrderQty*(1-UnitPriceDiscount)))/(COUNT(distinct soh.SalesOrderID)) as average,
min(OrderDate) as firstdate, Max(OrderDate) as LastDate
from Sales.Customer c join Sales.SalesOrderHeader soh 
on c.CustomerID=soh.CustomerID join Sales.SalesOrderDetail sod on soh.SalesOrderID=sod.SalesOrderID
group by c.CustomerID
order by c.CustomerID

--10.3 List the top 20 products by total sales amount, 
--including p.product name, p.category, total quantity sold, and total revenue.

with  product_category
as
(
select ProductID,sum(UnitPrice*OrderQty*(1-UnitPriceDiscount)) as sum ,count(*) as count
FROM Sales.SalesOrderDetail
group by ProductID
)
select top 20 p.ProductID,p.Name,c.Name,pc.count,pc.sum from product_category pc 
join Production.Product p on pc.ProductID= p.ProductID
join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory c on p.ProductSubcategoryID=c.ProductCategoryID
/*
10.4 Show sales amount by month for 2013, 
displaying the month name, sales amount, and percentage of the yearly total.
*/
select datename(MONTH,OrderDate),sum(TotalDue),
cast(SUM(TotalDue)/(select SUM(TotalDue) from Sales.SalesOrderHeader where YEAR(OrderDate) = 2013) *100 as decimal) 
from Sales.SalesOrderHeader 
where YEAR(OrderDate) = 2013
group by datename(MONTH,OrderDate)
/*11.1 Show employees with their full name, age in years, years of service, 
hire date formatted as 'Mon DD, YYYY', and birth month name.*/

select p.FirstName+' '+p.LastName as name ,(year(GETDATE())-year(BirthDate)) as age,
case 
when year([EndDate]) is not null then  (year([EndDate])-year([StartDate]))
when year([EndDate]) is null then year(getdate())-year([StartDate])
end as years_of_service ,
FORMAT(e.HireDate, 'MMM dd, yyyy') AS FormattedHireDate,
DATENAME(MONTH, e.BirthDate) AS BirthMonth

from HumanResources.Employee e  join Person.Person p 
on e.BusinessEntityID =p.BusinessEntityID join
HumanResources.EmployeeDepartmentHistory EDH
on EDH.BusinessEntityID=e.BusinessEntityID;
--11.2 Format customer names as 'LAST, First M.' (with middle initial), extract the email domain,and apply proper case formatting.
select upper(LastName)+','+ left(FirstName,1)+SUBSTRING(FirstName,2,len(FirstName))+' '+left(MiddleName,1) ,
SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, LEN(EmailAddress)) AS Domain
 from Sales.Customer c  
join Person.Person p on p.BusinessEntityID=c.PersonID 
join Person.EmailAddress em on p.BusinessEntityID =em.BusinessEntityID

/*
11.3 For each product, show name, weight rounded to one decimal, 
weight in pounds (converted from grams), and price per pound.
*/
select ProductID,round(Weight,1)as weight_rounded_one,(453.592/Weight) as weigth_pounds,
ListPrice/(453.592/Weight)
from Production.Product

/*12.1 List product name, category, subcategory,
and vendor name for products that have been purchased from vendors.*/

select p.Name as productName,pc.Name as categoryName ,
ps.Name as subcategoryName ,v.Name
from Production.Product p 
join Production.ProductSubcategory ps 
on  p.ProductSubcategoryID=ps.ProductSubcategoryID
join Production.ProductCategory pc 
on ps.ProductCategoryID=pc.ProductCategoryID
join Purchasing.ProductVendor pv 
on p.ProductID=p.ProductID
join Purchasing.Vendor v 
on pv.BusinessEntityID=v.BusinessEntityID

--12.2 Show order details including order ID, customer name, 
-- oh.salesperson name,oh. territory name,p. product name, quantity, and d.line total.

select * from Sales.SalesOrderHeader  oh
select * from Sales.SalesOrderDetail od 

select od.SalesOrderID,p.FirstName+' '+ p.LastName as customer_name ,
oh.SalesPersonID ,oh.TerritoryID,ProductID,od.OrderQty 
from Sales.SalesOrderHeader  oh
join Sales.SalesOrderDetail od on od.SalesOrderID=oh.SalesOrderID
join Sales.Customer c on c.CustomerID = oh.CustomerID
join Person.Person p on p.BusinessEntityID = c.PersonID

/*
12.3 List employees with their sales territories, including employee name, job title, territory name,
territory group, and sales year-to-date.
*/
select CONCAT(FirstName,' ',MiddleName,' ',LastName) as full_name,JobTitle,t.Name,
t.SalesLastYear,t.[Group]
from HumanResources.Employee e join Person.Person p 
on e.BusinessEntityID = p.BusinessEntityID join Sales.SalesPerson sp on e.BusinessEntityID = sp.BusinessEntityID
join Sales.SalesTerritory t on sp.TerritoryID = t.TerritoryID 
/*13.1 List all products with their total sales,
including those never sold. Show product name, category, total quantity sold (zero if never sold),
and total revenue (zero if never sold).*/
select 
    p.Name AS ProductName,
    pc.Name AS CategoryName,
    ISNULL(SUM(sod.OrderQty), 0) AS TotalQuantitySold,
    ISNULL(SUM(sod.LineTotal), 0) AS TotalRevenue
FROM 
    Production.Product p
left join Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
left join Production.ProductSubcategory ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
left join Production.ProductCategory pc on ps.ProductCategoryID = pc.ProductCategoryID
group by 
    p.ProductID, p.Name, pc.Name

/*13.2 Show all sales territories with their assigned employees, including unassigned territories.
Show territory name, employee name (null if unassigned), and sales year-to-date.*/

select st.Name,p.FirstName+' ' +p.LastName ,sp.SalesYTD 
from Sales.SalesTerritory st
left join Sales.SalesPerson sp on st.TerritoryID=sp.TerritoryID
left join HumanResources.Employee  e on sp.BusinessEntityID =e.BusinessEntityID
left join Person.Person p  ON  p.BusinessEntityID =e.BusinessEntityID   

/*
13.3 Show the relationship between vendors and product categories,
including vendors with no products and categories with no vendors.*/

select v.Name vendor_name,pc.Name category_name from Purchasing.Vendor v left join Purchasing.ProductVendor pv on v.BusinessEntityID = pv.BusinessEntityID
left join Production.Product p on p.ProductID = pv.ProductID left join Production.ProductSubcategory psc 
on p.ProductSubcategoryID = psc.ProductSubcategoryID left join Production.ProductCategory pc 
on psc.ProductCategoryID = pc.ProductCategoryID 
union 
select 
v.Name AS VendorName,
pc.Name AS CategoryName
FROM Production.ProductCategory pc
left join  Production.ProductSubcategory psc on pc.ProductCategoryID = psc.ProductCategoryID left join
 Production.Product p on psc.ProductSubcategoryID = p.ProductSubcategoryID	left join
 Purchasing.ProductVendor pv on p.ProductID = pv.ProductID
left join Purchasing.Vendor v on pv.BusinessEntityID = v.BusinessEntityID;
/*14.1 List products with above-average list price,
showing product ID, name, list price, and price difference from the average.*/

select name ,ProductID,ListPrice,
(ListPrice-(select avg(ListPrice) from Production.Product)) as "difference price"
from Production.Product 
where ListPrice > (
select avg(ListPrice) from Production.Product)

 --14.2 List customers who bought products from the 'Mountain' category, 
 --showing customer name, total orders, and total amount spent.
select p2.FirstName+' '+LastName as customer_name ,count (soh.SalesOrderID) ,
sum(LineTotal)  from Production.ProductSubcategory psc
join Production.Product p on psc.ProductSubcategoryID =p.ProductSubcategoryID
join production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
join [Sales].[SalesOrderDetail] sod on p.ProductID =sod.ProductID
join Sales.SalesOrderHeader soh on sod.SalesOrderID =soh.SalesOrderID
join Sales.Customer c on soh.CustomerID =c.CustomerID
join Person.Person p2 on p2.BusinessEntityID =c.PersonID
group by p2.FirstName+' '+LastName
/*
14.3 List products that have been ordered by more than 100 different customers,
showing product name, category, and unique customer count.
*/
select  p.Name,pc.Name,count(distinct soh.CustomerID) 
from production.product p join  Sales.SalesOrderDetail sod on p.ProductID = sod.ProductID
join  Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID join
Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory pc on pc.ProductCategoryID = psc.ProductCategoryID
group by p.Name,pc.Name 
having count(distinct soh.CustomerID) > 100

/*14.4 For each customer, show their order count and their rank among all customers.*/

select c.CustomerID ,COUNT(*) as "num of order" ,
dense_rank() over(order by count(*) desc) as"rank" from Sales.Customer c join Sales.SalesOrderHeader soh 
on soh.CustomerID=c.CustomerID
group by c.CustomerID

/* 15.1 Create a view named vw_ProductCatalog with product ID, name, product number,
category, subcategory, list price, standard cost, profit margin percentage, 
inventory level, and status (active/discontinued).*/
create view vw_ProductCatalog as
select p.ProductID,p.Name,p.ProductNumber,psc.ProductSubcategoryID,
p.ListPrice,p.StandardCost,ROUND(((p.ListPrice - p.StandardCost) / p.ListPrice) * 100, 2) as ProfitMarginPercentage , sum(pn.Quantity) as inventory ,
case 
when p.SellEndDate IS NULL THEN 'Active'
else 'Discontinued' 
end  as state
from Production.Product  p
left join Production.ProductSubcategory  psc on p.ProductSubcategoryID=psc.ProductSubcategoryID
left join Production.ProductInventory pn on pn.ProductID=p.ProductID
group by p.ProductID,p.Name,ProductNumber,SellEndDate,psc.ProductSubcategoryID,ListPrice,StandardCost
/*
15.2 Create a view named vw_SalesAnalysis with year, month, territory, total sales, 
order count, average order value, and top product name.
*/
  create view vw_SalesAnalysis as
   select p.Name as pro_name,sum(UnitPrice*OrderQty)as total_sales,YEAR(OrderDate)as year,MONTH(OrderDate) month,
   t.Name territory,COUNT(od.SalesOrderID) no_of_order,AVG(UnitPrice) ave_value 
   from Production.Product p join Sales.ProductReviews pr on p.ProductID = pr.ProductId
   join Sales.Customer c on pr.CustomerID = c.CustomerID join Sales.SalesOrderHeader oh on c.CustomerID = oh.CustomerID 
   join sales.SalesTerritory t on t.TerritoryID = oh.CustomerID join Sales.SalesOrderDetail od 
   on oh.SalesOrderID = od.SalesOrderID
   group by p.Name,YEAR(OrderDate),MONTH(OrderDate), t.Name
	select * from vw_SalesAnalysis 
	order by pro_name 

	/*15.3 Create a view named vw_EmployeeDirectory with 
full name, job title, department, manager name, hire date, years of service,email, and phone.
*/
create view vw_EmployeeDirectory as 
(
select p.FirstName+' '+p.LastName as "full name" ,d.Name as "department name",
JobTitle,HireDate ,pp.PhoneNumber,EA.EmailAddress,
case 
when year([EndDate]) is not null then  (year([EndDate])-year([StartDate]))
when year([EndDate]) is null then year(getdate())-year([StartDate])
end as years_of_service 
from HumanResources.Employee e join HumanResources.EmployeeDepartmentHistory  edh 
on e.BusinessEntityID=edh.BusinessEntityID
join HumanResources.Department d on edh.DepartmentID=d.DepartmentID
join Person.Person p on p.BusinessEntityID=e.BusinessEntityID
join Person.PersonPhone pp on e.BusinessEntityID=pp.BusinessEntityID
join Person.EmailAddress EA on e.BusinessEntityID=EA.BusinessEntityID
)
select * from vw_EmployeeDirectory
/*15.4 Write three different queries using the views you created, 
demonstrating practical business scenarios.
*/
--1:
select ProductID,v.ProductSubcategoryID,v.StandardCost from vw_ProductCatalog v
--2:
select ProductID,ListPrice from vw_ProductCatalog
where ListPrice>100
--3:
select ProductID,Name from vw_ProductCatalog
where state ='active'

/*
16.1 Classify products by price as 'Premium' (greater than $500), 'Standard' ($100 to $500), or 'Budget' 
(less than $100), and show the count and average price for each category.
*/
select pc.Name pro_name , 
case 
when ListPrice > 500 then 'Premium'
when ListPrice between 100 and 500 then 'Standard'
else 'Budget'
end as classify_pro,
count(ListPrice) count_price,AVG(ListPrice) avg_price
from Production.Product p join Production.ProductSubcategory psc on p.ProductSubcategoryID = psc.ProductSubcategoryID 
join Production.ProductCategory pc  on psc.ProductCategoryID = pc.ProductCategoryID 
group by pc.Name ,
case 
when ListPrice > 500 then 'Premium'
when ListPrice between 100 and 500 then 'Standard'
else 'Budget'
end

/*16.2 Classify employees by years of service as 'Veteran' (10+ years),
'Experienced' (5-10 years), 'Regular' (2-5 years), or 'New' (less than 2 years),
and show salary statistics for each group.*/

with EmpService as (
select p.FirstName+' '+p.LastName as "fullname",
case 
when edh.EndDate is null then (year(GETDATE())-YEAR(HireDate))
when edh.EndDate is not null then (year(EndDate)-YEAR(HireDate))
end as yearOfservice 
from HumanResources.Employee e join Person.Person p on e.BusinessEntityID=p.BusinessEntityID 
join HumanResources.EmployeeDepartmentHistory edh on e.BusinessEntityID=edh.BusinessEntityID
)
select 
fullname,
yearOfservice,
case
when yearOfservice>10 then 'Veteran'
when yearOfservice between 5 and 10 then 'Experienced'
when yearOfservice between 2 and 5 then 'Regular'
when yearOfservice <2 then 'New'
else 'not found'
end as typs
from EmpService

/*
17.1 Show products with name, weight (display 'Not Specified' if null),
size (display 'Standard' if null), and color (display 'Natural' if null).
*/
select Name,
coalesce(cast(Weight as varchar(20)),'Not Specified')as weight,
coalesce(Size,'Standard')as size ,
coalesce(Color,'Natural') as color 
from Production.Product

/*17.2 For each customer, display the best available contact method,
prioritizing email address, then phone, then address line.
*/
select p.FirstName+' '+p.LastName as "CustoumerName" ,
coalesce(EmailAddress,pp.phonenumber,addressline1) as "contactMethod" 
from sales.Customer c join Person.EmailAddress EA on c.PersonID=EA.BusinessEntityID
join Person.PersonPhone pp on c.PersonID=pp.BusinessEntityID
join Person.Person p on c.PersonID=p.BusinessEntityID 
join Person.BusinessEntityAddress BE on BE.BusinessEntityID=c.PersonID
join Person.Address a on a.AddressID=BE.AddressID
/*
18.1 Create a recursive query to show the complete employee hierarchy,
including employee name,
manager name, hierarchy level, and path.
*/
with EmployeeHierarchy as (
select
concat(FirstName,' ',MiddleName,' ',LastName) EmployeeName,
null as managerName,
concat(p.FirstName, ' ', MiddleName, ' ', p.LastName) as Path
from HumanResources.Employee e join Person.Person p on e.BusinessEntityID = p.BusinessEntityID 
)
select * 
from EmployeeHierarchy

/*18.2 Create a query to compare year-over-year sales for each product,
showing product, sales for 2013, sales for 2014, growth percentage, 
and growth category.
*/
select p.Name ,
sum(case when year(orderdate)=2013 then ListPrice *OrderQty end )as "sales for 2013",
sum(case when year(orderdate)=2014 then ListPrice *OrderQty end )as "sales for 2014",
CAST((SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN listprice * sod.orderqty END) -
         SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN listprice * sod.orderqty END)) * 100.0 /
        NULLIF(SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN listprice * sod.orderqty END), 0)
    AS DECIMAL(5,2)) AS [Growth %],
    CASE
        WHEN 
            SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN listprice * sod.orderqty END) IS NULL
            THEN 'No Sales in 2013'
        WHEN 
            SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN listprice * sod.orderqty END) >
            SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN listprice * sod.orderqty END)
            THEN 'Increased'
        WHEN 
            SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN listprice * sod.orderqty END) <
            SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN listprice * sod.orderqty END)
            THEN 'Decreased'
        ELSE 'Same'
    END AS [Growth Category]
from Production.Product p join Sales.SalesOrderDetail sod on p.ProductID =sod.ProductID
join Sales.SalesOrderHeader soh on sod.SalesOrderID=soh.SalesOrderID 
where year(OrderDate) in(2013,2014)
group by p.Name

/*
19.1 Rank products by sales within each category, showing product name,
category, sales amount, rank, dense rank, and row number.
*/
select pc.ProductCategoryID as category_id,p.Name product_name,pc.Name category_name,
sum(UnitPrice*OrderQty) sales_amount ,
rank()over(PARTITION BY pc.ProductCategoryID order by sum(UnitPrice*OrderQty) desc) rank,
 dense_rank()over(PARTITION BY pc.ProductCategoryID order by sum(UnitPrice*OrderQty) desc) denrank,
  ROW_NUMBER()over(PARTITION BY pc.ProductCategoryID order by sum(UnitPrice*OrderQty) desc) rownum

from Production.Product p join Production.ProductSubcategory psc 
on p.ProductSubcategoryID = psc.ProductSubcategoryID join Production.ProductCategory pc
on psc.ProductCategoryID = pc.ProductCategoryID join Sales.SalesOrderDetail od 
on p.ProductID = od.ProductID
group by pc.ProductCategoryID ,p.Name,pc.Name

/*
19.2 Show the running total of sales by month for 2013,
displaying month, monthly sales, running total,and percentage of year-to-date.
*/
select 
month(OrderDate),sum(UnitPrice*OrderQty)
from sales.SalesOrderHeader oh join sales.SalesOrderDetail od
on oh.SalesOrderID = od.SalesOrderID
where year(OrderDate)=2013
group by month(OrderDate)



