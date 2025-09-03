-- =====================================================
-- IMPORT PROBLEMS HANDELING
-- =====================================================
UPDATE orders 
SET OrderDate = CASE 
    WHEN OrderDate IS NOT NULL AND OrderDate != '' AND OrderDate != 'NULL' 
    THEN STR_TO_DATE(OrderDate, '%d/%m/%y') 
    ELSE NULL 
END,
RequiredDate = CASE 
    WHEN RequiredDate IS NOT NULL AND RequiredDate != '' AND RequiredDate != 'NULL' 
    THEN STR_TO_DATE(RequiredDate, '%d/%m/%y') 
    ELSE NULL 
END,
ShippedDate = CASE 
    WHEN ShippedDate IS NOT NULL AND ShippedDate != '' AND ShippedDate != 'NULL' 
    THEN STR_TO_DATE(ShippedDate, '%d/%m/%y') 
    ELSE NULL 
END;

-- Customers table - Fixed version
UPDATE customers 
SET RegistrationDate = CASE 
    WHEN RegistrationDate IS NOT NULL AND RegistrationDate != '' AND RegistrationDate != 'NULL' 
    THEN STR_TO_DATE(RegistrationDate, '%d/%m/%y') 
    ELSE NULL 
END;

-- Shipments table - Fixed version
UPDATE shipments 
SET ShipDate = CASE 
    WHEN ShipDate IS NOT NULL AND ShipDate != '' AND ShipDate != 'NULL' 
    THEN STR_TO_DATE(ShipDate, '%d/%m/%y') 
    ELSE NULL 
END,
EstimatedDeliveryDate = CASE 
    WHEN EstimatedDeliveryDate IS NOT NULL AND EstimatedDeliveryDate != '' AND EstimatedDeliveryDate != 'NULL' 
    THEN STR_TO_DATE(EstimatedDeliveryDate, '%d/%m/%y') 
    ELSE NULL 
END,
ActualDeliveryDate = CASE 
    WHEN ActualDeliveryDate IS NOT NULL AND ActualDeliveryDate != '' AND ActualDeliveryDate != 'NULL' 
    THEN STR_TO_DATE(ActualDeliveryDate, '%d/%m/%y') 
    ELSE NULL 
END;

-- Production table - Fixed version
UPDATE production 
SET ProductionDate = CASE 
    WHEN ProductionDate IS NOT NULL AND ProductionDate != '' AND ProductionDate != 'NULL' 
    THEN STR_TO_DATE(ProductionDate, '%d/%m/%y') 
    ELSE NULL 
END;

-- Purchase Orders table - Fixed version
UPDATE purchase_orders 
SET OrderDate = CASE 
    WHEN OrderDate IS NOT NULL AND OrderDate != '' AND OrderDate != 'NULL' 
    THEN STR_TO_DATE(OrderDate, '%d/%m/%y') 
    ELSE NULL 
END,
ExpectedDeliveryDate = CASE 
    WHEN ExpectedDeliveryDate IS NOT NULL AND ExpectedDeliveryDate != '' AND ExpectedDeliveryDate != 'NULL' 
    THEN STR_TO_DATE(ExpectedDeliveryDate, '%d/%m/%y') 
    ELSE NULL 
END,
ActualDeliveryDate = CASE 
    WHEN ActualDeliveryDate IS NOT NULL AND ActualDeliveryDate != '' AND ActualDeliveryDate != 'NULL' 
    THEN STR_TO_DATE(ActualDeliveryDate, '%d/%m/%y') 
    ELSE NULL 
END;

-- Inventory table - Fixed version
UPDATE inventory 
SET LastStocktakeDate = CASE 
    WHEN LastStocktakeDate IS NOT NULL AND LastStocktakeDate != '' AND LastStocktakeDate != 'NULL' 
    THEN STR_TO_DATE(LastStocktakeDate, '%d/%m/%y') 
    ELSE NULL 
END;


-- =====================================================
-- 1. EFFICIENCY METRICS
-- =====================================================
-- 1.1 On-Time Delivery Rate by Carrier
SELECT 
    c.CarrierName,
    c.ServiceType,
    COUNT(*) as Total_Shipments,
    SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) as OnTime_Deliveries,
    ROUND((SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as OnTime_Delivery_Rate,
    ROUND(AVG(DATEDIFF(s.ActualDeliveryDate, s.ShipDate)), 2) as Avg_Delivery_Days
FROM shipments s
JOIN carriers c ON s.CarrierID = c.CarrierID
WHERE s.ActualDeliveryDate IS NOT NULL
GROUP BY c.CarrierID, c.CarrierName, c.ServiceType
ORDER BY OnTime_Delivery_Rate DESC;

-- 1.2 Order Fulfillment Cycle Time
SELECT 
    'Order Fulfillment Cycle Time' as KPI,
    ROUND(AVG(DATEDIFF(o.ShippedDate, o.OrderDate)), 2) as Avg_Days_Order_to_Ship,
    ROUND(AVG(DATEDIFF(s.ActualDeliveryDate, o.OrderDate)), 2) as Avg_Days_Order_to_Delivery,
    MIN(DATEDIFF(o.ShippedDate, o.OrderDate)) as Min_Days_to_Ship,
    MAX(DATEDIFF(o.ShippedDate, o.OrderDate)) as Max_Days_to_Ship
FROM orders o
LEFT JOIN shipments s ON o.OrderID = s.OrderID
WHERE o.ShippedDate IS NOT NULL;

-- 1.3 Order Fulfillment Cycle Time by Priority
SELECT 
    o.Priority,
    COUNT(*) as Order_Count,
    ROUND(AVG(DATEDIFF(o.ShippedDate, o.OrderDate)), 2) as Avg_Days_to_Ship,
    ROUND(AVG(DATEDIFF(s.ActualDeliveryDate, o.OrderDate)), 2) as Avg_Days_to_Delivery
FROM orders o
LEFT JOIN shipments s ON o.OrderID = s.OrderID
WHERE o.ShippedDate IS NOT NULL
GROUP BY o.Priority
ORDER BY 
    CASE o.Priority 
        WHEN 'Critical' THEN 1 
        WHEN 'High' THEN 2 
        WHEN 'Medium' THEN 3 
        WHEN 'Low' THEN 4 
    END;
    
-- =====================================================
-- 2. INVENTORY METRICS
-- =====================================================

-- 2.1 Inventory Turnover Ratio
WITH inventory_turnover AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        p.Category,
        SUM(ol.Quantity * ol.UnitPrice) as COGS_Estimate,
        AVG(i.InventoryValue) as Avg_Inventory_Value,
        CASE 
            WHEN AVG(i.InventoryValue) > 0 
            THEN ROUND(SUM(ol.Quantity * ol.UnitPrice) / AVG(i.InventoryValue), 2)
            ELSE 0 
        END as Inventory_Turnover_Ratio
    FROM products p
    LEFT JOIN order_lines ol ON p.ProductID = ol.ProductID
    LEFT JOIN orders o ON ol.OrderID = o.OrderID
    LEFT JOIN inventory i ON p.ProductID = i.ProductID
    WHERE o.OrderStatus = 'Delivered'
    GROUP BY p.ProductID, p.ProductName, p.Category
    HAVING AVG(i.InventoryValue) > 0
)
SELECT 
    Category,
    COUNT(*) as Product_Count,
    ROUND(AVG(Inventory_Turnover_Ratio), 2) as Avg_Inventory_Turnover,
    ROUND(MIN(Inventory_Turnover_Ratio), 2) as Min_Turnover,
    ROUND(MAX(Inventory_Turnover_Ratio), 2) as Max_Turnover
FROM inventory_turnover
GROUP BY Category
ORDER BY Avg_Inventory_Turnover DESC;

-- 2.2 Inventory Health by Warehouse
SELECT 
    w.WarehouseName,
    w.Location,
    COUNT(i.ProductID) as Products_Stocked,
    SUM(i.QuantityOnHand) as Total_Units,
    ROUND(SUM(i.InventoryValue), 2) as Total_Inventory_Value,
    SUM(CASE WHEN i.QuantityOnHand <= i.ReorderPoint THEN 1 ELSE 0 END) as Items_Below_Reorder,
    SUM(CASE WHEN i.QuantityOnHand = 0 THEN 1 ELSE 0 END) as Out_of_Stock_Items,
    ROUND(
        (SUM(CASE WHEN i.QuantityOnHand <= i.ReorderPoint THEN 1 ELSE 0 END) * 100.0 / COUNT(i.ProductID)), 2
    ) as Reorder_Alert_Rate,
    ROUND(
        (SUM(CASE WHEN i.QuantityOnHand = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(i.ProductID)), 2
    ) as Stockout_Rate
FROM warehouses w
JOIN inventory i ON w.WarehouseID = i.WarehouseID
GROUP BY w.WarehouseID, w.WarehouseName, w.Location
ORDER BY Total_Inventory_Value DESC;

-- 2.3 Days of Inventory Outstanding (DIO)
WITH daily_sales AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        p.Category,
        AVG(i.QuantityOnHand) as Avg_Inventory_Qty,
        SUM(ol.Quantity) / 365.0 as Daily_Sales_Qty
    FROM products p
    LEFT JOIN inventory i ON p.ProductID = i.ProductID
    LEFT JOIN order_lines ol ON p.ProductID = ol.ProductID
    LEFT JOIN orders o ON ol.OrderID = o.OrderID
    WHERE o.OrderStatus = 'Delivered'
      AND o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    GROUP BY p.ProductID, p.ProductName, p.Category
    HAVING Daily_Sales_Qty > 0
)
SELECT 
    Category,
    COUNT(*) as Product_Count,
    ROUND(AVG(Avg_Inventory_Qty / Daily_Sales_Qty), 1) as Avg_Days_Inventory_Outstanding,
    ROUND(MIN(Avg_Inventory_Qty / Daily_Sales_Qty), 1) as Min_DIO,
    ROUND(MAX(Avg_Inventory_Qty / Daily_Sales_Qty), 1) as Max_DIO
FROM daily_sales
GROUP BY Category
ORDER BY Avg_Days_Inventory_Outstanding;

-- =====================================================
-- 3. PRODUCTION EFFICIENCY METRICS
-- =====================================================

-- 3.1 Overall Equipment Effectiveness (OEE) Components
SELECT 
    DATE_FORMAT(ProductionDate, '%Y-%m') as Month,
    p.Category,
    -- Availability (assuming 8 hours = 480 minutes per shift)
    ROUND(AVG((480 - DowntimeMinutes) / 480 * 100), 2) as Availability_Percent,
    -- Performance (Actual vs Planned)
    ROUND(AVG(ActualQuantity / PlannedQuantity * 100), 2) as Performance_Percent,
    -- Quality (Good units / Total units)
    ROUND(AVG((ActualQuantity - QualityDefects) / ActualQuantity * 100), 2) as Quality_Percent,
    -- OEE Calculation
    ROUND(
        AVG((480 - DowntimeMinutes) / 480) * 
        AVG(ActualQuantity / PlannedQuantity) * 
        AVG((ActualQuantity - QualityDefects) / ActualQuantity) * 100, 2
    ) as OEE_Percent
FROM production pr
JOIN products p ON pr.ProductID = p.ProductID
WHERE pr.PlannedQuantity > 0 AND pr.ActualQuantity > 0
GROUP BY DATE_FORMAT(ProductionDate, '%Y-%m'), p.Category
ORDER BY Month DESC, OEE_Percent DESC;

-- 3.2 Production Attainment Rate
SELECT 
    'Production Attainment' as KPI,
    SUM(PlannedQuantity) as Total_Planned,
    SUM(ActualQuantity) as Total_Actual,
    ROUND((SUM(ActualQuantity) * 100.0 / SUM(PlannedQuantity)), 2) as Attainment_Rate,
    COUNT(*) as Production_Runs,
    SUM(QualityDefects) as Total_Defects,
    ROUND((SUM(QualityDefects) * 100.0 / SUM(ActualQuantity)), 2) as Defect_Rate
FROM production
WHERE PlannedQuantity > 0;

-- 3.3 Production Efficiency by Category
SELECT 
    p.Category,
    COUNT(*) as Production_Runs,
    SUM(pr.PlannedQuantity) as Total_Planned,
    SUM(pr.ActualQuantity) as Total_Actual,
    ROUND((SUM(pr.ActualQuantity) * 100.0 / SUM(pr.PlannedQuantity)), 2) as Attainment_Rate,
    ROUND(AVG(pr.DowntimeMinutes), 1) as Avg_Downtime_Minutes,
    SUM(pr.QualityDefects) as Total_Defects,
    ROUND((SUM(pr.QualityDefects) * 100.0 / SUM(pr.ActualQuantity)), 2) as Defect_Rate,
    ROUND(AVG(pr.ProductionCost / pr.ActualQuantity), 2) as Avg_Cost_Per_Unit
FROM production pr
JOIN products p ON pr.ProductID = p.ProductID
WHERE pr.PlannedQuantity > 0 AND pr.ActualQuantity > 0
GROUP BY p.Category
ORDER BY Attainment_Rate DESC;

-- =====================================================
-- 4. SUPPLIER PERFORMANCE METRICS
-- =====================================================

-- 4.1 Supplier Performance Scorecard
SELECT 
    s.SupplierName,
    s.Country,
    s.QualityRating,
    s.OnTimeDeliveryRate as Supplier_Reported_OTD,
    COUNT(po.PurchaseOrderID) as Total_Purchase_Orders,
    ROUND(AVG(po.TotalCost), 2) as Avg_PO_Value,
    SUM(po.TotalCost) as Total_Spend,
    -- Actual On-Time Delivery Performance
    ROUND(
        (SUM(CASE WHEN po.ActualDeliveryDate <= po.ExpectedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / 
         COUNT(CASE WHEN po.ActualDeliveryDate IS NOT NULL THEN 1 END)), 2
    ) as Actual_OTD_Rate,
    ROUND(AVG(DATEDIFF(po.ActualDeliveryDate, po.ExpectedDeliveryDate)), 1) as Avg_Delivery_Variance_Days,
    -- Performance Score (weighted average)
    ROUND(
        (s.QualityRating * 0.4 + 
         (SUM(CASE WHEN po.ActualDeliveryDate <= po.ExpectedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / 
          COUNT(CASE WHEN po.ActualDeliveryDate IS NOT NULL THEN 1 END)) / 20 * 0.6), 2
    ) as Performance_Score
FROM suppliers s
LEFT JOIN purchase_orders po ON s.SupplierID = po.SupplierID
GROUP BY s.SupplierID, s.SupplierName, s.Country, s.QualityRating, s.OnTimeDeliveryRate
HAVING COUNT(po.PurchaseOrderID) > 0
ORDER BY Performance_Score DESC;

-- 4.2 Supplier Lead Time Analysis
SELECT 
    s.SupplierName,
    s.LeadTime_Days as Promised_Lead_Time,
    COUNT(po.PurchaseOrderID) as Order_Count,
    ROUND(AVG(DATEDIFF(po.ActualDeliveryDate, po.OrderDate)), 1) as Actual_Avg_Lead_Time,
    ROUND(MIN(DATEDIFF(po.ActualDeliveryDate, po.OrderDate)), 1) as Min_Lead_Time,
    ROUND(MAX(DATEDIFF(po.ActualDeliveryDate, po.OrderDate)), 1) as Max_Lead_Time,
    ROUND(STDDEV(DATEDIFF(po.ActualDeliveryDate, po.OrderDate)), 1) as Lead_Time_Variability,
    ROUND(AVG(DATEDIFF(po.ActualDeliveryDate, po.OrderDate)) - s.LeadTime_Days, 1) as Lead_Time_Variance
FROM suppliers s
JOIN purchase_orders po ON s.SupplierID = po.SupplierID
WHERE po.ActualDeliveryDate IS NOT NULL
GROUP BY s.SupplierID, s.SupplierName, s.LeadTime_Days
ORDER BY Lead_Time_Variance;

-- =====================================================
-- 5. CUSTOMER ANALYTICS
-- =====================================================

-- 5.1 Customer Performance Analysis
SELECT 
    c.CustomerType,
    c.Region,
    COUNT(DISTINCT c.CustomerID) as Customer_Count,
    COUNT(o.OrderID) as Total_Orders,
    ROUND(SUM(o.OrderValue), 2) as Total_Revenue,
    ROUND(AVG(o.OrderValue), 2) as Avg_Order_Value,
    ROUND(SUM(o.OrderValue) / COUNT(DISTINCT c.CustomerID), 2) as Revenue,
    ROUND(SUM(o.OrderValue) / COUNT(DISTINCT c.CustomerID), 2) as Revenue_Per_Customer,
    ROUND(COUNT(o.OrderID) / COUNT(DISTINCT c.CustomerID), 2) as Orders_Per_Customer,
    -- Customer Satisfaction Metrics
    ROUND(
        (SUM(CASE WHEN o.OrderStatus = 'Delivered' THEN 1 ELSE 0 END) * 100.0 / COUNT(o.OrderID)), 2
    ) as Order_Completion_Rate
FROM customers c
LEFT JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerType, c.Region
ORDER BY Total_Revenue DESC;

-- 5.2 Top Customers by Revenue
SELECT 
    c.CustomerName,
    c.CustomerType,
    c.Region,
    c.Country,
    COUNT(o.OrderID) as Total_Orders,
    ROUND(SUM(o.OrderValue), 2) as Total_Revenue,
    ROUND(AVG(o.OrderValue), 2) as Avg_Order_Value,
    MIN(o.OrderDate) as First_Order_Date,
    MAX(o.OrderDate) as Last_Order_Date,
    DATEDIFF(MAX(o.OrderDate), MIN(o.OrderDate)) as Customer_Lifetime_Days,
    -- Customer Lifetime Value
    ROUND(SUM(o.OrderValue), 2) as Customer_Lifetime_Value,
    -- Recency (days since last order)
    DATEDIFF(CURDATE(), MAX(o.OrderDate)) as Days_Since_Last_Order
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderStatus IN ('Shipped', 'Delivered')
GROUP BY c.CustomerID, c.CustomerName, c.CustomerType, c.Region, c.Country
HAVING Total_Revenue > 0
ORDER BY Total_Revenue DESC
LIMIT 20;

-- 5.3 Customer Segmentation (RFM Analysis)
WITH customer_rfm AS (
    SELECT 
        c.CustomerID,
        c.CustomerName,
        c.CustomerType,
        -- Recency (days since last purchase)
        DATEDIFF(CURDATE(), MAX(o.OrderDate)) as Recency_Days,
        -- Frequency (number of orders)
        COUNT(o.OrderID) as Frequency,
        -- Monetary (total spend)
        SUM(o.OrderValue) as Monetary_Value
    FROM customers c
    JOIN orders o ON c.CustomerID = o.CustomerID
    WHERE o.OrderStatus IN ('Shipped', 'Delivered')
    GROUP BY c.CustomerID, c.CustomerName, c.CustomerType
),
rfm_scores AS (
    SELECT *,
        -- RFM Scoring (1-5 scale)
        CASE 
            WHEN Recency_Days <= 30 THEN 5
            WHEN Recency_Days <= 60 THEN 4
            WHEN Recency_Days <= 90 THEN 3
            WHEN Recency_Days <= 180 THEN 2
            ELSE 1
        END as R_Score,
        CASE 
            WHEN Frequency >= 20 THEN 5
            WHEN Frequency >= 15 THEN 4
            WHEN Frequency >= 10 THEN 3
            WHEN Frequency >= 5 THEN 2
            ELSE 1
        END as F_Score,
        CASE 
            WHEN Monetary_Value >= 50000 THEN 5
            WHEN Monetary_Value >= 25000 THEN 4
            WHEN Monetary_Value >= 10000 THEN 3
            WHEN Monetary_Value >= 5000 THEN 2
            ELSE 1
        END as M_Score
    FROM customer_rfm
)
SELECT 
    CASE 
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Loyal Customers'
        WHEN R_Score >= 3 AND F_Score <= 2 AND M_Score >= 3 THEN 'Potential Loyalists'
        WHEN R_Score >= 4 AND F_Score <= 2 AND M_Score <= 2 THEN 'New Customers'
        WHEN R_Score <= 2 AND F_Score >= 3 AND M_Score >= 3 THEN 'At Risk'
        WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 3 THEN 'Cannot Lose Them'
        ELSE 'Others'
    END as Customer_Segment,
    COUNT(*) as Customer_Count,
    ROUND(AVG(Monetary_Value), 2) as Avg_Revenue,
    ROUND(AVG(Frequency), 1) as Avg_Order_Frequency,
    ROUND(AVG(Recency_Days), 1) as Avg_Recency_Days
FROM rfm_scores
GROUP BY 
    CASE 
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Loyal Customers'
        WHEN R_Score >= 3 AND F_Score <= 2 AND M_Score >= 3 THEN 'Potential Loyalists'
        WHEN R_Score >= 4 AND F_Score <= 2 AND M_Score <= 2 THEN 'New Customers'
        WHEN R_Score <= 2 AND F_Score >= 3 AND M_Score >= 3 THEN 'At Risk'
        WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 3 THEN 'Cannot Lose Them'
        ELSE 'Others'
    END
ORDER BY Avg_Revenue DESC;

-- =====================================================
-- 6. FINANCIAL METRICS
-- =====================================================

-- 6.1 Revenue Analysis by Time Period
SELECT 
    DATE_FORMAT(o.OrderDate, '%Y-%m') as Month,
    COUNT(DISTINCT o.OrderID) as Total_Orders,
    COUNT(DISTINCT o.CustomerID) as Unique_Customers,
    ROUND(SUM(o.OrderValue), 2) as Total_Revenue,
    ROUND(AVG(o.OrderValue), 2) as Avg_Order_Value,
    -- Month-over-Month Growth
    ROUND(
        ((SUM(o.OrderValue) - LAG(SUM(o.OrderValue)) OVER (ORDER BY DATE_FORMAT(o.OrderDate, '%Y-%m'))) / 
         LAG(SUM(o.OrderValue)) OVER (ORDER BY DATE_FORMAT(o.OrderDate, '%Y-%m')) * 100), 2
    ) as Revenue_Growth_Rate
FROM orders o
WHERE o.OrderStatus IN ('Shipped', 'Delivered')
GROUP BY DATE_FORMAT(o.OrderDate, '%Y-%m')
ORDER BY Month;

-- 6.2 Profitability Analysis by Product Category
SELECT 
    p.Category,
    COUNT(DISTINCT ol.OrderID) as Orders_Count,
    SUM(ol.Quantity) as Total_Units_Sold,
    ROUND(SUM(ol.LineTotal), 2) as Total_Revenue,
    ROUND(SUM(ol.Quantity * p.UnitCost), 2) as Total_Cost,
    ROUND(SUM(ol.LineTotal) - SUM(ol.Quantity * p.UnitCost), 2) as Gross_Profit,
    ROUND(
        ((SUM(ol.LineTotal) - SUM(ol.Quantity * p.UnitCost)) / SUM(ol.LineTotal) * 100), 2
    ) as Gross_Margin_Percent,
    ROUND(AVG(ol.UnitPrice - p.UnitCost), 2) as Avg_Unit_Profit
FROM order_lines ol
JOIN products p ON ol.ProductID = p.ProductID
JOIN orders o ON ol.OrderID = o.OrderID
WHERE o.OrderStatus IN ('Shipped', 'Delivered')
GROUP BY p.Category
ORDER BY Gross_Profit DESC;

-- 6.3 Cost Analysis
SELECT 
    'Shipping Costs' as Cost_Category,
    ROUND(SUM(s.ShippingCost), 2) as Total_Cost,
    COUNT(*) as Transaction_Count,
    ROUND(AVG(s.ShippingCost), 2) as Avg_Cost_Per_Transaction
FROM shipments s
UNION ALL
SELECT 
    'Production Costs' as Cost_Category,
    ROUND(SUM(pr.ProductionCost), 2) as Total_Cost,
    COUNT(*) as Transaction_Count,
    ROUND(AVG(pr.ProductionCost), 2) as Avg_Cost_Per_Transaction
FROM production pr
UNION ALL
SELECT 
    'Purchase Order Costs' as Cost_Category,
    ROUND(SUM(po.TotalCost), 2) as Total_Cost,
    COUNT(*) as Transaction_Count,
    ROUND(AVG(po.TotalCost), 2) as Avg_Cost_Per_Transaction
FROM purchase_orders po;

-- =====================================================
-- 7. QUALITY METRICS
-- =====================================================

-- 7.1 First Time Right (FTR) Rate
SELECT 
    'First Time Right Rate' as KPI,
    COUNT(*) as Total_Orders,
    SUM(CASE WHEN o.OrderStatus = 'Delivered' THEN 1 ELSE 0 END) as Successful_Orders,
    SUM(CASE WHEN o.OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) as Cancelled_Orders,
    ROUND(
        (SUM(CASE WHEN o.OrderStatus = 'Delivered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2
    ) as First_Time_Right_Rate
FROM orders o;

