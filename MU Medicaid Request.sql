declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}') 
declare @npi as varchar(20) = {?NPI}

select 

--sum(tdl.procedure_quantity)
tdl.tx_id
,detail_type
,ser.prov_name + ' - ' + '[' + ser2.npi + ']' 'Billing Provider'
,pat.pat_mrn_id as 'MRN'
,case when arpb.outstanding_amt = 0 then 'Paid' else 'Oustanding' end 'Claim Status'
,tdl.orig_amt 'Charge Amount'
,case when payments.tx_type_c = 2 then match.mtch_tx_hx_pat_amt end 'Patient Paid'
,case when payments.tx_type_c = 2 then match.mtch_tx_hx_ins_amt end 'Insurance Paid'
,case when payments.tx_type_c = 3 then match.mtch_tx_hx_amt end 'Adjustment'
,arpb.outstanding_amt 'Outstanding Amt'
,tdl.orig_service_date 'Service Date'
,eap.proc_name + ' - ' + '[' + eap.proc_code + ']' 'Procedure'
,pos.pos_name + ' - ' + '[' + cast(pos.pos_id as varchar) + ']' 'Place of Service'
,fin.name + ' - ' + '[' + fin.fin_class_c + ']' 'Orig Fin Class'
,tdl.procedure_quantity
,tdl.original_cvg_id
,cov.subscr_num 

from 

clarity_tdl_tran tdl
left join arpb_transactions arpb on arpb.tx_id = tdl.tx_id
left join arpb_tx_match_hx match on match.tx_id = arpb.tx_id
left join arpb_transactions payments on payments.tx_id = match.mtch_tx_hx_id
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
left join clarity_ser_2 ser2 on ser2.prov_id = ser.prov_id
left join zc_fin_class fin on fin.fin_class_c = tdl.original_fin_class
left join patient pat on pat.pat_id = tdl.int_pat_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join coverage cov on cov.coverage_id = tdl.original_cvg_id

where 

ser2.npi = @npi
and tdl.detail_type in (1,10)
and arpb.tx_type_c = 1
and payments.tx_type_c in (2,3)
and tdl.post_date >= @start_date
and tdl.post_date < @end_date
and (tdl.cpt_code between '96150' and '96154'
or tdl.cpt_code between '90800' and '90899'
or tdl.cpt_code between '99024' and '99480'
or eap.proc_cat = 'PR EVALUATION AND MANAGEMENT SERVICES')
and match.MTCH_TX_HX_UN_DTTM is null
and payments.void_date is null
and arpb.void_date is null

order by tdl.tx_id