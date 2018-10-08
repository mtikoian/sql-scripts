select

 tdl.account_id as 'Account ID'
,tdl.tx_id as 'Charge ID'
,tdl.match_trx_id as 'Payment ID'
,convert(DATE,tdl.orig_service_date,101) as 'DOS'
,cast(sa.serv_area_id as varchar) + ' - ' + sa.serv_area_name as 'Service Area'
,cast(loc.loc_id as varchar) + ' - ' + loc.loc_name 'Location'
,eap.proc_code + ' - ' + eap.proc_name as 'Procedure Code'
,tdl.orig_price 'Charge Amount'
,tdl.amount as 'Adjustment Amount'
,coalesce(tdl.TX_COMMENT,'') as 'Transaction Comment'
,emp.NAME as 'User Name'

from clarity_tdl_tran tdl
left join clarity_eap eap on eap.proc_id = tdl.match_proc_id
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_emp emp on emp.user_id = tdl.user_id

where eap.proc_code in ('8018','3010')
and tdl.detail_type in (21) -- Credit Adjustment matched to Charge
and sa.serv_area_id = 1312
and tdl.orig_service_date >= '2015-01-01'
and tdl.orig_service_date < '2016-04-01'

order by tdl.account_id
