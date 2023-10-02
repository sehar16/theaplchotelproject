-- ******SLIDE 1*****************************************************
-- Is hotel revenue increasing year on year?
-- *************************************************************************
select h.arrival_date_year as year,
    round(sum((((h.stays_in_week_nights + h.stays_in_weekend_nights) * (h.adults + h.children + h.babies) * m.cost)
+
     ((h.stays_in_week_nights + h.stays_in_weekend_nights) * h.adr) )
* ( 1 - mg.discount))) as paid from 
(select * from hotel2018
union all
select * from hotel2019
union all
select * from hotel2020
) as h
inner join meal_cost as m on m.meal= h.meal
inner join market_segment as mg on mg.market_segment = h.market_segment
where h.is_canceled = 0 
group by 1;
 
-- ****************************************************************************************************
-- *****SLIDE 2******
-- What market segment are major contributors of the revenue per year
-- ****************************************************************************************************

select segment, max(year2018) as year2018, max(year2019) as year2019, max(year2020) as year2020 from
(select segment,
case
     when year = 2018 then paid else 0
     end as year2018,
case
     when year = 2019 then paid else 0
     end as year2019,
case
     when year = 2020 then paid else 0
     end as year2020 from 
(select h.arrival_date_year as year, mg.market_segment as segment ,
    sum((((h.stays_in_week_nights + h.stays_in_weekend_nights) * (h.adults + h.children + h.babies) * m.cost)
+
     ((h.stays_in_week_nights + h.stays_in_weekend_nights) * h.adr) )
* ( 1 - mg.discount)) as paid

from 
(select * from hotel2018
union all
select * from hotel2019
union all
select * from hotel2020
)
 as h
inner join meal_cost as m on m.meal= h.meal
inner join market_segment as mg on mg.market_segment = h.market_segment
where h.is_canceled = 0 
group by 1,2)as temp) as temp1 group by 1;


-- ****************************************************************************************************
-- *****SLIDE 3******
-- When is the hotel at maximum occupancy?
-- ****************************************************************************************************
select arrival_date_month, max(year2018) as year2018 ,max(year2019) as year2019,max(year2020) as year2020, max(week_num) as week_num from
(select arrival_date_month,week_num,
case 
    when year =2018 then occupancy else 0
end as year2018,
case 
    when year =2019 then occupancy else 0
end as year2019,
case 
    when year =2020 then occupancy else 0
end as year2020 from
 (
		SELECT arrival_date_year as year, arrival_date_month,max(arrival_date_week_number) as week_num,count(*) as occupancy from hotel2018 group by 1,2 
        union all
        SELECT arrival_date_year as year, arrival_date_month,max(arrival_date_week_number) as week_num,count(*) as occupancy FROM hotel2019 group by 1,2 
        union all
        SELECT arrival_date_year as year, arrival_date_month,max(arrival_date_week_number) as week_num,count(*) as occupancy FROM hotel2020 group by 1,2 
    ) as temp) as temp1 group by 1 order by 5;


-- ****************************************************************************************************
 -- ******SLIDE 4******
-- When are people cancelling the most?
-- ****************************************************************************************************
SELECT arrival_date_month,max(count2018) as count2018, max(count2019) as count2019 , max(count2020) as count2020, max(week_num) as week_num 
FROM 
(SELECT 
 arrival_date_month, week_num,
CASE 
	WHEN arrival_date_year = 2018 THEN cnt
    ELSE 0
END as count2018,
CASE 
	WHEN arrival_date_year = 2019 THEN cnt
    ELSE 0
END as count2019,
CASE 
	WHEN arrival_date_year = 2020 THEN cnt
    ELSE 0
END as count2020
FROM (
Select arrival_date_year, arrival_date_month, max(arrival_date_week_number) as week_num,count(*) as cnt from hotel2018 WHERE is_canceled = 1 group by 1,2 
UNION
Select arrival_date_year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2019 WHERE is_canceled = 1 group by 1,2
UNION
Select arrival_date_year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2020 WHERE is_canceled = 1 group by 1,2) as temp) as temp2 
GROUP BY 1 ORDER BY 5;

-- ****************************************************************************************************
-- *****SLIDE 5*****
-- Are families with kids more likely to cancel the hotel booking?
-- ****************************************************************************************************
select familyflag, max(year2018) as year2018, max(year2019) as year2019 , max(year2020) as year2020  from
(select familyflag,
case
    when arrival_date_year = 2018 then count else 0
end as year2018,
 case
    when arrival_date_year = 2019 then count else 0
end as year2019,
case
    when arrival_date_year = 2020 then count else 0
end as year2020 from
(select arrival_date_year, familyflag , count(*) as count from
(select *,
case 
  when (children + babies) = 0 then 'NON_FAMILY'
  ELSE 'FAMILY'
  END AS familyflag from
(select * from hotel2018
union all
select * from hotel2019
union all
select * from hotel2020) as temp) as temp1 WHERE is_canceled = 1 group by 1,2)astemp2) as temp3 group by 1
;

