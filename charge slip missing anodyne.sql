select 
charge_slip_number
,tx_id as charge_id
,d.name as type
,orig_service_date
,post_date
,amount
from clarity_tdl_tran tdl
left join zc_detail_type d on d.detail_type = tdl.detail_type
where CHARGE_SLIP_NUMBER = -10385310
and d.detail_type <= 20

order by post_date