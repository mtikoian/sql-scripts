SELECT sa.serv_area_name  
	,pat_first_name
	,pat_last_name
	,birth_date
	,service_date
	,eap.proc_name
	,amount as 'charge amount'
	,epp_orig.benefit_plan_id as 'original_plan_id'
	,epp_orig.benefit_plan_name as 'original_plan_name'
	,epp_curr.benefit_plan_id as 'current_plan_id'
	,epp_curr.benefit_plan_name as 'current_plan_name'
	,epm_orig.payor_id as 'original_payor_id'
	,epm_orig.payor_name as 'original_payor_name'
	,epm_cur.payor_id as 'currrent_payor_id'
	,epm_cur.payor_name as 'current_payor_name'


FROM arpb_transactions arpb_transactions_charges
LEFT JOIN account acct ON arpb_transactions_charges.account_id = acct.account_id
LEFT JOIN coverage coverage_charges WITH (NOLOCK) ON arpb_transactions_charges.ORIGINAL_CVG_ID = coverage_charges.coverage_id
LEFT JOIN coverage coverage_current WITH (NOLOCK) ON arpb_transactions_charges.coverage_id = coverage_current.coverage_id
LEFT JOIN patient ON arpb_transactions_charges.patient_id = patient.pat_id
LEFT JOIN clarity_sa sa ON arpb_transactions_charges.service_area_id = sa.serv_area_id
left join clarity_epm epm_cur on arpb_transactions_charges.payor_id = epm_cur.payor_id
left join clarity_epm epm_orig on arpb_transactions_charges.original_epm_id = epm_orig.payor_id
left join clarity_epp epp_curr on coverage_current.plan_id = epp_curr.benefit_plan_id
left join clarity_epp epp_orig on coverage_charges.plan_id = epp_orig.benefit_plan_id
left join clarity_eap eap on arpb_transactions_charges.proc_id = eap.proc_id
WHERE (coverage_charges.plan_id = 1005001 -- ANTHEM SENIOR ADVANTAGE
or coverage_current.plan_id = 1005001)
	AND service_date >= '2014-01-01 00:00:00'
	AND sa.serv_area_id < 30  -- EXCLUDE AFFILIATES
	AND arpb_transactions_charges.tx_type_c = 1 -- TRANSACTION TYPE = CHARGES
ORDER By arpb_transactions_charges.patient_id, service_date