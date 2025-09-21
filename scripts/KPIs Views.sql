USE depiecommerce;



Create View rps_view as (
select ws.website_session_id, sum(o.price_usd) / count(ws.website_session_id) as rps
from orders as o 
inner join website_sessions as ws
on o.website_session_id = ws.website_session_id
group by ws.website_session_id
)

