select 
	 sa.serv_area_name
	,tdl.account_id
	,tdl.invoice_number --ETR 955
	,tdl.tx_id  --ETR .1
	,specialty
	,case when tdl.detail_type = 50 then 'Insurance Claim' else 'Patient Bill' end as tran_type
	,pos.pos_type 
	,tdl.orig_service_date --ETR 45
	,payor.payor_name as 'original_payor'
	,fin.name as 'original_financial_class'
	,pos.pos_name as 'place_of_service'
	,pat.birth_date
	,sex.name as 'gender'
	,performing.prov_name as 'service_provider'
	,billing.prov_name as 'billing_provider'
	,tdl.dx_one_id
	,tdl.dx_two_id
	,tdl.dx_three_id
	,tdl.dx_four_id
	,tdl.dx_five_id
	,tdl.dx_six_id
	,eap.proc_code
	,eap.proc_name as 'procedure'

	
from clarity_tdl_tran tdl
left join zc_financial_class fin on tdl.original_fin_class = fin.financial_class
left join clarity_epm payor on tdl.original_payor_id = payor.payor_id
left join clarity_pos pos on tdl.pos_id = pos.pos_id
left join patient pat on tdl.int_pat_id = pat.pat_id
left join clarity_ser billing on tdl.billing_provider_id = billing.prov_id
left join clarity_ser performing on tdl.performing_prov_id = performing.prov_id
left join clarity_eap eap on tdl.proc_id = eap.proc_id
left join zc_sex sex on pat.sex_c = sex.rcpt_mem_sex_c
left join clarity_dep dep on tdl.dept_id = dep.department_id
left join clarity_sa sa on tdl.serv_area_id = sa.serv_area_id


where tdl.serv_area_id = 11
and tdl.orig_service_date >= '2014-01-01'
and tdl.Orig_service_date < '2015-01-01'
and tdl.detail_type in (50) -- insurance claim
and specialty = 'physical therapy'
--and tdl.tx_id = 65883643
order by account_id, orig_service_date, proc_code