--SQL Advance Case Study
SELECT TOP 1 * FROM DIM_CUSTOMER;
SELECT TOP 1 * FROM DIM_DATE;
SELECT TOP 1 * FROM DIM_LOCATION;
SELECT TOP 1 * FROM DIM_MANUFACTURER
SELECT TOP 1 * FROM DIM_MODEL;
SELECT TOP 1 * FROM FACT_TRANSACTIONS;

--Q1-- List all the states in which we have customers who have bought cellphones from 2005 till today.
	
select DISTINCT C.STATE
from fact_transactions AS A
inner join  dim_customer AS B ON A.IDCUSTOMER = B.IDCUSTOMER
INNER JOIN DIM_LOCATION AS C ON C.IDLOCATION = A.IDLOCATION
WHERE YEAR(A.DATE) >2005;

--Q1--END

--Q2--2. What state in the US is buying the most 'Samsung' cell phones?

	
select TOP 1 
D.STATE, COUNT(D.STATE) AS NO_OF_CUSTOMER
from DIM_MANUFACTURER AS A 
INNER JOIN  dim_model AS B  ON A.IDMANUFACTURER =B.IDMANUFACTURER
INNER JOIN  fact_transactions AS C ON  B.IDMODEL =C.IDMODEL
INNER JOIN DIM_LOCATION AS D ON D.IDLOCATION = C.IDLOCATION
WHERE COUNTRY = 'US'
AND A.MANUFACTURER_NAME ='SAMSUNG'
GROUP BY D.STATE;

--Q2--END

--Q3--Show the number of transactions for each model per zip code per state.

SELECT DISTINCT C.STATE, C.ZIPCODE,  B.MODEL_NAME,   COUNT(*) AS TransactionCount
from fact_transactions AS A
INNER JOIN dim_model AS B ON A.IDMODEL =B.IDMODEL
INNER JOIN  dim_location AS C ON A.IDLOCATION =C.IDLOCATION
GROUP BY C.STATE, C.ZIPCODE, B.MODEL_NAME;	


--Q3--END

--Q4-- Show the cheapest cellphone (Output should contain the price also)


select TOP 1 
 B.MANUFACTURER_NAME,  MODEL_NAME, UNIT_PRICE
from dim_model AS A
INNER JOIN DIM_MANUFACTURER AS B ON A.IDMANUFACTURER =  B.IDMANUFACTURER
ORDER BY UNIT_PRICE ASC ;



--Q4--END

--Q5-- Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price. 

WITH TOPSALES AS (
select A.Manufacturer_Name, B.Model_Name, C.TotalPrice, C.Quantity , C.TotalPrice* C.Quantity  AS TOTAL_SALES,
RANK () OVER( PARTITION BY (A.Manufacturer_Name) ORDER BY (C.TotalPrice* C.Quantity )) AS RANKK
from DIM_MANUFACTURER as A
INNER JOIN  dim_model AS B ON A.IDMANUFACTURER =B.IDMANUFACTURER
INNER JOIN  fact_transactions AS C ON B.IDMODEL =C.IDMODEL
WHERE 'RANKK' >= '5'
GROUP BY A.Manufacturer_Name, B.Model_Name, C.TotalPrice, C.Quantity
)
SELECT Manufacturer_Name, Model_Name, AVG(TOTAL_SALES) AS AVERAGE_PRICE
FROM TOPSALES
GROUP BY Manufacturer_Name, Model_Name
order by AVG(TOTAL_SALES)DESC ;


--Q5--END

--Q6--6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500

select IDCUSTOMER, count(idcustomer) AS NO_OF_ORDERS, SUM(TOTALPRICE) AS TOTA_SALES, sum(totalprice) / count(idcustomer) as average_amount_spent
FROM FACT_TRANSACTIONS 
WHERE [Date] > '2009-01-01'
GROUP BY IDCUSTOMER
HAVING  sum(totalprice) / count(idcustomer) > 500;


--Q6--END
	
--Q7--7. List if there is any model that was in the top 5 in terms of quantity,simultaneously in 2008, 2009 and 2010
WITH DATA2008 AS (
    SELECT TOP 5 B.IDMODEL, SUM(B.QUANTITY) AS TOTAL_QUANTITY
    FROM dim_model AS A
    INNER JOIN fact_transactions AS B ON B.IDMODEL = A.IDMODEL
    WHERE YEAR(B.DATE) = 2008
    GROUP BY B.IDMODEL
    ORDER BY TOTAL_QUANTITY DESC
), DATA2009 AS (
    SELECT TOP 5 B.IDMODEL, SUM(B.QUANTITY) AS TOTAL_QUANTITY
    FROM dim_model AS A
    INNER JOIN fact_transactions AS B ON B.IDMODEL = A.IDMODEL
    WHERE YEAR(B.DATE) = 2009
    GROUP BY B.IDMODEL
    ORDER BY TOTAL_QUANTITY DESC
), DATA2010 AS (
    SELECT TOP 5 B.IDMODEL, SUM(B.QUANTITY) AS TOTAL_QUANTITY
    FROM dim_model AS A
    INNER JOIN fact_transactions AS B ON B.IDMODEL = A.IDMODEL
    WHERE YEAR(B.DATE) = 2010
    GROUP BY B.IDMODEL
    ORDER BY TOTAL_QUANTITY DESC
)
SELECT A.IDMODEL
FROM DATA2008 AS A
INNER JOIN DATA2009 AS B ON A.IDMODEL = B.IDMODEL
INNER JOIN DATA2010 AS C ON A.IDMODEL = C.IDMODEL;

--Q7--END



--Q8--Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.


WITH TOPSALES AS 
(select A.Manufacturer_Name, YEAR(C.DATE) AS YEARS, SUM(C.TOTALPRICE) AS TOTAL_SALES,
RANK () OVER(PARTITION BY YEAR(C.DATE) ORDER BY SUM(C.TOTALPRICE) ) AS RANKK
FROM DIM_MANUFACTURER AS A
INNER JOIN  dim_model AS B ON A.IDManufacturer =B.IDManufacturer
INNER JOIN fact_transactions AS C ON C.IDModel =B.IDModel
WHERE YEAR(C.DATE) IN ( 2009, 2010)
GROUP BY A.Manufacturer_Name, YEAR(C.DATE)
)
SELECT Manufacturer_Name, YEARS, TOTAL_SALES, RANKK
FROM TOPSALES
WHERE YEARS IN (2009,2010)
GROUP BY Manufacturer_Name, YEARS, TOTAL_SALES, RANKK
HAVING RANKK = 2;


--Q8--END
--Q9--9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.

WITH TOPSALES AS 
(
select  A.Manufacturer_Name, C.TotalPrice, C.Quantity, 
MAX(CASE WHEN YEAR(C.DATE) = 2009 THEN 'Yes' ELSE 'No' END) AS SoldIn2009,
MAX(CASE WHEN YEAR(C.DATE) = 2010 THEN 'Yes' ELSE 'No' END) AS SoldIn2010
FROM DIM_MANUFACTURER AS A
INNER JOIN  dim_model AS B ON A.IDManufacturer =B.IDManufacturer
INNER JOIN fact_transactions AS C ON C.IDModel =B.IDModel
WHERE
YEAR(C.DATE) IN (2009, 2010)
GROUP BY
A.Manufacturer_Name, C.TotalPrice, C.Quantity
)
select Manufacturer_Name, SUM(Quantity) AS TOTAL_ITEM_SOLD
from TOPSALES
WHERE SOLDIN2009 = 'NO' AND SOLDIN2010 = 'YES'
GROUP BY Manufacturer_Name 
ORDER BY SUM(Quantity) DESC;
	










--Q9--END

--Q10--10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.


WITH CUSTOMER_SPEND AS
(
SELECT TOP 100 A.IDCustomer, A.Customer_Name,YEAR(B.Date) AS YEARS, SUM(TOTALPRICE) AS TotalSpend,
AVG(B.TotalPrice) AS Averagesales,     AVG(QUANTITY) AS AverageQuantity,
rank() OVER (PARTITION BY YEAR(B.DATE) ORDER BY SUM(TOTALPRICE)) AS RANKK
FROM dim_customer AS A 
INNER JOIN fact_transactions AS B ON A.IDCUSTOMER =B.IDCUSTOMER
GROUP BY A.IDCustomer, A.Customer_Name,YEAR(B.Date)
)
SELECT IDCUSTOMER, CUSTOMER_NAME, YEARS, TOTALSPEND, AVERAGESALES, AVERAGEQUANTITY, RANKK,
LAG(TotalSpend, 1, NULL) OVER (PARTITION BY IDCustomer ORDER BY YEARS) AS Perviousyearspend,
CASE 
WHEN   
LAG(TotalSpend, 1, NULL) OVER (PARTITION BY IDCustomer ORDER BY YEARS) = 0 THEN NULL
ELSE ((LAG(TotalSpend, 1, NULL) OVER (PARTITION BY IDCustomer ORDER BY YEARS)-TOTALSPEND)/ LAG(TotalSpend, 1, NULL) OVER (PARTITION BY IDCustomer ORDER BY YEARS) )*100
END AS percentage_change_in_spend
FROM CUSTOMER_SPEND
GROUP BY IDCUSTOMER, CUSTOMER_NAME, YEARS, TOTALSPEND, AVERAGESALES, AVERAGEQUANTITY, RANKK;


	


















--Q10--END
	