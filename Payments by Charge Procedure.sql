select 

 date.year as 'Year'
,date.year_month as 'Year_Month'
,sa.serv_area_name as 'Service Area'
,eap.proc_code + ' - ' + eap.proc_name as 'Charge Procedure'
,tdl.amount as 'Payment Amount'
,tdl.tx_id

from clarity_tdl_tran tdl
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_eap eap on eap.proc_id = tdl.match_proc_id
left join date_dimension date on date.calendar_dt_str = tdl.post_date

where 
tdl.tran_type = 2
and tdl.serv_area_id = 30
and tdl.post_date >= '1/1/2014'
and eap.proc_code in (
'99221'
,'99222'
,'99223'
,'99231'
,'99232'
,'99233'
,'99238'
,'99239'
,'99291'
,'99217'
,'99218'
,'99219'
,'99220'
,'99224'
,'99225'
,'99226'
,'99234'
,'99235'
,'99236'
)