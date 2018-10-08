select 
 enc.PAT_ENC_CSN_ID as 'Patient CSN'
,enc.CONTACT_DATE as 'Contact Date'
,enc.ENC_TYPE_C  as 'ENC TYPE ID'
,disp.NAME as 'ENC TYPE'
,enc.DEPARTMENT_ID as 'Department ID'
,dep.DEPARTMENT_NAME as 'Department'
,dep.SPECIALTY as 'Department Specialty'
,dep.GL_PREFIX as 'Department GL'
,loc.LOC_ID as 'Location ID'
,loc.LOC_NAME as 'Location'
,loc.GL_PREFIX as 'Location GL'
,sa.RPT_GRP_TEN as 'Region ID'
,upper(sa.NAME) as 'Region'
,enc.COPAY_COLLECTED as 'Copay Collected'
,enc.COPAY_DUE as 'Copay Due'
,enc.ENC_CLOSED_YN as 'ENC Closed YN'
,enc.ENC_CLOSE_DATE as 'ENC Closed Date'
,appt.APPT_STATUS_C as 'Appt Status ID'
,appt.NAME as 'Appt Status'
,prc.PRC_ID as 'Visit Type ID'
,prc.PRC_NAME as 'Visit Type'
,prc.BENEFIT_GROUP as 'Benefit Group'
,ser_visit.PROV_ID as 'Visit Provider ID'
,ser_visit.PROV_NAME as 'Visit Provider'
from PAT_ENC enc
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_SER ser_visit on ser_visit.PROV_ID = enc.VISIT_PROV_ID
left join CLARITY_PRC prc on prc.PRC_ID = enc.APPT_PRC_ID
left join ZC_APPT_STATUS appt on appt.APPT_STATUS_C = enc.APPT_STATUS_C
left join ZC_DISP_ENC_TYPE disp on disp.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
where enc.CONTACT_DATE >= '5/1/2018'
and enc.CONTACT_DATE <='5/31/2018'
and enc.SERV_AREA_ID in (11,13,16,17,18,19)