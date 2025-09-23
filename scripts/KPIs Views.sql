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
=======
use depiecommerce;
-- select * from orders;
-- -- where primary_product_id !=1 ;
-- select * from order_item_refunds;
select * from website_sessions;


-- 1. Traffic & Engagement
-- ●	Website Traffic (count).
SELECT 
    COUNT(website_session_id) AS total_sessions
FROM website_sessions;

-- ●	Sessions for Unique users = 394,318
SELECT 
    COUNT(DISTINCT  user_id) AS unique_users
FROM website_sessions;
-- Sessions count per user 
-- kol unique user 3mal kam session 
SELECT 
    user_id,
    COUNT(website_session_id) AS sessions_per_user
FROM website_sessions
GROUP BY user_id
ORDER BY sessions_per_user ; 
-- اhow many users made sessions with signup and how many did not sign up (y3ny fy session id bs user id null )
-- in conclusion, all users are signed up 
SELECT 
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS sessions_without_user,
    SUM(CASE WHEN user_id IS NOT NULL THEN 1 ELSE 0 END) AS sessions_with_user
FROM website_sessions;


-- ●	Daily/Hourly Traffic → group website_sessions.created_at by day/hour.
-- Daily Traffic
SELECT 
    DATE(created_at) AS day,
    COUNT(website_session_id) AS sessions
FROM website_sessions
GROUP BY DATE(created_at)
ORDER BY day;

-- Hourly Traffic
SELECT 
    DATE(created_at) AS day,
    HOUR(created_at) AS hour,
    COUNT(website_session_id) AS sessions
FROM website_sessions
GROUP BY DATE(created_at), HOUR(created_at)
ORDER BY day, hour;

-- ●	Top Pages, Entry Pages → website_pageviews.pageview_url; entry page = first pageview per session.
-- Top Pages aktar urls most viewed (top10)
-- in conclusion, aktar page bt get viewed hya l products and least 2 are /the-hudson-river-mini-bear, 2610 & /billing, 3617
SELECT 
    pageview_url,
    COUNT(*) AS views
FROM website_pageviews
GROUP BY pageview_url
ORDER BY views
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
