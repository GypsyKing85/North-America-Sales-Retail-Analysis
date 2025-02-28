# North-America-Sales-Retail-Analysis


## Project Overview
Analysis of North America Retail Company sales data to uncover key insights on profitability, business performance, products, and customer behavior. The findings helped identify areas for improvement and suggest strategies to boost efficiency and profitability.

## Data Source
The dataset used is Retail-Supply-Chain-Sales-Analysis.CSV

## Tools Used
* SQL

## Data Cleaning and Preparation
1. Data Importation and Review
2. Splitting the data into facts and dimension Table and ERD creation

## Goals
1. What was the Average delivery days for different product subcategory?
2. What was the Average delivery days for each segment ?
3. What are the Top 5 Fastest delivered products and Top 5
slowest delivered products?
4. Which product Subcategory generate most profit?
5. Which segment generates the most profit?
6. Which Top 5 customers made the most profit?
7. What is the total number of products by Subcategory

## Data Analysis

### 1. What was the Average delivery days for different product subcategory?
```sql
SELECT dp.Sub_Category, AVG(DATEDIFF(DAY,oft.Order_Date,oft.Ship_Date)) AS AvgDeliveryDays
  FROM OrdersFactTable AS oft
  LEFT JOIN DimProduct AS dp
  ON oft.ProductKey=dp.ProductKey
  GROUP BY dp.Sub_Category
/*It takes an average of 32 days to deliver products in the Chairs and Bookcases Sub_category
While it takes an average of 34 days and 36 days to deliver products in the Furnishings Sub_category 
and Tables Sub_Category respectively*/
```

### 2. What was the Average delivery days for each segment?
```sql
SELECT * FROM OrdersFactTable
SELECT Segment,AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS AvgDeliveryDays
FROM OrdersFactTable
GROUP BY Segment
ORDER BY AvgDeliveryDays DESC
/*It takes an average of 35 days to get products to the corporate customer segment 
while it takes 34 and 31 days for consumer and home office respectively*/
```

### 3. What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
```sql
SELECT TOP 5(dp.Product_Name), DATEDIFF(DAY,oft.Order_Date,oft.Ship_Date) AS DeliveryDays
  FROM OrdersFactTable AS oft
  LEFT JOIN DimProduct AS dp
  ON oft.ProductKey=dp.ProductKey
  ORDER BY 2 ASC
/*The Top 5 Fastest delivered products with 0 delivery days are;
Sauder Camden County Barrister Bookcase, Planked Cherry Finish
Sauder Inglewood Library Bookcases
O'Sullivan 2-Shelf Heavy-Duty Bookcases
O'Sullivan Plantations 2-Door Library in Landvery Oak
O'Sullivan Plantations 2-Door Library in Landvery Oak*/

SELECT TOP 5(dp.Product_Name), DATEDIFF(DAY,oft.Order_Date,oft.Ship_Date) AS DeliveryDays
  FROM OrdersFactTable AS oft
  LEFT JOIN DimProduct AS dp
  ON oft.ProductKey=dp.ProductKey
  ORDER BY 2 DESC
/*Top 5 slowest delivered products with 214 delivery days are;
Bush Mission Pointe Library
Hon Multipurpose Stacking Arm Chairs
Global Ergonomic Managers Chair
Tensor Brushed Steel Torchiere Floor Lamp
Howard Miller 11-1/2" Diameter Brentwood Wall Clock*/
```

### 4. Which product Subcategory generate most profit?
```sql
SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS TotalProfit 
  FROM OrdersFactTable AS oft
  LEFT JOIN DimProduct AS dp
  ON oft.ProductKey=dp.ProductKey
  WHERE oft.Profit > 0
  GROUP BY dp.Sub_Category
  ORDER BY TotalProfit DESC
/*The Sub_Category chairs generates the most profit with a total of $36471.1 
while tables generates the least profit*/
```

### 5. Which segment generates the most profit?
```sql
SELECT Segment,ROUND(SUM(Profit),2) AS TotalProfit
FROM OrdersFactTable
WHERE Profit > 0
GROUP BY Segment
ORDER BY TotalProfit DESC
/*The Consumer customer generates the highest profit
while the home office generates the lowest profit*/
```

### 6. Which Top 5 customers made the most profit?
```sql
SELECT TOP 5 Customer_Name,ROUND(SUM(Profit),2) AS TotalProfit
FROM OrdersFactTable
LEFT JOIN DimCustomer
ON OrdersFactTable.Customer_ID=DimCustomer.Customer_ID
WHERE Profit > 0
GROUP BY Customer_Name
ORDER BY TotalProfit DESC
/*The top 5 customers generating the highest profit are;
Laura Armstrong
Joe Elijah
Seth Vernon
Quincy Jones
Maria Etezadi*/
```

### 7. What is the total number of products by Subcategory
```sql
SELECT Sub_Category, COUNT(DISTINCT Product_Name) AS TotalProduct
FROM DimProduct
GROUP BY Sub_Category
/* The total number of products for each Sub-Category is 48, 87, 184, 34 for Bookcases, Chairs, Furnishings, Tables respectively*/
```

## Insights/Findings







## Recommendation
