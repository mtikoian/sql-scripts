select 
[Financial Class]
,count(*) as count

from

(

select 
distinct int_pat_id
,fc.financial_class_name as 'Financial Class'


from 
clarity_tdl_tran tdl
left join clarity_fc fc on fc.financial_class = tdl.original_fin_class
where serv_area_id in (30)
and detail_type = 1 
and orig_service_date >= '1/1/2015'
and orig_service_date < '1/1/2016'


)a

group by [financial class]
order by [financial class]