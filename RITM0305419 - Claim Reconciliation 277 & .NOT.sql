declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')
declare @sa as integer = {?Service Area}


select 

 sa.serv_area_name as 'Service Area'
,rec.claim_rec_id as 'Claim Rec ID'
,rec.claim_invoice_num as 'Invoice Number'
,stat.category_data as 'Category Data'
,ot.payor_ref_num as 'Reference Number'
,stat.status_msg as 'Status Message'
,ot.status_date as 'Status Date'
,case when len(stat.category_data) = 4 then '.NOT' else '277' end as 'Status'
,epm.payor_name + ' - [' + cast(epm.payor_id as varchar) + '] ' as 'Payor' 


from 

reconcile_clm rec
left join reconcile_clm_ot ot on ot.claim_rec_id = rec.claim_rec_id
left join reconcile_clm_stat stat on stat.claim_recon_id = ot.claim_rec_id and stat.contact_date_real = ot.contact_date_real
left join clarity_sa sa on sa.serv_area_id = rec.service_area_id
left join clarity_epm epm on epm.payor_id = rec.payor_id

where 

sa.serv_area_id = @sa
and ot.status_date >= @start_date
and ot.status_date <= @end_date
and stat.category_data is not null
--and rec.claim_invoice_num = 'T334041341'