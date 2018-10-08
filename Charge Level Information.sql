select 
	 sa.serv_area_name
	,account_id
	,tx_id  --ETR .1
    ,specialty
	,case when detail_type = 1 then 'new charge' else 'voided charge' end as tran_type
	,orig_service_date --ETR 45
	,eap.proc_code
	,eap.proc_name as 'procedure'
	,modifier_one
	,modifier_two
	,modifier_three
	,modifier_four
	,procedure_quantity
	,amount
	--need invoice_number


from clarity_tdl_tran tdl
left join clarity_eap eap on tdl.proc_id = eap.proc_id
left join clarity_dep dep on tdl.dept_id = dep.department_id
left join clarity_sa sa on tdl.serv_area_id = sa.serv_area_id


where tdl.serv_area_id = 11
and orig_service_date >= '2014-01-01'
and Orig_service_date < '2015-01-01'
and tdl.detail_type in (1,10) -- new charge, voided charge
and specialty = 'physical therapy'
order by account_id, orig_service_date, proc_code