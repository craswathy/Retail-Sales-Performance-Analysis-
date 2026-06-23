drop database if exists superstore_db;
create database superstore_db;
use superstore_db;

create table superstore(
Row_ID INT,
Order_Date DATE,
Ship_Date DATE,
Ship_Mode VARCHAR(50),
Segment VARCHAR(50),
City VARCHAR(100),
Sate VARCHAR(100),
Region VARCHAR(50),
Category VARCHAR(100),
Sub_Category VARCHAR(100),
Product_Name VARCHAR(225),
Sales DECIMAL(10,2),
Quantity INT,
Discount DECIMAL(4,2),
Profit DECIMAL(10,2)
);

SELECT* FROM superstore LIMIT 10;

SELECT count(*) AS total_row,
min(Order_Date) AS erliest_order,
max(Order_Date) AS latest_order FROM superstore;

/* OVERALL KPIs- REVENUE,PROFIT,ORDERS */

SELECT 
ROUND(SUM(Sales),2)  AS total_revenue,
ROUND(SUM(Profit),2) AS total_Profit,
COUNT(*)             AS total_orders,
SUM(Quantity)        AS total_units,
ROUND(AVG(Sales),2)  AS avg_order_value,
ROUND(SUM(Profit)/SUM(Sales)*100,1) AS profit_margin_pct
FROM superstore;

/* GROUP BY -YEAR OVER -YEAR SALES */

SELECT  
YEAR(Order_Date)      AS year,
COUNT(*)              AS orders,
ROUND(SUM(Sales),2)   AS revenue,
ROUND(SUM(Profit),2)  AS profit,
ROUND(SUM(Profit)/SUM(sales)*100,1) AS margin_pct
FROM superstore
GROUP BY YEAR(Order_Date)
ORDER BY year;

/* YEAR-OVER-YEAR GROWTH % */

SELECT  year,revenue,
ROUND((revenue - LAG(revenue) OVER (ORDER BY year))
/ LAG (revenue) OVER (ORDER BY year)*100,1) AS growth_pct
FROM(
SELECT
    YEAR(Order_Date) AS year,
    ROUND(SUM(sales), 2) AS revenue
FROM superstore
GROUP BY YEAR(Order_Date)
) yearly
ORDER BY year;

/* CATEGORY AND REGION 
Sales and Profit by Category */

SELECT  Category,
ROUND(SUM(Sales),2) AS revenue,
ROUND(SUM(Profit),2) AS profit,
ROUND((SUM(Profit)/SUM(Sales))*100,1) AS margin_pct,
ROUND(SUM(Sales)/(SELECT SUM(Sales)FROM superstore)*100,1) AS pct_of_total
FROM superstore 
GROUP BY Category ORDER BY Revenue DESC;

/* Sub_Category ranking */

SELECT Sub_Category,Category,
ROUND(SUM(Sales),2) AS revenue,
ROUND(SUM(Profit),2) AS profit,
RANK() OVER (ORDER BY SUM(Sales)DESC) AS revenue_rank
FROM superstore 
GROUP BY Sub_Category,Category
ORDER BY revenue DESC;

/* Sales By Region */

SELECT Region,
ROUND(SUM(Sales),2) AS revenue,
ROUND(SUM(Profit),2) AS profit,
ROUND(SUM(Profit)/SUM(Sales)*100,1) AS profit_margin,
COUNT(*) AS Orders
FROM superstore
GROUP BY Region;

/* Top 5 products by revenue*/

SELECT Product_Name,Category,Sub_Category,
ROUND(SUM(Sales),2) AS revenue,
ROUND(SUM(Profit),2) AS profit,
SUM(Quantity) AS units_sold
FROM superstore
GROUP BY Product_Name,Category,Sub_Category
ORDER BY revenue DESC
LIMIT 5;

/* Loss making sub categories */

SELECT Sub_Category,
ROUND(SUM(Sales),2) AS revenue,
ROUND(SUM(Profit),2) AS profit
FROM superstore
GROUP BY Sub_Category
HAVING SUM(Profit)<0
ORDER BY profit ASC;

/* MONTHLY TREND */

SELECT  
YEAR(Order_Date) AS year,
MONTH(Order_Date) AS month_no,
MONTHNAME(Order_Date) AS month_name,
ROUND(SUM(Sales),2) AS revenue,
ROUND(SUM(Profit),2) AS profit,
COUNT(*) AS orders
FROM  superstore 
GROUP BY 
YEAR(Order_Date),MONTH(Order_Date),MONTHNAME(Order_Date)
ORDER BY year,month_no;

/* Best and Worst month ever */

SELECT 'best month' AS label,year,month_name,revenue
FROM(
 SELECT YEAR(Order_Date) AS year,
        MONTHNAME(Order_Date) AS month_name,
        ROUND(SUM(Sales),2) AS revenue
 FROM superstore
 GROUP BY YEAR(Order_Date), MONTH(Order_Date),
        MONTHNAME(Order_Date)
 ORDER BY revenue DESC LIMIT 1
 )best
 
 UNION ALL
 
 SELECT 'worst month',year,month_name,revenue
FROM(
 SELECT YEAR(Order_Date) AS year,
        MONTHNAME(Order_Date) AS month_name,
        ROUND(SUM(Sales),2) AS revenue
 FROM superstore
 GROUP BY YEAR(Order_Date), MONTH(Order_Date),
        MONTHNAME(Order_Date)
 ORDER BY revenue ASC LIMIT 1
 ) worst;
 
 /* Quarterly sales summary*/

 SELECT YEAR(Order_Date) AS year,
CASE
   WHEN MONTH(Order_Date) BETWEEN 1 AND 3 THEN'Q1'
   WHEN MONTH(Order_Date) BETWEEN 4 AND 6 THEN'Q2'
   WHEN MONTH(Order_Date) BETWEEN 7 AND 9 THEN'Q3'
   ELSE'Q4'
END   AS quarter,
ROUND(SUM(Sales),2) AS revenue,
ROUND(SUM(Profit),2) AS profit,
COUNT(*)  AS orders
FROM superstore
GROUP BY YEAR(Order_Date),quarter
ORDER BY year,quarter;

/* SEGMENT ANALYSIS 
Sales by customer segment */

SELECT Segment,
COUNT(*)              AS orders,
ROUND(SUM(Sales),2)   AS revenue,
ROUND(SUM(Profit),2)  AS profit,
ROUND(SUM(Profit)/SUM(sales)*100,1) AS margin_pct
FROM superstore
GROUP BY Segment 
ORDER BY revenue DESC;

/* Segment x category crossbar */
 SELECT Segment,
 ROUND(SUM(CASE WHEN Category='Technology' THEN Sales ELSE 0 END),2) AS technology,
 ROUND(SUM(CASE WHEN Category='Furniture'THEN Sales ELSE 0 END),2) AS furniture,
 ROUND(SUM(CASE WHEN Category='Office Supplies'THEN Sales ELSE 0 END),2)AS office_suppies,
 ROUND(SUM(Sales),2) AS total
 FROM superstore 
 GROUP BY Segment
 ORDER BY total DESC;
 
 /* Ship mode performance*/
 
 SELECT Ship_mode,
 COUNT(*) AS orders,
 ROUND(AVG(DATEDIFF(Ship_Date,Order_Date))) AS avg_days_to_ship,
 ROUND(SUM(Sales),2) AS revenue
 FROM superstore 
 GROUP BY Ship_mode
 ORDER BY avg_days_to_ship ASC;

/* DISCOUND ANALYSIS */

SELECT
  CASE 
   WHEN Discount=0 THEN 'No Discound'
   WHEN Discount <=0.10 THEN '1-10%'
   WHEN Discount <=0.20 THEN '11-20%'
   WHEN Discount <=0.30 THEN '21-30%'
   WHEN Discount <=0.50 THEN '31-50%'
   ELSE '51-80%'
END  AS discount_band,
COUNT(*)  AS orders,
ROUND(SUM(Sales),2)   AS revenue,
ROUND(SUM(Profit),2)  AS profit,
ROUND(SUM(Profit)/SUM(sales)*100,1) AS margin_pct
FROM superstore 
 GROUP BY discount_band
 ORDER BY MIN(Discount);
  
/* Does discount increase quantity? */

SELECT 
CASE
 WHEN discount=0 THEN 'No Discount'
 WHEN discount <=0.20 THEN 'Low (1-20%)'
 WHEN discount <=0.40 THEN'Medium (21-40%)'
 ELSE  'High(41%+)'
 END AS discount_level,
 ROUND(AVG(Quantity),1) AS avg_qty_sold,
 ROUND(AVG(Profit),2) AS avg_profit,
 COUNT(*) AS orders
 FROM superstore 
 GROUP BY discount_level
 ORDER BY MIN(discount);
 
 /* Orders with negative profit */
 
 SELECT
 Product_name,Category,discount,region,
 ROUND(sales,2) AS sales,
 ROUND(Profit,2) AS profit
 FROM superstore 
 WHERE Profit<0
 ORDER BY profit ASC
 LIMIT 10;