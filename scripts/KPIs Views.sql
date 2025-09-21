USE depiecommerce;



Create View rps_view as (
select ws.website_session_id, sum(o.price_usd) / count(ws.website_session_id) as rps
from orders as o 
inner join website_sessions as ws
on o.website_session_id = ws.website_session_id
group by ws.website_session_id
)

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

