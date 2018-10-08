declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

select
distinct
a.PAT_ENC_CSN_ID
,a.PAT_MRN_ID
,a.PAT_NAME
,a.PROC_CODE
,a.PROC_NAME
,a.BIRTH_DATE
,a.SERVICE_DATE_DT
,a.DESTINATION
,a.BILLING_PROVIDER_ID
,a.BILLING_PROVIDER_NAME
,a.SERVICE_PROVIDER_ID
,a.SERVICE_PROVIDER_NAME
,stuff((select distinct ', ' + edg.CURRENT_ICD10_LIST from pat_enc_dx enc_dx_2 left join CLARITY_EDG edg on edg.DX_ID = enc_dx_2.DX_ID
where enc_dx_2.PAT_ENC_CSN_ID = a.PAT_ENC_CSN_ID FOR XML PATH('')),1,1,'') As DIAGNOSIS
From
(
select 
 distinct
	 ucl.UCL_ID
	,ucl.SERVICE_DATE_DT
	,enc.BILL_NUM
	,enc.PAT_ENC_CSN_ID
	,pat.PAT_NAME
	,eap.PROC_CODE
	,eap.PROC_NAME
	,edg.CURRENT_ICD10_LIST
	,dep.DEPARTMENT_NAME
	,dest.NAME as DESTINATION
	,pat.PAT_MRN_ID
	,pat.BIRTH_DATE
	,ucl.BILLING_PROVIDER_ID
	,ser_bill.PROV_NAME as BILLING_PROVIDER_NAME
	,ucl.SERVICE_PROVIDER_ID
	,ser_serv.PROV_NAME as SERVICE_PROVIDER_NAME
	
from CLARITY_UCL ucl
left join ZC_CHG_DESTINATION dest on dest.CHG_DESTINATION_C = ucl.CHG_DESTINATION_C
inner join PATIENT pat on pat.PAT_ID = ucl.PATIENT_ID
left join CLARITY_EAP eap on eap.PROC_ID = ucl.PROCEDURE_ID
inner join PAT_ENC_2 enc on enc.PAT_ENC_CSN_ID = ucl.EPT_CSN
left join PAT_ENC_DX enc_dx on enc_dx.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
left join CLARITY_EDG edg on edg.DX_ID = enc_dx.DX_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = ucl.DEPARTMENT_ID
left join CLARITY_SER ser_bill on ser_bill.PROV_ID = ucl.BILLING_PROVIDER_ID
left join CLARITY_SER ser_serv on ser_serv.PROV_ID = ucl.SERVICE_PROVIDER_ID

where ucl.SERVICE_DATE_DT >= @start_date
and ucl.SERVICE_DATE_DT <= @end_date
and dep.DEPARTMENT_NAME = 'HMHP SE ACC PEDS LLC'
and dest.NAME = 'HMHP PEDS PRO FEES'
--and pat.PAT_NAME = 'SANCHEZ,JACOB Y'
)a

order by PAT_NAME