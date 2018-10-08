select
*
from 

(
select
sa.serv_area_name as 'Service Area'
,tdl.tx_id as 'Transaction ID'
,ser.prov_name as 'Billing Provider'
,eap.proc_name as 'Procedure Code'
,eap_match.proc_name as 'Matched Procedure Code'
,eap_match.gl_num_debit  as 'Matched GL Debit'
,eap.gl_num_debit as 'GL Debit'
,eap.gl_num_credit as 'GL Credit'
,case when tdl.detail_type in (21,23) and eap_match.gl_num_debit = 'admin' then tdl.amount 
 when tdl.detail_type in (4,13,30,31) and eap.gl_num_debit = 'admin' then tdl.amount
 when detail_type in (6) and eap.gl_num_credit = 'admin' then tdl.amount
 else 0 end as 'Amount'
from clarity_tdl_tran tdl
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
where tdl.post_date >= '9/1/2017'
and tdl.post_date <= '9/30/2017'
and tdl.serv_area_id = 1314
and billing_provider_id = '1648305'
and tdl.detail_type in (4,6,13,21,23,30,31)
)a

where amount <> 0