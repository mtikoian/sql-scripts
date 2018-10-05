select
 enc.CONTACT_DATE
,coalesce(cast(enc.ACCOUNT_ID as nvarchar),'UKNOWN ACCOUNT') as ACCOUNT
,upper(sa.NAME) as 'REGION'
,dep.DEPARTMENT_NAME
,coalesce(dep.SPECIALTY,'No Specialty') as SPECIALTY
,stat.NAME as 'APPOINTMENT_STATUS'
,type.NAME as 'ENCOUNTER_TYPE'
,coalesce(enc.COPAY_COLLECTED,0) as COPAY_COLLECTED
,coalesce(enc.COPAY_DUE,0) as COPAY_DUE
,case when bal.PATIENT_BALANCE < 0 then 0 else coalesce(bal.PATIENT_BALANCE,0) end as PB_PATIENT_BALANCE
,case when bal.HB_SELFPAY_BALANCE <0 then 0 else coalesce(bal.HB_SELFPAY_BALANCE,0) end as HB_PATIENT_BALANCE

from PAT_ENC enc
left join ZC_DISP_ENC_TYPE disp on disp.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
left join CLARITY_PRC prc on prc.PRC_ID = enc.APPT_PRC_ID
left join ClarityCHPUtil.rpt.PB_DAILY_ACCOUNT_PATIENT_BALANCE bal on bal.ACCOUNT_ID = enc.ACCOUNT_ID and bal.UPDATE_DATE = enc.CONTACT_DATE
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join ZC_APPT_STATUS stat on stat.APPT_STATUS_C = enc.APPT_STATUS_C
left join ZC_DISP_ENC_TYPE type on type.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
left join PAT_ENC_2 enc2 on enc2.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID


where enc.CONTACT_DATE >= '08/15/2018'
and enc.CONTACT_DATE <= '9/9/2018'
and enc.SERV_AREA_ID in (11,13,16,17,18,19)
and enc.APPT_STATUS_C in (2,5,6) -- Completed, Left without Seen, Arrived
order by enc.ACCOUNT_ID