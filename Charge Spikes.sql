select 
 sum(case when detail_type in (1,10) then amount else 0 end) as 'Charges'
,sum(case when detail_type in (2,5,11,20,22,32,33) then amount else 0 end) as 'Payments'
from clarity_tdl_tran
where serv_area_id in (11,13,16.17,18,19)
and post_date >= '10/1/2018'
and post_date <= '10/31/2018'
