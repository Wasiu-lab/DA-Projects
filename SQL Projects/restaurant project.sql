use restaurant_db;

select * 
from order_details;

select *
from menu_items;

alter table menu_items
rename column ï»¿menu_item_id to menu_item_id;

alter table order_details
rename column ï»¿order_details_id to order_details_id;

select min(order_date), max(order_date)
from order_details;

select distinct count(menu_item_id)
from menu_items;

select *
from menu_items;

select item_name, price
from menu_items
where price = (
select min(price)
from menu_items
);

select item_name, price
from menu_items
where price = (
select max(price)
from menu_items
);

select distinct(count(category))
from menu_items
where category = 'italian';

select item_name, price
from menu_items
where category = 'italian'
order by 2 desc;

select category, count(item_name)
from menu_items
group by category;

select category, avg(price)
from menu_items
group by category;

select *
from order_details;

select min(order_date) as min_date, max(order_date) as max_date
from order_details;

select count(distinct order_id)
from order_details;

select count(order_details_id)
from order_details;

select order_id, count(item_id) as item_id_count
from order_details
group by order_id
order by 2 desc;

-- num of orders that have more than 12 items
select count(*)
from 
(select order_id, count(item_id) item_id_count
from order_details
group by order_id
having item_id_count > 12
order by 2 desc) as num;

select * 
from order_details;

select *
from menu_items;

select * 
from order_details od
join menu_items md
	on od.item_id =md.menu_item_id;

select item_name, category,count(item_name) as count_pur
from order_details od
join menu_items md
	on od.item_id =md.menu_item_id
group by item_name, category
order by count(item_name) desc;

-- order that were spent the most on 
select order_id, round(sum(price), 2) as total_sum_order
from order_details od
join menu_items md
	on od.item_id =md.menu_item_id
group by order_id
order by total_sum_order desc
limit 5;

select category, count(item_id) 
from order_details od
join menu_items md
	on od.item_id =md.menu_item_id
where order_id = 440
group by category;

select category, count(item_id) as num_item
from order_details od
join menu_items md
	on od.item_id =md.menu_item_id
where order_id in (440, 2075, 1957, 330, 2675)
group by category
order by num_item desc;

select item_name, count(item_id) as num_item
from order_details od
join menu_items md
	on od.item_id =md.menu_item_id
where order_id in (440, 2075, 1957, 330, 2675)
group by item_name
order by num_item desc;

select order_id, category, count(item_id) as num_item
from order_details od
join menu_items md
	on od.item_id =md.menu_item_id
where order_id in (440, 2075, 1957, 330, 2675)
group by order_id, category
order by order_id and num_item desc;









