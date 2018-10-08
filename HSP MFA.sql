select
	coverage_mem_list.pat_id,
	pat_last_name,
	pat_first_name,
	pat_middle_name,
	add_line_1,
	add_line_2,
	patient.city,
	zc_state.name as 'state',
	zc_country.name as 'country',
	patient.zip,
	patient.home_phone,
	account_name,
	zc_account_type.name,
	zc_account_status.name,
	serv_area_id, 
	zc_financial_class.name,
	mem_eff_from_date,
	mem_eff_to_date,
	clarity_epm.payor_id,
	clarity_epm.payor_name,
	coverage_mem_list.pat_id,
	coverage_mem_list.line

from patient 
left join coverage_mem_list on  patient.pat_id = coverage_mem_list.pat_id 
left join coverage on coverage_mem_list.coverage_id = coverage.coverage_id
left join acct_coverage on coverage.coverage_id = acct_coverage.coverage_id
left join account on acct_coverage.account_id =  account.account_id
left join account_status on account.account_id = account_status.account_id
left join zc_account_status on account_status.account_status_c = zc_account_status.account_status_c
left join zc_financial_class on account.fin_class_c = zc_financial_class.financial_class
left join zc_account_type on account.account_type_c = zc_account_type.account_type_c
left join clarity_epm on coverage.payor_id = clarity_epm.payor_id
left join zc_state on patient.state_c = zc_state.state_c
left join zc_country on patient.country_c = zc_country.country_c

where account_status.account_status_c in  (141,140) -- HSP MFA Rx & Medical, HSP MFA Medical
and account.serv_area_id = 21
and payor_name in ('HSIC MEDICARE COST', 'HSIC MEDICARE ADVANTAGE', 'HSIC MEDICARE COSTXX', 'MEDICARE')
and (mem_eff_from_date >= '2014-01-01' or mem_eff_from_date is null)


order by patient.pat_id

