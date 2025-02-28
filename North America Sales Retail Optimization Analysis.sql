SELECT * FROM [Sales Retail]

--To Create a DimCustomer table from the Sales Retail Table
SELECT * INTO DimCustomer
FROM
(SELECT Customer_ID,Customer_Name FROM [Sales Retail])
AS DimC

WITH CTE_DimC
AS
(SELECT Customer_ID,Customer_Name,ROW_NUMBER() OVER (PARTITION BY Customer_ID,Customer_Name ORDER BY Customer_ID ASC) AS RowNumber
FROM DimCustomer)

DELETE FROM CTE_DimC
WHERE RowNumber>1 -- To remove duplicates from DimCustomer Table

SELECT * FROM DimCustomer

--To Create a DimLocation table from the Sales Retail Table
SELECT * INTO DimLocation
FROM 
    (SELECT Postal_Code, Country, City, State,Region 
	FROM [Sales Retail]
	)
AS DimL

SELECT * FROM DimLocation

WITH CTE_DimL
AS
  (SELECT Postal_Code,Country,City,State,Region,ROW_NUMBER() OVER (PARTITION BY Postal_Code,Country,City,State,Region ORDER BY Postal_Code ASC)AS RowNumber 
  FROM DimLocation
  )
  DELETE FROM CTE_DimL
  WHERE RowNumber > 1 -- To remove duplicates from DimLocation Table


--To Create a DimProduct table from the Sales Retail Table
SELECT * INTO DimProduct
FROM 
(SELECT Product_ID,Category,Sub_Category,Product_Name FROM [Sales Retail]
)
AS DimP

SELECT * FROM DimProduct

WITH CTE_DimP
AS
  (SELECT Product_ID,Category,Sub_Category,Product_Name,ROW_NUMBER() OVER (PARTITION BY Product_ID,Category,Sub_Category,Product_Name ORDER BY Product_ID ASC)AS RowNumber 
  FROM DimProduct
  )
  DELETE FROM CTE_DimP
  WHERE RowNumber > 1 -- To remove duplicates from DimProduct Table

  
  --To Create SalesFactTabe
  SELECT * INTO OrdersFactTable
  FROM 
  (SELECT Order_ID,Order_Date,Ship_Date,SHip_Mode,Customer_ID,Segment,Postal_Code,Retail_Sales_People,Product_ID,Returned,Sales,Quantity,Discount,Profit
  FROM [Sales Retail]
  )
  AS OrderFact

  SELECT * FROM OrdersFactTable


  WITH CTE_OrderFact
  AS
  (SELECT Order_ID,Order_Date,Ship_Date,SHip_Mode,Customer_ID,Segment,Postal_Code,Retail_Sales_People,Product_ID,Returned,Sales,Quantity,Discount,Profit
,ROW_NUMBER() OVER (PARTITION BY Order_ID,Order_Date,Ship_Date,SHip_Mode,Customer_ID,Segment,Postal_Code,Retail_Sales_People,Product_ID,Returned,Sales,Quantity,Discount,Profit
 ORDER BY Order_ID ASC)AS RowNumber 
  FROM OrdersFactTable)
  
  DELETE FROM CTE_OrderFact
  WHERE RowNumber > 1 -- To remove duplicates from OrdersFactTable

  SELECT * FROM OrdersFactTable

  SELECT * FROM DimProduct
  WHERE Product_ID='FUR-FU-10004091'

  -- To add a surrogate key called ProductKey to serve as the new identifier for the table DimProduct
  ALTER TABLE DimProduct
  ADD ProductKey INT IDENTITY(1,1) PRIMARY KEY

  --To add the ProductKey to the OrdersFactTable
  ALTER TABLE OrdersFactTable
  ADD ProductKey INT

  UPDATE OrdersFactTable
  SET ProductKey=DimProduct.ProductKey
  FROM OrdersFactTable
  JOIN DimProduct
  ON OrdersFactTable.Product_ID=DimProduct.Product_ID

  --To drop the Product_ID in the OrdersFactTable and DimProduct table
  ALTER TABLE DimProduct
  DROP COLUMN Product_ID

  ALTER TABLE OrdersFactTable
  DROP COLUMN Product_ID

  --To add a unique identifier to the OrdersFactTable
  ALTER TABLE OrdersFactTable
  ADD ROW_ID INT IDENTITY(1,1)


  --Exploratory Analysis
  --What is average delivery date for different Product SubCategory
  SELECT dp.Sub_Category, AVG(DATEDIFF(DAY,oft.Order_Date,oft.Ship_Date)) AS AvgDeliveryDays
  FROM OrdersFactTable AS oft
  LEFT JOIN DimProduct AS dp
  ON oft.ProductKey=dp.ProductKey
  GROUP BY dp.Sub_Category
/*It takes an average of 32 days to deliver products in the Chairs and Bookcases Sub_category
While it takes an average of 34 days and 36 days to deliver products in the Furnishings Sub_category 
and Tables Sub_Category respectively*/


--What was the average delivery days for each Segment?
SELECT * FROM OrdersFactTable
SELECT Segment,AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS AvgDeliveryDays
FROM OrdersFactTable
GROUP BY Segment
ORDER BY AvgDeliveryDays DESC
/*It takes an average of 35 days to get products to the corporate customer segment 
while it takes 34 and 31 days for consumer and home office respectively*/


--What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
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


--Which Product Sub_Category generate the most profit?
 SELECT dp.Sub_Category, ROUND(SUM(oft.Profit),2) AS TotalProfit 
  FROM OrdersFactTable AS oft
  LEFT JOIN DimProduct AS dp
  ON oft.ProductKey=dp.ProductKey
  WHERE oft.Profit > 0
  GROUP BY dp.Sub_Category
  ORDER BY TotalProfit DESC
/*The Sub_Category chairs generates the most profit with a total of $36471.1 
while tables generates the least profit*/


--Which segment generates the most profit?
SELECT Segment,ROUND(SUM(Profit),2) AS TotalProfit
FROM OrdersFactTable
WHERE Profit > 0
GROUP BY Segment
ORDER BY TotalProfit DESC
/*The Consumer customer generates the highest profit
while the home office generates the lowest profit*/


--Which top 5 customers made the most profit?
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


--What is the total number of product by sub_category?
SELECT Sub_Category, COUNT(DISTINCT Product_Name) AS TotalProduct
FROM DimProduct
GROUP BY Sub_Category
/* The total number of products for each Sub-Category is 48, 87, 184, 34 for Bookcases, Chairs, Furnishings, Tables respectively*/










