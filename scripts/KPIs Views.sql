USE depiecommerce;

-- 2. Marketing Performance KPIs

-- RPS KPI 
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
create view orders_source_view as (
select ws.utm_source, count(o.order_id), sum(o.price_usd)
FROM
        orders AS o
            INNER JOIN
        website_sessions AS ws ON o.website_session_id = ws.website_session_id
group by ws.utm_source
);

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
    (SELECT depth_count 
     FROM funnel_depth_count_view 
     WHERE pageview_url = '/thank-you-for-your-order') * 1.0
    /
    (SELECT SUM(depth_count) 
     FROM funnel_depth_count_view 
     WHERE pageview_url LIKE '/billing%') * 100
    AS conversion_rate;

select *
from funnel_conversion_view;
-- ----------------------------------------------------------------------------------------------------------------------------------------
