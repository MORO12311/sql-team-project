USE depiecommerce;

/*Orders & Revenue*/
CREATE VIEW total_orders AS
    SELECT 
        COUNT(order_id) AS total_orders
    FROM
        orders;
    
-- Revenue
CREATE VIEW revenue AS
    SELECT 
        SUM(price_usd) AS revenues
    FROM
        orders;
    
-- Net Revenue
CREATE VIEW Net_revenue AS
    SELECT 
        SUM(oi.price_usd) - SUM(oir.refund_amount_usd) AS net_revenue
    FROM
        order_items AS oi
            LEFT JOIN
        order_item_refunds AS oir ON oi.order_item_id = oir.order_item_id;
    
-- Gross Merchandise Value (GMV) 
CREATE VIEW GMV AS
    SELECT 
        SUM(price_usd) AS volume_of_transactions
    FROM
        order_items;
    
    -- Average Order Value (AOV) 
CREATE VIEW Average_order_value AS
    SELECT 
        SUM(price_usd) / COUNT(order_id) AS Average_Order_Value
    FROM
        orders;
    
-- Gross Margin 
CREATE VIEW Gross_margin AS
    SELECT 
        CONCAT(ROUND(((SUM(price_usd) - SUM(cogs_usd)) / SUM(price_usd)) * 100,
                        2),
                '%') AS gross_margin
    FROM
        orders;
    
-- Refund/Return Rate by orders
CREATE VIEW return_rate_by_orders AS
SELECT 
    ROUND(COUNT(DISTINCT (oir.order_id)) / COUNT(DISTINCT (o.order_id)) * 100,
            3) AS Return_rate_by_orders
FROM
    orders AS o
        LEFT JOIN
    order_item_refunds AS oir ON o.order_id = oir.order_id
    
-- Refund/Return Rate by Value
CREATE VIEW return_rate_by_value AS
SELECT
CONCAT( 
    ROUND(
        (SUM(oir.refund_amount_usd) * 1.0 / SUM(o.price_usd)) * 100,
    2),'%' )AS return_rate_value
FROM orders o
LEFT JOIN order_item_refunds as oir
    ON o.order_id = oir.order_id
    
-- Refund Rates by Product
CREATE VIEW return_rate_by_products AS
SELECT 
    p.product_id,
    p.product_name,
    COUNT(DISTINCT oir.order_item_id) AS returned_items,
    COUNT(DISTINCT oi.order_item_id) AS total_items_sold,
    CONCAT(
    ROUND(
        (COUNT(DISTINCT oir.order_item_id) * 1.0 / COUNT(DISTINCT oi.order_item_id)) * 100,
        2
    ) ,'%') AS return_rate_percent
FROM products AS p
LEFT JOIN order_items AS oi 
    ON p.product_id = oi.product_id
LEFT JOIN order_item_refunds AS oir
    ON oi.order_item_id = oir.order_item_id
GROUP BY p.product_id, p.product_name
ORDER BY return_rate_percent DESC

-- orders by product 'no of orders that has the product'
CREATE VIEW orders_by_product AS
SELECT 
    p.product_id,
    p.product_name,
    COUNT(DISTINCT oi.order_id) AS number_of_orders
FROM
    products AS p
        LEFT JOIN
    order_items AS oi ON oi.product_id = p.product_id
GROUP BY p.product_id , p.product_name

-- Revenue by product
CREATE VIEW Rev_by_product AS
    SELECT 
        p.product_id,
        p.product_name,
        SUM(oi.price_usd) AS Revenues_usd
    FROM
        products AS p
            LEFT JOIN
        order_items AS oi ON p.product_id = oi.product_id
    GROUP BY p.product_id , p.product_name
    
 -- Revenue by margin  
create view rev_by_margin as
    SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.price_usd - oi.cogs_usd) AS margin_usd
FROM products p
JOIN order_items oi 
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name

-- Product Portfolio Impact 
create view Product_Portfolio_Impact as
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.price_usd) AS revenue_usd,
   CONCAT(
		ROUND( (SUM(oi.price_usd) * 100.0) / SUM(SUM(oi.price_usd)) OVER(), 2) ,'%') AS contribution_percent
FROM products p
JOIN order_items oi 
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue_usd DESC








    
    


