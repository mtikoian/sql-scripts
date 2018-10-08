select 

	patient.pat_name,
	patient.birth_date,
	clarity_dep.department_name,
	clarity_dep.department_id,
	clarity_ucl.service_date_dt,
	clarity_ucl.ucl_id,
	clarity_ser_servicing.prov_name as 'service_provider',
    clarity_ser_billing.prov_name as 'billing_provider',
	clarity_ser_referral.prov_name as 'referral_provider',
	clarity_ser_referral.prov_id as 'referral_provider_id',
	clarity_eap.proc_code,
	clarity_eap.proc_name,
	clarity_ucl.quantity -- The quantity entered for this charge line. 

from 

clarity_ucl
left join clarity_eap clarity_eap on clarity_ucl.procedure_id = clarity_eap.proc_id 
left join patient on clarity_ucl.patient_id = patient.pat_id
left join clarity_dep on clarity_ucl.department_id = clarity_dep.department_id
left join clarity_ser clarity_ser_billing on clarity_ucl.billing_provider_id = clarity_ser_billing.prov_id 
left join clarity_ser clarity_ser_servicing on clarity_ucl.service_provider_id = clarity_ser_servicing.prov_id 
left join clarity_ser clarity_ser_referral on clarity_ucl.rfl_provider_id = clarity_ser_referral.prov_id

where clarity_ucl.SERVICE_DATE_DT >= '2015-07-01 00:00' 
and clarity_ucl.SERVICE_DATE_DT <= '2015-07-16 00:00' 
and proc_code in ('5100007', '5100008', '5100009', '5100010', '5100011', '3310003', '3350001', '4600154', '9400003',
'3040101', '9400003', '2600006', '4600138', '4600154', '3040098', '7710001', '7710002', '3040075', '3040551', '3040757',
'2600002', '2600001', '4600138', '2600004', '2600003', '2600006', '4600165', '4600172', '9400011', '4600184', '3090001',
'4600163', '4600181', '4600185', '2700227', '3350002', '4600188', '3310001', '3310002','3040103')
and clarity_dep.department_id in ('13103151', '13105187', '13105115', '13101147', '13105133')
--and billing_provider_id in ('1636631', '1623855', '3051168', '3053984', '1625935')
and patient.pat_id in  ('Z3115219', 'Z2865980')

order by patient.pat_id, service_date_dt