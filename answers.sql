-- Question 1 Achieving 1NF
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';

-- Recursive CTE to split comma-separated product list into separate rows
WITH RECURSIVE split_products AS (

    -- 1. Anchor part: select original row and extract first product
    SELECT
        OrderID,
        CustomerName,
        SUBSTRING_INDEX(Products, ',', 1) AS Product,              -- First product
        SUBSTRING(Products, LENGTH(SUBSTRING_INDEX(Products, ',', 1)) + 2) AS Remaining_Products
        -- Remaining string after removing the first product (skip comma + space)

    FROM ProductDetail

    UNION ALL

    -- 2. Recursive part: continue splitting Remaining_Products until empty
    SELECT
        OrderID,
        CustomerName,
        SUBSTRING_INDEX(Remaining_Products, ',', 1) AS Product,    -- Next product
        SUBSTRING(Remaining_Products, LENGTH(SUBSTRING_INDEX(Remaining_Products, ',', 1)) + 2)
        -- Update Remaining_Products by removing extracted product

    FROM split_products
    WHERE Remaining_Products <> ''                                -- Continue until no products left
)

-- Final output: each product as a separate row (1NF)
SELECT
    OrderID,
    CustomerName,
    TRIM(Product) AS Product                                        -- Clean spaces
FROM split_products;

-- Question 2 Achieving 2NF 

-- ============================================
-- Step 1: Create a new table 'Orders' to store
-- customer info without redundancy (2NF)
-- ============================================

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Insert DISTINCT OrderID and CustomerName
-- This removes the partial dependency from the original table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- ============================================
-- Step 2: Create OrderItems table to store
-- the products for each order (fully depends
-- on the composite key: OrderID + Product)
-- ============================================

CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),   -- Composite key
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert product-level data from the original table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- ============================================
-- The data is now in 2NF:
-- Orders: (OrderID → CustomerName)
-- OrderItems: (OrderID, Product → Quantity)
-- ============================================

