select sa.serv_area_name
,zucl.name as charge_source
,service_date_dt
,patient_id
,pat_name
,ucl.account_id
,acct.account_name
,billing_provider_id
,bill.prov_name as billing_provider_name
,service_provider_id
,ser.prov_name as service_provider_name
,procedure_id
,proc_name
from clarity_ucl ucl
left join ZC_CHG_SOURCE_UCL zucl on ucl.CHARGE_SOURCE_C = zucl.CHG_SOURCE_UCL_C
left join CLARITY_SA sa on ucl.SERVICE_AREA_ID = sa.SERV_AREA_ID
left join patient pat on ucl.patient_id = pat.pat_id
left join account acct on ucl.account_id = acct.account_id
left join clarity_ser bill on ucl.billing_provider_id = bill.prov_id
left join clarity_ser ser on ucl.service_provider_id = ser.prov_id
left join clarity_eap eap on ucl.procedure_id = eap.proc_id
where SERVICE_DATE_DT >= '2014-03-01 00:00'
and SERVICE_DATE_DT <= '2015-03-31 00:00'
and ucl.SERVICE_AREA_ID in (13)
and system_flag_c in (1,3) -- new or modified
--and zucl.name = 'inpatient'
--and SERVICE_AREA_ID in (11,13,16,17,18,19)
order by serv_area_name, zucl.name, service_date_dt