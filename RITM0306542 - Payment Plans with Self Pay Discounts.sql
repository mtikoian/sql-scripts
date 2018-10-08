select 

acct.account_id
,acct.account_name
,acct.pmt_plan_strt_date
,acct.pmt_plan_amount
,arpb.tx_id
,sa.serv_area_name
,arpb.outstanding_amt
,arpb.insurance_amt
,arpb.patient_amt
,arpb.proc_id
,arpb.cpt_code
,arpb.payor_id
,arpb.coverage_id
,arpb.original_fc_c
,arpb.tx_type_c




from 

arpb_transactions arpb
left join account acct on acct.account_id = arpb.account_id
left join account_status stat on stat.account_id = acct.account_id
left join zc_account_status zstat on zstat.account_status_c = stat.account_status_c
left join clarity_sa sa on sa.serv_area_id = arpb.service_area_id

where

sa.serv_area_id in (11,13,16,17,18,19)
and acct.account_id = 1069338
and stat.account_status_c = 2
and pmt_plan_strt_date >= '2014-01-01'
--and arpb.tx_type_c = 1

