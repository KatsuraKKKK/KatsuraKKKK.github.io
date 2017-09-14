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
select total.cityId as cityId,
		total.cityName as cityName,
		total.totalCount as totalCount,
		total.totalAmount as totalAmount,
		pass.passCount as passCount,
		pass.passAmount as passAmount from (
	select city_amount.city_id as cityId, city_amount.name as cityName, count(1) as totalCount, sum(city_amount.apply_amount) as totalAmount
	from (select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
			from t_loan_apply tla
				inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
				inner join t_city tc on tc.id = tla.city_id
				inner join t_approve_log tal on tal.loan_apply_id = tlo.id
			where tla.product_type = 1
				and tla.apply_source = 1 
				and tal.node_id in (0)
				and tal.approve_time > '2016-06-05 00:00:00'
				and tal.approve_time < '2016-06-13 23:59:59') as city_amount
	group by city_amount.city_id
	) as total
left join (
select city_amount.city_id as cityId, count(1) as passCount, sum(city_amount.apply_amount) as passAmount
from (
	select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
		from t_loan_apply tla
			inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
			inner join t_city tc on tc.id = tla.city_id
			inner join t_approve_log tal on tal.loan_apply_id = tlo.id
		where tla.product_type = 1
			and tla.apply_source = 1 -- 1 新房 2 二手
			and tal.node_id in (0)
			and tal.to_node_id (1) -- 订单确认
			and tal.approve_time > '2016-06-05 00:00:00'
			and tal.approve_time < '2016-06-13 23:59:59'
		) as city_amount
group by city_amount.city_id) as pass on total.cityId = pass.cityId;

-- 审批 笔数，总额
select total.cityId as cityId,
		total.cityName as cityName,
		total.totalCount as totalCount,
		total.totalAmount as totalAmount,
		pass.passCount as passCount,
		pass.passAmount as passAmount from (
	select city_amount.city_id as cityId, city_amount.name as cityName, count(1) as totalCount, sum(city_amount.apply_amount) as totalAmount
	from (select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
			from t_loan_apply tla
				inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
				inner join t_city tc on tc.id = tla.city_id
				inner join t_approve_log tal on tal.loan_apply_id = tlo.id
			where tla.product_type = 1
				and tla.apply_source = 1 
				and tal.node_id in (3, 4, 5, 6)
				and tal.approve_time > '2016-06-05 00:00:00'
				and tal.approve_time < '2016-06-13 23:59:59') as city_amount
	group by city_amount.city_id
	) as total
left join (
select city_amount.city_id as cityId, count(1) as passCount, sum(city_amount.apply_amount) as passAmount
from (
	select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
		from t_loan_apply tla
			inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
			inner join t_city tc on tc.id = tla.city_id
			inner join t_approve_log tal on tal.loan_apply_id = tlo.id
		where tla.product_type = 1
			and tla.apply_source = 1 -- 1 新房 2 二手
			and tal.node_id in (3, 4, 5, 6)
			and tal.to_node_id in (7)
			and tal.approve_time > '2016-06-05 00:00:00'
			and tal.approve_time < '2016-06-13 23:59:59'
		) as city_amount
group by city_amount.city_id) as pass on total.cityId = pass.cityId;

-- 面签 笔数，总额
select total.cityId as cityId,
		total.cityName as cityName,
		total.totalCount as totalCount,
		total.totalAmount as totalAmount,
		pass.passCount as passCount,
		pass.passAmount as passAmount from (
	select city_amount.city_id as cityId, city_amount.name as cityName, count(1) as totalCount, sum(city_amount.apply_amount) as totalAmount
	from (select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
			from t_loan_apply tla
				inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
				inner join t_city tc on tc.id = tla.city_id
				inner join t_approve_log tal on tal.loan_apply_id = tlo.id
			where tla.product_type = 1
				and tla.apply_source = 1 
				and tal.node_id in (7)
				and tal.approve_time > '2016-06-05 00:00:00'
				and tal.approve_time < '2016-06-13 23:59:59') as city_amount
	group by city_amount.city_id
	) as total
left join (
select city_amount.city_id as cityId, count(1) as passCount, sum(city_amount.apply_amount) as passAmount
from (
	select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
		from t_loan_apply tla
			inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
			inner join t_city tc on tc.id = tla.city_id
			inner join t_approve_log tal on tal.loan_apply_id = tlo.id
		where tla.product_type = 1
			and tla.apply_source = 1 -- 1 新房 2 二手
			and tal.node_id in (7)
			and tal.to_node_id in (8)
			and tal.approve_time > '2016-06-05 00:00:00'
			and tal.approve_time < '2016-06-13 23:59:59'
		) as city_amount
group by city_amount.city_id) as pass on total.cityId = pass.cityId;

-- 放款 笔数，总额
select total.cityId as cityId,
		total.cityName as cityName,
		total.totalCount as totalCount,
		total.totalAmount as totalAmount,
		pass.passCount as passCount,
		pass.passAmount as passAmount from (
	select city_amount.city_id as cityId, city_amount.name as cityName, count(1) as totalCount, sum(city_amount.lend_amount) as totalAmount
	from (select distinct tlo.id, tla.city_id, tc.name, td.lend_amount
			from t_loan_apply tla
              inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
              inner join t_debit td on td.loan_order_id = tlo.id
              inner join t_city tc on tc.id = tla.city_id
              inner join t_approve_log tal on tal.loan_apply_id = tlo.id
			where tla.product_type = 1
				and tla.apply_source = 1 
				and tal.node_id in (8,9)
				and tal.approve_time > '2016-06-05 00:00:00'
				and tal.approve_time < '2016-06-13 23:59:59') as city_amount
	group by city_amount.city_id
	) as total
left join (
select city_amount.city_id as cityId, count(1) as passCount, sum(city_amount.lend_amount) as passAmount
from (
	select distinct tlo.id, tla.city_id, tc.name, td.lend_amount
		   from t_loan_apply tla
              inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
              inner join t_debit td on td.loan_order_id = tlo.id
              inner join t_city tc on tc.id = tla.city_id
              inner join t_approve_log tal on tal.loan_apply_id = tlo.id
		where tla.product_type = 1
			and tla.apply_source = 1 -- 1 新房 2 二手
			and tal.node_id in (8, 9)
			and tal.to_node_id in (10)
			and tal.approve_time > '2016-06-05 00:00:00'
			and tal.approve_time < '2016-06-13 23:59:59'
		) as city_amount
group by city_amount.city_id) as pass on total.cityId = pass.cityId;


<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="com.fangdd.loan.mapper.report.LoanReportMapper">
    <resultMap id="cityCountAmountMap" type="com.fangdd.loan.entity.report.CityCountAmount">
        <result column="cityId" property="cityId" jdbcType="BIGINT"/>
        <result column="cityName" property="cityName" jdbcType="VARCHAR"/>
        <result column="count" property="count" jdbcType="BIGINT"/>
        <result column="amountSum" property="amountSum" jdbcType="BIGINT"/>
    </resultMap>

    <select id="getPerCityApplyStatics" resultMap="cityCountAmountMap">
        select city_amount.city_id as cityId,
               city_amount.name as cityName,
               count(1) as `count`,
               sum(city_amount.apply_amount) as amountSum
        from (select distinct tla.id, tla.city_id, tc.name, tla.apply_amount
              from t_loan_apply tla
              inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
              inner join t_city tc on tc.id = tla.city_id
              where tla.apply_source = #{applySource}
                    and tla.product_type = #{productType}
                    <![CDATA[ and tla.created_time >= #{startTime} ]]>
                    <![CDATA[ and tla.created_time < #{endTime} ]]> ) as city_amount
        group by city_amount.city_id
    </select>

    <select id="getPerCityPhasePassStatistics" resultMap="cityCountAmountMap">
        select city_amount.city_id as cityId,
               city_amount.name as cityName,
               count(1) as `count`,
               sum(city_amount.apply_amount) as amountSum
        from (select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
              from t_loan_apply tla
              inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
              inner join t_city tc on tc.id = tla.city_id
              inner join t_approve_log tal on tal.loan_apply_id = tlo.id
              where tla.product_type = #{productType}
                    and tla.apply_source = #{applySource}
                    and tal.to_node_id = #{toNode}
                    <![CDATA[ and tlo.`status` <> 99 ]]>
                    <![CDATA[ and tlo.`status` <> -1 ]]>
                    <![CDATA[ and tal.approve_time >= #{startTime} ]]>
                    <![CDATA[ and tal.approve_time < #{endTime} ]]> ) as city_amount
        group by city_amount.city_id
    </select>

    <select id="getLendOutPerCityStatistics" resultMap="cityCountAmountMap">
        select city_amount.city_id as cityId,
               city_amount.name as cityName,
               count(1) as `count`,
               sum(city_amount.lend_amount) as amountSum
        from (select distinct tlo.id, tla.city_id, tc.name, td.lend_amount
              from t_loan_apply tla
              inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
              inner join t_debit td on td.loan_order_id = tlo.id
              inner join t_city tc on tc.id = tla.city_id
              inner join t_approve_log tal on tal.loan_apply_id = tlo.id
              where tla.product_type = #{productType}
                    and tla.apply_source = #{applySource}
                    and tal.to_node_id = 10
                    <![CDATA[ and tlo.`status` <> 99 ]]>
                    <![CDATA[ and tlo.`status` <> -1 ]]>
                    <![CDATA[ and tal.approve_time >= #{startTime} ]]>
                    <![CDATA[ and tal.approve_time < #{endTime} ]]> ) as city_amount
        group by city_amount.city_id
    </select>

    <select id="getPerCityPhaseTotalStatistics" resultMap="cityCountAmountMap">
        select city_amount.city_id as cityId,
        city_amount.name as cityName,
        count(1) as `count`,
        sum(city_amount.apply_amount) as amountSum
        from (select distinct tlo.id, tla.city_id, tc.name, tla.apply_amount
        from t_loan_apply tla
        inner join t_loan_order tlo on tlo.loan_apply_id = tla.id
        inner join t_city tc on tc.id = tla.city_id
        inner join t_approve_log tal on tal.loan_apply_id = tlo.id
        where tla.product_type = #{productType}
        and tla.apply_source = #{applySource}
        and tal.node_id = #{fromNode}
        <![CDATA[ and tlo.`status` <> 99 ]]>
        <![CDATA[ and tlo.`status` <> -1 ]]>
        <![CDATA[ and tal.approve_time >= #{startTime} ]]>
        <![CDATA[ and tal.approve_time < #{endTime} ]]> ) as city_amount
        group by city_amount.city_id
    </select>
</mapper>