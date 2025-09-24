USE depiecommerce;

-- _________________________Manar________________________________
select * from website_sessions;
-- 1. Traffic & Engagement
-- ●	Website Traffic (count).
CREATE VIEW traffic_view AS
    (SELECT 
        COUNT(website_session_id) AS total_sessions
    FROM
        website_sessions);

-- ●	Sessions for Unique users = 394,318
CREATE VIEW uniqsession_view AS
    (SELECT 
        COUNT(DISTINCT user_id) AS unique_users
    FROM
        website_sessions);
-- Sessions count per user 
-- kol unique user 3mal kam session 
CREATE VIEW user_session_view AS
    (SELECT 
        user_id, COUNT(website_session_id) AS sessions_per_user
    FROM
        website_sessions
    GROUP BY user_id
    ORDER BY sessions_per_user); 
-- اhow many users made sessions with signup and how many did not sign up (y3ny fy session id bs user id null )
-- in conclusion, all users are signed up 
CREATE VIEW usersignedup_view AS
    (SELECT 
        COUNT(*) AS total_sessions,
        SUM(CASE
            WHEN user_id IS NULL THEN 1
            ELSE 0
        END) AS sessions_without_user,
        SUM(CASE
            WHEN user_id IS NOT NULL THEN 1
            ELSE 0
        END) AS sessions_with_user
    FROM
        website_sessions);

-- ●	Daily/Hourly Traffic → group website_sessions.created_at by day/hour.
-- Daily Traffic
CREATE VIEW dailytraf_view AS
    (SELECT 
        DATE(created_at) AS day,
        COUNT(website_session_id) AS sessions
    FROM
        website_sessions
    GROUP BY DATE(created_at)
    ORDER BY day);

-- Hourly Traffic
CREATE VIEW hourlytraf_view AS
    (SELECT 
        DATE(created_at) AS day,
        HOUR(created_at) AS hour,
        COUNT(website_session_id) AS sessions
    FROM
        website_sessions
    GROUP BY DATE(created_at) , HOUR(created_at)
    ORDER BY day , hour);

-- ●	Top Pages, Entry Pages → website_pageviews.pageview_url; entry page = first pageview per session.
-- Top Pages aktar urls most viewed (top10)
-- in conclusion, aktar page bt get viewed hya l products and least 2 are /the-hudson-river-mini-bear, 2610 & /billing, 3617
CREATE VIEW toppages_view AS
    (SELECT 
        pageview_url, COUNT(*) AS views
    FROM
        website_pageviews
    GROUP BY pageview_url
    ORDER BY views)
;
-- Entry Pages (first page per session)
-- ??????? 
WITH first_pages AS (
    SELECT 
        website_session_id,
        MIN(created_at) AS first_view
    FROM website_pageviews
    GROUP BY website_session_id
)
SELECT 
    wp.pageview_url,
    COUNT(*) AS entry_count
FROM website_pageviews wp
JOIN first_pages fp
    ON wp.website_session_id = fp.website_session_id
   AND wp.created_at = fp.first_view
GROUP BY wp.pageview_url
ORDER BY entry_count DESC
LIMIT 10;

-- How long a user stayed on your site in one visit
CREATE VIEW userstay_view AS
WITH session_times AS (
    SELECT 
        ws.user_id,
        ws.website_session_id,
        MIN(wp.created_at) AS session_start,
        MAX(wp.created_at) AS session_end
    FROM website_sessions ws
    JOIN website_pageviews wp 
        ON ws.website_session_id = wp.website_session_id
    GROUP BY ws.user_id, ws.website_session_id
),
session_durations AS (
    SELECT 
        user_id,
        website_session_id,
        TIMESTAMPDIFF(SECOND, session_start, session_end) AS session_duration_seconds
    FROM session_times
)
SELECT 
    user_id,
    ROUND(AVG(session_duration_seconds), 2) AS avg_session_duration_seconds,
    SUM(session_duration_seconds) AS total_time_seconds,
    COUNT(website_session_id) AS session_count
FROM session_durations
GROUP BY user_id
ORDER BY avg_session_duration_seconds DESC;

-- ●	Bounce Rate / Bounce Rates → sessions with only 1 pageview ÷ total sessions.
-- I recommend doing it by excel 
CREATE VIEW bounce_view AS
WITH session_views AS (
    SELECT 
        website_session_id,
        COUNT(*) AS pageviews_count
    FROM website_pageviews
    GROUP BY website_session_id
)
SELECT 
    ROUND(
        SUM(CASE WHEN pageviews_count = 1 THEN 1 ELSE 0 END) 
        / COUNT(*) * 100, 2
    ) AS bounce_rate_percentage
FROM session_views;
-- ●	Page Load Time → ❌ not available in schema.


>>>>>>> 814ce5f158bd71d82a7d156f489473342597d323


-- ----------------------------------------------------------------------------------------------------------------------------------------------------------
-- _______________________________________________Omar_____________________________________________________
-- 2. Marketing Performance KPIs

CREATE VIEW rps_view AS
    (SELECT 
        ws.website_session_id,
        SUM(o.price_usd) / COUNT(ws.website_session_id) AS rps
    FROM
        orders AS o
            INNER JOIN
        website_sessions AS ws ON o.website_session_id = ws.website_session_id
    GROUP BY ws.website_session_id);

-- Orders by Device and campaign

CREATE VIEW orders_device_view AS
    (SELECT 
        ws.device_type, COUNT(o.order_id) AS orders_count
    FROM
        orders AS o
            INNER JOIN
        website_sessions AS ws ON o.website_session_id = ws.website_session_id
    GROUP BY ws.device_type);
-- ------------------------------------
CREATE VIEW orders_campaign_view AS
    (SELECT 
        ws.utm_campaign,
        COUNT(o.order_id) AS orders_count,
        ROUND(SUM(o.price_usd), 0) AS campaign_revenue
    FROM
        orders AS o
            INNER JOIN
        website_sessions AS ws ON o.website_session_id = ws.website_session_id
    GROUP BY ws.utm_campaign);

-- Channel Diversification
CREATE VIEW orders_source_view AS
    (SELECT 
        ws.utm_source, COUNT(o.order_id), SUM(o.price_usd)
    FROM
        orders AS o
            INNER JOIN
        website_sessions AS ws ON o.website_session_id = ws.website_session_id
    GROUP BY ws.utm_source);

-- -------------------------------
-- Clickthrough from /products
CREATE VIEW product_funnel_ctr_view AS
WITH products_sessions AS (
    -- Sessions that viewed /products
    SELECT DISTINCT website_session_id
    FROM depiecommerce.website_pageviews
    WHERE pageview_url = '/products'
),
funnel_counts AS (
    SELECT 
        'Products' AS step,
        COUNT(DISTINCT ps.website_session_id) AS sessions
    FROM products_sessions ps
    
    UNION ALL
    
    SELECT 
        'Cart' AS step,
        COUNT(DISTINCT ps.website_session_id) AS sessions
    FROM products_sessions ps
    JOIN depiecommerce.website_pageviews wp 
        ON ps.website_session_id = wp.website_session_id
    WHERE wp.pageview_url = '/cart'
    
    UNION ALL
    
    SELECT 
        'Shipping' AS step,
        COUNT(DISTINCT ps.website_session_id) AS sessions
    FROM products_sessions ps
    JOIN depiecommerce.website_pageviews wp 
        ON ps.website_session_id = wp.website_session_id
    WHERE wp.pageview_url = '/shipping'
    
    UNION ALL
    
    SELECT 
        'Billing' AS step,
        COUNT(DISTINCT ps.website_session_id) AS sessions
    FROM products_sessions ps
    JOIN depiecommerce.website_pageviews wp 
        ON ps.website_session_id = wp.website_session_id
    WHERE wp.pageview_url LIKE '/billing%'
    
    UNION ALL
    
    SELECT 
        'Thank You' AS step,
        COUNT(DISTINCT ps.website_session_id) AS sessions
    FROM products_sessions ps
    JOIN depiecommerce.website_pageviews wp 
        ON ps.website_session_id = wp.website_session_id
    WHERE wp.pageview_url = '/thank-you-for-your-order'
)
SELECT 
    step,
    sessions,
    ROUND(100.0 * sessions / MAX(CASE WHEN step = 'Products' THEN sessions END) OVER (), 2) AS ctr_from_products,
    ROUND(
        100.0 * sessions 
        / LAG(sessions) OVER (ORDER BY CASE step 
                                          WHEN 'Products' THEN 1 
                                          WHEN 'Cart' THEN 2 
                                          WHEN 'Shipping' THEN 3 
                                          WHEN 'Billing' THEN 4 
                                          WHEN 'Thank You' THEN 5 END
                             ), 2
    ) AS ctr_from_previous
FROM funnel_counts;

<<<<<<< HEAD
-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 3. Conversion & Funnel KPIs
-- Conversion Rate (CVR)
create view cvr_view as (
-- Conversion Rate 
-- count(o.order_id) --> NULLs excluded (return orders number), count(*) --> return sessions number 
-- Each order must have a session but not vice versa 
SELECT 
    (SELECT COUNT(order_id) FROM orders) /
    (SELECT COUNT(website_session_id) FROM website_sessions) AS conversion_rate

-- ---------------------- OR using subquery
/* 
select count(o.order_id)/count(*) as conversion_rate
FROM
        website_sessions AS ws
           left JOIN
        orders as o ON ws.website_session_id = o.website_session_id ;
*/
);

-- Funnel Conversion % 
create view entry_pages_count_view as (
-- Including /home and /landing% pages 
SELECT pageview_url, COUNT(*) AS entry_pages_count
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY website_session_id ORDER BY created_at) AS funnel_depth
    FROM depiecommerce.website_pageviews
) f
WHERE funnel_depth = 1
GROUP BY pageview_url
ORDER BY entry_pages_count DESC
);

-- Users Number without duplicates
with cte_users_number as (
  select * 
  from (
      select *, 
        row_number() over (partition by user_id order by user_id) as unique_users 
      from website_sessions) d 
  where unique_users = 1
) 
select count(unique_users) 
from cte_users_number;

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- Depth counts (excluding home & lander pages)
CREATE VIEW funnel_depth_count_view AS
SELECT pageview_url, COUNT(*) AS depth_count
FROM (
    SELECT 
        wp.*, 
        ROW_NUMBER() OVER (PARTITION BY website_session_id ORDER BY created_at) AS funnel_depth
    FROM depiecommerce.website_pageviews wp
) f
WHERE funnel_depth > 1 -- exclude first pageviews (/home, /lander%)
GROUP BY pageview_url
ORDER BY depth_count DESC;


-- Funnel Conversion: Thank-you / Billing
CREATE VIEW funnel_conversion_view AS
    SELECT 
        (SELECT 
                depth_count
            FROM
                funnel_depth_count_view
            WHERE
                pageview_url = '/thank-you-for-your-order') * 1.0 / (SELECT 
                SUM(depth_count)
            FROM
                funnel_depth_count_view
            WHERE
                pageview_url LIKE '/billing%') * 100 AS conversion_rate;

SELECT 
    *
FROM
    funnel_conversion_view;
-- ----------------------------------------------------------------------------------------------------------------------------------------
-- _______________________________________________Nour_____________________________________________________
-- 3.Orders and Revenue
USE depiecommerce;

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
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------(((((((((FARIS)))))))))--------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

<<<<<<< HEAD


-- ----------------

=======
-- The year start from 2012-03-19 
-- We Need to calc just 2 period from 2012-03-19 to 2013-03-19 AND 2014-03-19 to 2015-03-19
CREATE VIEW CAGR_CALC AS 
WITH RECURSIVE first_last_period AS (
SELECT 
    DATE('2012-03-19') AS start_date,
    DATE('2013-03-19') AS end_date,
    1 AS rn
    -- rn stand for calc the row so by this way i give each row a number 1,2 or 3
UNION ALL SELECT 
    DATE_ADD(start_date, INTERVAL 1 YEAR),
    DATE_ADD(end_date, INTERVAL 1 YEAR),
    rn + 1
    -- now for each period have its own number first have 1 and second is 2 and third is 3
    FROM first_last_period
    WHERE end_date < '2015-03-19'
    ),
rev_period AS (
SELECT 
    CONCAT(start_date, ' --> ', end_date) AS period,
    ROUND(SUM(o.price_usd)) - ROUND(SUM(oif.refund_amount_usd)) AS net_rev
FROM
    first_last_period AS flp
        LEFT JOIN
    orders AS o ON o.created_at >= flp.start_date
        AND o.created_at <= flp.end_date
        INNER JOIN
    order_item_refunds AS oif ON oif.created_at >= flp.start_date
        AND oif.created_at <= flp.end_date
WHERE
    rn = 1
        OR rn = (SELECT 
            MAX(rn)
        FROM
            first_last_period)
GROUP BY period
)
-- We need to get the info to calc GAGR 
SELECT 
POWER(CAST(MAX(net_rev) AS FLOAT) / MIN(net_rev) , 1.0 / 3) -1 AS CAGR
-- cast is makeing the number float to make the result as float like 0.26 not 0 
FROM rev_period;
>>>>>>> b5ecc5c53a97ce0f2d9a9a86eabaf6b646ae2f04



    
    


