select 
 tdl.account_id
 ,acct.account_name
 ,tx_id
 ,tdl.orig_service_date
 ,tdl.post_date
 ,sa.serv_area_name
 ,tdl.tran_type
 ,eap.proc_code
 ,eap.proc_name
 ,tdl.orig_amt
 ,original_payor_id
 ,coalesce(epm_original.payor_name,'') as original_payor
 ,coalesce(epm.payor_name,'') as matched_payor
 ,coalesce(cast(arpb.eob_allowed_amount as varchar),'') as eob_allowed_amount
 ,coalesce(cast(arpb.eob_coins_amount as varchar),'') as eob_coins_amount
 ,coalesce(cast(arpb.eob_deduct_amount as varchar),'') as ebo_deduct_amount
 ,coalesce(cast(arpb.eob_copay_amount as varchar),'') as eob_copay_amount
 ,eap_match.proc_code
 ,eap_match.proc_name
 ,tdl.patient_amount
 ,tdl.insurance_amount


from 
clarity_tdl_tran tdl
left join account acct on tdl.account_id = acct.account_id
left join clarity_eap eap on tdl.proc_id = eap.proc_id
left join v_arpb_reimbursement arpb on tdl.match_trx_id = arpb.payment_tx_id
left join clarity_eap eap_match on tdl.match_proc_id = eap_match.proc_id
left join clarity_sa sa on tdl.serv_area_id = sa.serv_area_id
left join clarity_epm epm on tdl.match_payor_id = epm.payor_id
left join clarity_epm epm_original on tdl.original_payor_id = epm_original.payor_id


where tdl.tran_type = 1 --charge matched to payment
and eap.proc_code in ('99444')
and eap_match.proc_code in ('1000','2000')
and orig_service_date >= '2014-01-01 00:00:00'
--and tx_id = 64328419
--and tdl.account_id = 1107770

order by account_id, orig_service_date, post_date
