declare @startdate date  = dateadd(d,0,datediff(d,0,getdate())) ---7 days ago
		,@enddate date = dateadd(d,0,datediff(d,0,getdate())+7); ---yesterday

select
 enc.CONTACT_DATE
,coalesce(cast(enc.ACCOUNT_ID as nvarchar),'UKNOWN ACCOUNT') as ACCOUNT
,upper(sa.NAME) as 'REGION'
,dep.DEPARTMENT_NAME
,coalesce(dep.SPECIALTY,'No Specialty') as SPECIALTY
,stat.NAME as 'APPOINTMENT_STATUS'
,type.NAME as 'ENCOUNTER TYPE'
,coalesce(enc.COPAY_COLLECTED,0) as COPAY_COLLECTED
,coalesce(enc.COPAY_DUE,0) as COPAY_DUE
,case when bal.PATIENT_BALANCE < 0 then 0 else coalesce(bal.PATIENT_BALANCE,0) end as PB_PATIENT_BALANCE
,case when bal.HB_SELFPAY_BALANCE <0 then 0 else coalesce(bal.HB_SELFPAY_BALANCE,0) end as HB_PATIENT_BALANCE

from PAT_ENC enc
left join PAT_ENC_2 enc2 on enc2.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
left join ZC_APPT_STATUS stat on stat.APPT_STATUS_C = enc.APPT_STATUS_C
left join CLARITYCHPUTIL.rpt.PB_DAILY_ACCOUNT_PATIENT_BALANCE bal on bal.ACCOUNT_ID = enc.ACCOUNT_ID and bal.UPDATE_DATE = enc.CONTACT_DATE
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join ZC_DISP_ENC_TYPE type on type.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_POS pos on pos.POS_ID = enc2.VISIT_POS_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = enc2.VISIT_PAYOR_ID

where enc.APPT_STATUS_C = 1 -- scheduled
and enc.SERV_AREA_ID in (11,13,16,17,18,19)
and enc.CONTACT_DATE >= @startdate 
and enc.CONTACT_DATE <= @enddate