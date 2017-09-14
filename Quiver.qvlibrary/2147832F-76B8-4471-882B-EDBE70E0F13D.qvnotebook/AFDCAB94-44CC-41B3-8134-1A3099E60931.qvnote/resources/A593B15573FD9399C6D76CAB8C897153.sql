-- 4_4.sql

-- 申请 笔数，总额
select city_amount.city_id, city_amount.name, count(1), sum(city_amount.apply_amount)
from (select distinct tla.id, tla.city_id, tc.name, tla.apply_amount
		from t_loan_apply tla
			inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
			inner join t_city tc on tc.id = tla.city_id
		where 
			tla.apply_source = 1 -- 1 新房 2 二手
			and tla.product_type = 1
			and tla.created_time > '2016-06-13 00:00:00'
			and tla.created_time < '2016-06-13 23:59:59') as city_amount
group by city_amount.city_id;

-- 提单 笔数，总额
select city_amount.city_id, city_amount.name, count(1), sum(city_amount.apply_amount)
from (select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
		from t_loan_apply tla
			inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
			inner join t_city tc on tc.id = tla.city_id
			inner join t_approve_log tal on tal.loan_apply_id = tlo.id
		where tla.product_type = 1
			and tla.apply_source = 1 -- 1 新房 2 二手
			and tal.to_node_id = 1 -- 订单确认
			and tal.approve_time > '2016-06-13 00:00:00'
			and tal.approve_time < '2016-06-13 23:59:59') as city_amount
group by city_amount.city_id;

select * from (
	select city_amount.city_id, city_amount.name, count(1) as total, sum(city_amount.apply_amount)
	from (select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
			from t_loan_apply tla
				inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
				inner join t_city tc on tc.id = tla.city_id
				inner join t_approve_log tal on tal.loan_apply_id = tlo.id
			where tla.product_type = 1
				and tla.apply_source = 1 -- 1 新房 2 二手
				and tal.node_id = 0 -- 订单确认
				and tal.approve_time > '2016-06-05 00:00:00'
				and tal.approve_time < '2016-06-13 23:59:59') as city_amount
	group by city_amount.city_id) as total_city_amount
left join (
select pass_city_amount.city_id, pass_city_amount.name, count(1) as pass, sum(pass_city_amount.apply_amount)
from (select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
		from t_loan_apply tla
			inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
			inner join t_city tc on tc.id = tla.city_id
			inner join t_approve_log tal on tal.loan_apply_id = tlo.id
		where tla.product_type = 1
			and tla.apply_source = 1 -- 1 新房 2 二手
			and tal.to_node_id = 1 -- 订单确认
			and tal.approve_time > '2016-06-05 00:00:00'
			and tal.approve_time < '2016-06-13 23:59:59') as pass_city_amount
group by pass_city_amount.city_id) as pass_total_city_amount on total_city_amount.city_id = pass_total_city_amount.city_id;

-- 审批 笔数，总额
select city_amount.city_id, city_amount.name, count(1), sum(city_amount.loan_amount)
from (select distinct tlo.id, tla.city_id, tc.name, tlo.loan_amount
	  from t_loan_apply tla
		  inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
		  inner join t_city tc on tc.id = tla.city_id
		  inner join t_approve_log tal on tal.loan_apply_id = tlo.id
	  where tla.product_type = 1
	      and tla.apply_source = 1 -- 1 新房 2 二手
		  and tal.to_node_id = 7 -- 面签
		  and tal.approve_time > '2016-06-13 00:00:00'
		  and tal.approve_time < '2016-06-13 23:59:59') as city_amount
group by city_amount.city_id;

-- 面签 笔数，总额
select city_amount.city_id, city_amount.name, count(1), sum(city_amount.loan_amount)
from (select distinct tlo.id, tla.city_id, tc.name, tlo.loan_amount
		from t_loan_apply tla
			inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
			inner join t_city tc on tc.id = tla.city_id
			inner join t_approve_log tal on tal.loan_apply_id = tlo.id
		where tla.product_type = 1
			and tla.apply_source = 1 -- 1 新房 2 二手
			and tal.to_node_id = 8 -- 1 订单确认
			and tal.approve_time > '2016-06-13 00:00:00'
			and tal.approve_time < '2016-06-13 23:59:59') as city_amount
group by city_amount.city_id;

-- 放款 笔数，总额
select city_amount.city_id, city_amount.name, count(1), sum(city_amount.lend_amount)
from (select distinct tlo.id, tla.city_id, tc.name, td.lend_amount
		from t_loan_apply tla
			inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
			inner join t_debit td on td.loan_order_id = tlo.id
			inner join t_city tc on tc.id = tla.city_id
			inner join t_approve_log tal on tal.loan_apply_id = tlo.id
		where tla.product_type = 1
			and tla.apply_source = 1 -- 1 新房 2 二手
			and tal.to_node_id = 10 -- 放款
			and tal.approve_time > '2016-06-13 00:00:00'
			and tal.approve_time < '2016-06-13 23:59:59') as city_amount
group by city_amount.city_id;