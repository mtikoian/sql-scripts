select 
 tdl.account_id
,tdl.tx_id
,tdl.orig_service_date
,pat.pat_name
,epm.payor_id as 'original_payor_id'
,epm.payor_name as 'original_payor_name'
,epm_cur.payor_id as 'current_payor_id'
,epm_cur.payor_name as 'current_payor_name'
,tdl.orig_price
,eob.cvd_amt
,eob.noncvd_amt
,eob.ded_amt
,eob.copay_amt
,eob.coins_amt
,eob.cob_amt
,eob.paid_amt
,eap.proc_code as 'charge_code'
,eap.proc_name as 'charge_proc'
,eap_match.proc_code as 'payment_code'
,eap_match.proc_name as 'payment_proc'
,tdl.amount
,tdl.patient_amount
,tdl.insurance_amount
,sa.serv_area_id
,sa.serv_area_name
,loc.loc_id
,loc.loc_name
,dep.department_id
,dep.department_name

from 

clarity_tdl_tran tdl
left join pmt_eob_info_I eob on eob.tx_id = tdl.match_trx_id
left join clarity_epm epm on epm.payor_id = tdl.original_payor_id
left join clarity_epm epm_cur on epm_cur.payor_id = tdl.cur_payor_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join patient pat on pat.pat_id = tdl.int_pat_id

where

tdl.serv_area_id in (11,13,16,17,18,19)
and tdl.orig_service_date >= '2015-01-01'
and eap.proc_code in ('99444') -- G0444
and tdl.detail_type = 20 


order by tdl.account_id