select YEAR_MONTH_STR, sum(amount) as CHARGES
from clarity_tdl_tran
left join date_dimension on CALENDAR_DT = POST_DATE
where detail_type in (1,10) 
and loc_id in (18120,18121,19120,19127)
and post_date >= '7/1/2018'
and post_date <= '9/30/2018'
group by YEAR_MONTH_STR