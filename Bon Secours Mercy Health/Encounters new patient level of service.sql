declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

select
 pat.PAT_MRN_ID as 'PATIENT MRN'
,pat.PAT_NAME as 'PATIENT NAME'
,cast(enc.CONTACT_DATE as date) as 'CONTACT DATE'
,enc.APPT_TIME as 'APPT TIME'
,zdet.NAME as 'ENCOUNTER TYPE'
,prc.PRC_NAME as 'VISIT TYPE'
,zas.NAME as 'APPT STATUS'
,enc.PAT_ENC_CSN_ID
,dep.DEPARTMENT_NAME as 'DEPARTMENT'
,ser.PROV_NAME as 'VISIT PROVIDER'
,eap.PROC_CODE as 'PROCEDURE CODE'
,eap.PROC_NAME as 'PROCEDURE DESC'
,eap_chg.PROC_CODE as 'BILLED PROCEDURE CODE'
,eap_chg.PROC_NAME as 'BILLED PROCEDURE DESC'
from PAT_ENC enc
left join CLARITY_EAP eap on eap.PROC_ID = enc.LOS_PRIME_PROC_ID
left join PATIENT pat on pat.PAT_ID = enc.PAT_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join CLARITY_SER ser on ser.PROV_ID = enc.VISIT_PROV_ID
left join CLARITY_PRC prc on prc.PRC_ID = enc.APPT_PRC_ID
left join ZC_DISP_ENC_TYPE zdet on zdet.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
left join ZC_APPT_STATUS zas on zas.APPT_STATUS_C = enc.APPT_STATUS_C
left join CLARITY_TDL_TRAN tdl on tdl.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID and tdl.DETAIL_TYPE = 1
left join CLARITY_EAP eap_chg on eap_chg.PROC_ID = tdl.PROC_ID
where eap.PROC_CODE in ('92002', '92004', '99201', '99202', '99203', '99204', '99205', '99324', '99325', '99326', '99327', '99328', '99341', '99342', '99343', '99344', '99345', '99381', '99382', '99383', '99384', '99385', '99386', '99387', '99460', '99461', '99463', '99464') 
and enc.VISIT_PROV_ID in ('1613829','1624444','1605843','1602706','1628327')
and enc.CONTACT_DATE >= @start_date
and enc.CONTACT_DATE <= @end_date
order by enc.APPT_TIME