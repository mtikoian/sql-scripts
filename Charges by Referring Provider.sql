select 

sa.serv_area_name as 'Service Area'
,pos.pos_name as 'Place of Service'
,tdl.referral_source_id as 'Referral Provider ID'
,ser.prov_name as 'Referral Provider Name'
,tdl.billing_provider_id as 'Billing Provider ID'
,ser_bill.prov_name as 'Billing Provider Name'
,pat.pat_mrn_id as 'Patient MRN'
,pat.pat_name as 'Patient Name'
,tdl.tx_id as 'ETR ID'
,type.name as 'Type'
,orig_service_date as 'Service Date'
,eap.proc_name + ' - ' + eap.proc_code as 'Charge Procedure'
,tdl.amount as 'Amount'

from clarity_tdl_tran tdl
left join clarity_ser ser on ser.prov_id = tdl.referral_source_id
left join clarity_ser ser_bill on ser_bill.prov_id = tdl.billing_provider_id
left join zc_detail_type type on type.detail_type = tdl.detail_type
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join patient pat on pat.pat_id = tdl.int_pat_id
where tdl.detail_type in (1,10)
and sa.serv_area_id = 609
and referral_source_id is not null

order by orig_service_date