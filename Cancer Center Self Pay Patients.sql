/*
need to know all the self pay patients from St Anne Cancer Center and Perrysburg Cancer center from April 1 thru June 25, 2018
name, date of birth, location and date of service

STVZ ST ANNE MED ONC 193005185
STVZ PERRYSBURG MED ONC 193004111
MHPX CANCER CTR TOLEDO 19390072
MHPX CANCER CTR PBURG 19390161

*/

select 
distinct
 pat.PAT_NAME as PATIENT
,cast(pat.BIRTH_DATE as date) as DOB
,cast(enc.CONTACT_DATE as date) as 'CONTACT DATE'
,fc.FINANCIAL_CLASS_NAME as 'FINANCIAL CLASS'
,upper(sa.NAME) as 'REGION'
,loc.LOC_NAME as 'LOCATION'
,dep.DEPARTMENT_NAME as 'DEPARTMENT'
from PAT_ENC enc
left join PATIENT pat on pat.PAT_ID = enc.PAT_ID
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = enc.VISIT_FC
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
where enc.DEPARTMENT_ID in 
(193005185,193004111,19390072,19390161)
and contact_date between '4/1/2018' and '6/25/2018'
and enc.APPT_STATUS_C = 2 -- COMPLETED
and visit_fc = 4 -- selfpay
