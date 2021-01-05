libname c "C:\Users\tbruno\Documents\Business Reporting Tools\Chinook";

/***************************************************************************************************/
/*********************************FINANCE***********************************************************/
/***************************************************************************************************/
/************************/
/*** Question 1 *********/
/************************/
/***1***/
PROC SQL;
title 'Sales per months and years (1)';
SELECT distinct Month(Datepart(i.InvoiceDate)) as month, Year(Datepart(i.InvoiceDate)) as year,  
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2
FROM c.invoices i , c.invoice_items ii
WHERE i.invoiceid = ii.invoiceid
GROUP BY  2, 1;
QUIT;

PROC SQL;
title 'Average per months and years (1 bis)';
SELECT avg(sales)
FROM (SELECT distinct Month(Datepart(i.InvoiceDate)) as month, Year(Datepart(i.InvoiceDate)) as year,  
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2
FROM c.invoices i , c.invoice_items ii
WHERE i.invoiceid = ii.invoiceid
GROUP BY  2, 1);
QUIT;
/***2***/
PROC SQL;
title 'Sales per years (2)';
SELECT DISTINCT Year(Datepart(i.InvoiceDate)) as year,  
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2
FROM c.invoices i , c.invoice_items ii
WHERE i.invoiceid = ii.invoiceid
GROUP BY  1;
QUIT;
PROC SQL;
title 'Average sales per years (2 bis)';
SELECT avg(sales) 
FROM (SELECT DISTINCT Year(Datepart(i.InvoiceDate)) as year,  
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2
FROM c.invoices i , c.invoice_items ii
WHERE i.invoiceid = ii.invoiceid
GROUP BY  1);
QUIT;

/***3***/
PROC SQL;
title 'Sales per months (3)';
SELECT DISTINCT Month(Datepart(i.InvoiceDate)) as month,  
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2
FROM c.invoices i , c.invoice_items ii
WHERE i.invoiceid = ii.invoiceid
GROUP BY  1;
QUIT;
PROC SQL;
title 'Average sales per months (3 bis)';
SELECT avg(sales)
FROM (SELECT DISTINCT Month(Datepart(i.InvoiceDate)) as month,  
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2
FROM c.invoices i , c.invoice_items ii
WHERE i.invoiceid = ii.invoiceid
GROUP BY  1);
QUIT;

/***4***/
PROC SQL;
title 'Total Sales (4)';
SELECT SUM(UnitPrice*Quantity) as Sales format=dollar8.2
FROM c.invoice_items;
QUIT;

/*QUESTION 2 */
/***5***/
PROC SQL;
title 'Average Quantity per invoice (5)';
SELECT AVG(SumQuantity) as Average_Quantity_Per_Invoice 
FROM (SELECT SUM(quantity) as SumQuantity FROM c.invoice_items GROUP BY invoiceid) ;

QUIT;

PROC SQL;
title 'Average Sales per invoice (5 bis)';
SELECT AVG(Sumtotal) as Average_Sales_Per_Invoice format=dollar8.2
FROM (SELECT SUM(total) as Sumtotal FROM c.invoices GROUP BY invoiceid) ;

QUIT;



/* Finance supplementaire*/
/***6***/
PROC SQL; 
title 'Total number of tracks sold (6)';
SELECT SUM(quantity) as Number_of_Tracks_purchased 
FROM c.invoice_items;

QUIT;

/***7***/
PROC SQL;
title 'Average spending per Country (7)';
SELECT c.country, 
ROUND(SUM(i.total)/COUNT(i.invoiceid), 0.01) as Average_Sales_per_clients format=dollar8.2
FROM c.invoices i , c.customers c
WHERE i.customerid = c.customerid
GROUP BY 1
ORDER BY 2 DESC;
QUIT;

/***8***/
PROC SQL;
title 'Sales details per Country (8)';
SELECT c.country,
COUNT(DISTINCT c.customerid) as Customers,
COUNT(i.invoiceid) as Invoices,
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2, 
CATS(ROUND((SUM(ii.UnitPrice*ii.Quantity)/2240)*100,0.01), " % ")  as Percentage_on_global_Sales
FROM c.invoices i , c.invoice_items ii, c.customers c
WHERE i.invoiceid = ii.invoiceid
AND i.customerid = c.customerid
GROUP BY 1
ORDER BY 4 DESC;

QUIT;

/***9***/
PROC SQL;
title 'Number of customers (9)';
SELECT COUNT(customerid)
FROM c.customers;
QUIT;

/***************************************************************************************************/
/*********************************CUSTOMERS*********************************************************/
/***************************************************************************************************/

/*QUESTION 1***/
/***10***/
PROC SQL;
Title 'Type of Client (10)';
SELECT Location, COUNT(customerid) as Customers , ROUND((COUNT(customerid)/(SELECT COUNT(customerid)
FROM c.customers))*100,0.1) as Percentage
FROM (SELECT customerid, CASE WHEN company <> "NA" then "Company Client"
						else "Not Company Client" end as Location
	  FROM c.customers)
GROUP BY 1;
QUIT;

/*QUESTION 2***/
/***11***/
Proc sql; 
title 'Last Order Date Per Customer (11)';
SELECT c.CustomerID, max(i.invoicedate) format=datetime. as Last_Order,
CATS(ROUND(yrdif(datepart(MAX(i.invoiceDate)), today()),0.1)," years") as Recency,
COUNT( DISTINCT i.invoiceid) as Frequency, 
SUM(i.total) as Total_Spending format=dollar8.2,
ROUND(SUM(i.total)/COUNT(DISTINCT i.invoiceid),0.01) as Average_Spending
FROM c.customers c, c.invoices i
WHERE c.customerID = i.customerID
GROUP BY 1
ORDER BY 1;
Quit;


/**** QUESTION 3 *****/
/***12***/
PROC SQL;
title 'Time as Client in the company - Time between the first and last order (12)';
SELECT DISTINCT customerid,
CATS(ROUND(yrdif(datepart(MIN(i.invoiceDate)), today())-yrdif(datepart(MAX(i.invoiceDate)), today()),0.01)," years")as Time_as_Client
FROM c.invoices i
GROUP BY 1
ORDER BY 2 DESC ;
QUIT;

/***13***/
PROC SQL;
title 'Client average time (13)';
SELECT CATS(ROUND(AVG(Time_as_Client),0.01)," years") as Average_time_in_Company
FROM (SELECT DISTINCT customerid,
ROUND(yrdif(datepart(MIN(i.invoiceDate)), today())-yrdif(datepart(MAX(i.invoiceDate)), today()),0.01) as Time_as_Client
FROM c.invoices i
GROUP BY 1);
QUIT;

/**** QUESTION 4*****/
/***14***/
PROC SQL;
title 'Clients and Sales per Country (14)';
SELECT DISTINCT c.country, COUNT(DISTINCT c.customerid) as Clients, 
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2
FROM c.customers c, c.invoices i, c.invoice_items ii 
WHERE i.customerid = c.customerid
AND i.invoiceid = ii.invoiceid
GROUP BY 1
ORDER BY 2 DESC ;
QUIT;

/***15***/
PROC SQL;
title 'Region market details (15)';
SELECT Region, 
COUNT( DISTINCT c.country) as Countries, 
COUNT(DISTINCT c.customerid) as Customers, 
SUM(i.total) as Sales format=dollar8.2,
CATS(ROUND(SUM(i.total)/(SELECT SUM(total) FROM c.invoices),0.01)*100,"%") as Percentage_Sales
FROM c.customers c, c.invoices i, (SELECT c1.customerid, CASE WHEN country IN ("USA", "Canada")  then "North America"
							WHEN country IN ("Brazil", "Argentine", "Chile")  then "South America"
							WHEN country IN ("India", "Australia")  then "Asia/Oceania"
							else "Europe" end as Region
	  FROM c.customers c1)
WHERE i.customerid = c.customerid
AND c1.customerid = c.customerid 
GROUP BY 1
ORDER BY 3 DESC ;
QUIT;

/***************************************************************************************************/
/************************INTERNAL BUSINESS PROCESSES************************************************/
/***************************************************************************************************/

/**** QUESTION 1*****/
/***16**/
PROC SQL; 
title 'Sales per Genres (16)';
SELECT DISTINCT g.name, count(ii.invoiceLineid) as Purchases, 
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2,
CASE WHEN count(ii.invoiceLineid) > 200 then "High"
		when count(ii.invoiceLineid) > 60 then "Medium"
		else "Low" end as level
FROM c.genres g, c.tracks t, c.invoice_items ii
WHERE g.genreid = t.genreid
AND t.trackid = ii.trackid
GROUP BY 1
ORDER BY 2 DESC;
QUIT;

/***17***/
PROC SQL; 
title 'Genres summary (17)';
SELECT DISTINCT level, count(name) as Number_of_Genres, SUM(Sales) as Total_Sales format=dollar8.2, 
ROUND(SUM(Sales)/2328.6,0.1)*100 as Percentage
FROM (SELECT DISTINCT g.name, count(ii.invoiceLineid) as NumberofPurchases, 
SUM(ii.UnitPrice*ii.Quantity) as Sales, CASE WHEN count(ii.invoiceLineid) > 200 then "High"
		when count(ii.invoiceLineid) > 60 then "Medium"
		else "Low" end as level
FROM c.genres g, c.tracks t, c.invoice_items ii
WHERE g.genreid = t.genreid
AND t.trackid = ii.trackid
GROUP BY 1)
GROUP BY 1
ORDER BY CASE WHEN level = "High" THEN "1"
			  WHEN level = "Medium" THEN "2"
			  ELSE level END ASC;
QUIT;

/***18***/
PROC SQL;
title 'Tracks purchased (18)';
SELECT  Purchases, count(trackid) as Number
FROM (SELECT trackid, CASE WHEN count(trackid) = 2 THEN "2 times"
						 	 else "1 times" End as Purchases
		FROM c.invoice_items
		GROUP BY trackid)
GROUP BY 1;
QUIT;

/***19***/
PROC SQL; 
title 'Media types sales (19)';
SELECT DISTINCT m.name, COUNT(t.trackid) as Number_of_purchases, 
SUM(ii.unitprice*ii.quantity) as Sales format=dollar8.2,
CASE WHEN count(t.trackid) > 200 then "High"
WHEN count(t.trackid) > 60 then "Medium"
ELSE "Low" end as Level
FROM c.media_types m, c.tracks t, c.invoice_items ii
WHERE m.mediatypeid=t.mediatypeid
AND t.trackid = ii.trackid
GROUP BY 1
ORDER BY CASE WHEN level = "High" THEN "1"
			  WHEN level = "Medium" THEN "2"
			  ELSE level END ASC;
QUIT;


/**** QUESTION 2*****/
/***20***/
PROC SQL; /*****Methode 1 ******/
title 'Unused tracks and Storage (20)';
SELECT COUNT(DISTINCT t.trackid) as Tracks, CATS(SUM(t.bytes)/1000000000,"GB") as Possible_Stockage_Space
FROM c.tracks as t
WHERE t.trackid NOT IN (SELECT DISTINCT trackid FROM c.invoice_items);
QUIT;

PROC SQL; /*****Methode 2 ******/
title 'Unused tracks and Storage (20 bis)';
SELECT COUNT(trackid) 
FROM (SELECT t.trackid
FROM c.tracks t
EXCEPT
SELECT ii.trackid
FROM c.invoice_items ii);
QUIT;

/***************************************************************************************************/
/************************EMPLOYEES******************************************************************/
/***************************************************************************************************/

/**** QUESTION 1*****/
/***21***/
PROC SQL;
title 'Employee and Retirement (21)';
SELECT Retirement_Status, COUNT(employeeid) as Count
FROM (SELECT employeeid, 
		CASE WHEN yrdif(datepart(Birthdate), today()) > 60 then "Retirement soon"
		else "No retirement soon" end as Retirement_Status
		FROM c.employees)
GROUP BY 1;
QUIT;

/***22***/
PROC SQL;
title 'Employees (22)'; 
SELECT employeeid, LastName, Title,
CATS(ROUND(yrdif(datepart(Birthdate), today()),0.01)," years") as Age,
CATS(ROUND(yrdif(datepart(HireDate), today()),0.01)," years") as In_the_Company
FROM c.employees;
QUIT;

/**** QUESTION 2*****/
/***23***/
PROC SQL;
title 'Team details (23)';
SELECT DISTINCT title, COUNT(employeeid) as NumberofEmployee
FROM c.employees
GROUP BY 1;
QUIT;

/**** QUESTION 3*****/
/***24***/
PROC SQL;
title 'Sales per country and Sales Agent (24)';
SELECT c.country, e.employeeid, COUNT( DISTINCT i.invoiceid) as NumberofSales, 
SUM(ii.UnitPrice*ii.Quantity) as Sales format=dollar8.2
FROM c.invoices i, c.customers c, c.employees e, c.invoice_items ii
WHERE e.employeeid = c.supportRepid
AND i.customerid = c.customerid
AND i.invoiceid = ii.invoiceid
GROUP BY 2, 1
ORDER BY 1;
QUIT;

