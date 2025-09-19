# 📘 Data Dictionary

This document describes the database schema, columns, purposes, and quality checks.

---

## website_sessions

| Column Name        | Table            | Sample Data                      | Analytics Purpose & Relationship                          | Quality Check                  |
|--------------------|------------------|----------------------------------|-----------------------------------------------------------|--------------------------------|
| website_session_id | website_sessions | 1, 2, 3                          | Primary key; relates to `website_pageviews` and `orders`  | Unique, non-null               |
| created_at         | website_sessions | '2012-03-19 08:04:16'            | Used for time-based session analysis                      | Valid timestamp                 |
| user_id            | website_sessions | 1, 2, 3                          | Foreign key for user; links to orders                     | Integer, non-null               |
| is_repeat_session  | website_sessions | 0, 1                             | Identifies repeat visitors; engagement metric              | Boolean (0/1)                   |
| utm_source         | website_sessions | 'gsearch', 'bsearch'             | Tracks marketing channel; relates to campaign performance | Short strings                   |
| utm_campaign       | website_sessions | 'nonbrand'                       | Tracks specific campaigns                                 | Short strings                   |
| utm_content        | website_sessions | 'g_ad_1'                         | Differentiates ad content                                 | Short strings                   |
| device_type        | website_sessions | 'mobile', 'desktop'              | Device segmentation for analysis                          | Non-null, limited values         |
| http_referer       | website_sessions | 'https://www.gsearch.com'        | Tracks session sources                                    | Valid URLs                      |

---

## website_pageviews

| Column Name        | Table              | Sample Data        | Analytics Purpose & Relationship                         | Quality Check          |
|--------------------|--------------------|--------------------|----------------------------------------------------------|------------------------|
| website_pageview_id| website_pageviews  | 1, 2, 3            | Primary key; identifies each pageview                    | Unique, non-null       |
| created_at         | website_pageviews  | '2012-03-19 08:04' | Time series pageview analysis                            | Valid timestamp        |
| website_session_id | website_pageviews  | 1, 2, 3            | Foreign key; relates views to sessions                   | Should exist in `website_sessions` |
| pageview_url       | website_pageviews  | '/home', '/cart'   | Tracks customer navigation; relates to checkout flow     | Non-null, valid paths  |

---

## products

| Column Name   | Table    | Sample Data       | Analytics Purpose & Relationship       | Quality Check        |
|---------------|----------|-------------------|----------------------------------------|----------------------|
| product_id    | products | 1, 2, 3           | Primary key; referenced by orders/items | Unique, non-null     |
| created_at    | products | '2012-03-19 08:00'| Product lifecycle analysis              | Valid timestamp      |
| product_name  | products | 'Product A'       | Used for product-level reporting        | Descriptive, non-null|

---

## orders

| Column Name        | Table  | Sample Data  | Analytics Purpose & Relationship                  | Quality Check            |
|--------------------|--------|--------------|---------------------------------------------------|--------------------------|
| order_id           | orders | 1, 2, 3      | Primary key; links to `order_items`, `refunds`    | Unique, non-null         |
| created_at         | orders | '2012-03-19' | Time series / RFM analysis                        | Valid timestamp          |
| website_session_id | orders | 20, 104      | Foreign key; links order to session               | Should exist in sessions |
| user_id            | orders | 20, 104      | Foreign key; useful for customer analysis         | Should exist in users    |
| primary_product_id | orders | 1, 2, 3      | Foreign key; main product sold                    | Should exist in products |
| items_purchased    | orders | 1, 2         | Number of items in order                          | Integer                  |
| price_usd          | orders | 49.99        | Revenue analysis                                  | Valid, non-negative      |
| cogs_usd           | orders | 19.49        | Profit margin analysis                            | Valid, non-negative      |

---

## order_items

| Column Name    | Table       | Sample Data | Analytics Purpose & Relationship  | Quality Check      |
|----------------|-------------|-------------|-----------------------------------|--------------------|
| order_item_id  | order_items | 1, 2, 3     | Primary key; identifies items per order | Unique, non-null |
| created_at     | order_items | '2012-03-19'| Order item lifecycle analysis      | Valid timestamp    |
| order_id       | order_items | 1, 2, 3     | Foreign key; links item to order   | Should exist in orders |
| product_id     | order_items | 1, 2, 3     | Foreign key; product in item       | Should exist in products |
| is_primary_item| order_items | 0, 1        | Flags if item is main product      | Boolean (0/1)      |
| price_usd      | order_items | 49.99       | Item-level revenue                 | Positive number    |
| cogs_usd       | order_items | 19.49       | Item-level cost                    | Positive number    |

---

## order_item_refunds

| Column Name        | Table               | Sample Data | Analytics Purpose & Relationship         | Quality Check        |
|--------------------|---------------------|-------------|------------------------------------------|----------------------|
| order_item_refund_id| order_item_refunds | 1, 2, 3     | Primary key; tracks refunds               | Unique, non-null     |
| created_at         | order_item_refunds | '2012-04-06'| Refund analysis, time series              | Valid timestamp      |
| order_item_id      | order_item_refunds | 57, 74, 71  | Foreign key; refund relates to item       | Should exist in items|
| order_id           | order_item_refunds | 57, 74, 71  | Cross-check with order                    | Should exist in orders|
| refund_amount_usd  | order_item_refunds | 49.99       | Financial loss tracking                   | Positive number      |
