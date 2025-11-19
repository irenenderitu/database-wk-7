
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
