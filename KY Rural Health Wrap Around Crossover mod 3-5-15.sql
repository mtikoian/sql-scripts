select  
        tdl.tx_id as 'Charege ID'
	   ,tdl.match_trx_id as 'Payment ID'
	   ,pat.pat_mrn_id
       ,pat.pat_name as 'Patient Name'
	   ,epm2.payor_name as 'Original Payor'
       ,epm.payor_name as 'Current Payor'
	   ,epm3.payor_name as 'Matched Payor'
       ,cvg.SUBSCR_NUM as 'Original Subscriber ID'
	   ,cvg2.SUBSCR_NUM as 'Current Subscriber ID'
       ,tdl.orig_service_date as 'Service Date'
	   ,tdl.post_date as 'Post Date'
       ,eap.proc_code as 'Procedure Code'
       ,eap.proc_name as 'Procedure'
       ,tdl.orig_amt as 'Original Amount'
       ,tdl.insurance_amount as 'Insurance Amount'
	   ,eob.coins_amt as 'Coinsurance Amount'
	   ,eob.ded_amt as 'Deductible Amount'
       ,dep.department_name as 'Department'
       ,bill.prov_name as 'Billing Provider'
	   ,zs.name
	   ,npi.identity_id as 'NPI'
       ,perf.prov_name as 'Performing Provider'
       ,eob.ICN as 'ICN'
From clarity_tdl_tran tdl
left  join CLARITY_EAP eap on tdl.PROC_ID = eap.proc_id
left  join patient pat on tdl.int_pat_id = pat.pat_id
left join clarity_epm epm on tdl.cur_payor_id = epm.payor_id
left join clarity_epm epm2 on tdl.original_payor_id = epm2.payor_id
left join clarity_epm epm3 on tdl.action_payor_id = epm3.payor_id
left join clarity_dep dep on tdl.dept_id = dep.department_id
left join coverage cvg on tdl.original_cvg_id = cvg.coverage_id
left join coverage cvg2 on tdl.cur_cvg_id = cvg2.coverage_id
left join clarity_ser bill on tdl.billing_provider_id = bill.prov_id
left join clarity_ser perf on tdl.performing_prov_id = perf.prov_id
left join PMT_EOB_INFO_I eob on tdl.tdl_id = eob.tdl_id and tdl.match_trx_id = eob.tx_id
left join clarity_ser_spec spec_billing on bill.prov_id = spec_billing.prov_id
left join zc_specialty zs on spec_billing.specialty_c = zs.specialty_c
left join IDENTITY_SER_ID npi on tdl.billing_provider_id = npi.prov_id
where epm.payor_id in (1001, 2009,4101,4186,5101,4100,4205)
and dep.department_id in (19102105, 19102103, 19102104, 19102101, 19102102)
and tdl.orig_service_date >= '2011-11-01 00:00:00'
and tdl.orig_service_date <= ' 2014-12-31 00:00:00'
and tdl.detail_type = 20 -- Charges
--and tdl.insurance_amount <> 0
and identity_type_id = 100001 -- NPI
and spec_billing.line = 1 -- Primary Specialty
and tdl.tx_id = 50581688

and original_payor_id =  1001 -- Medicare
--and tdl.tx_id = 7067973
order by pat.pat_mrn_id, tdl.tx_id