--select
--* from FRONT_END_PMT_COLL_HX hx
--where pat_enc_csn_id = 182811932

--select * from pat_enc where pat_enc_csn_id = 182811932
/* Remove Encounter Types
	Hospital encounter: 3
	Community Outreach: 2106920036
	Scheduled Telephone Encounter: 21001783
	Erroneous Encounter: 2505
*/
select 
  cast(enc.CONTACT_DATE as date) as CONTACT_DATE
 ,dep_login.DEPARTMENT_ID
 ,dep_login.DEPARTMENT_NAME
 ,dep_login.SPECIALTY
 ,disp.NAME as ENCOUNTER
 ,enc.PAT_ENC_CSN_ID
 ,hx.COLL_WORKFLOW_TYPE_C
 ,sum(PB_COPAY_COLL) as PB_COPAY_COLL
 ,sum(PB_COPAY_PAID) as PB_COPAY_PAID
 ,sum(PB_COPAY_DUE) as PB_COPAY_DUE
 ,sum(HB_COPAY_COLL) as HB_COPAY_COLL
 ,sum(HB_COPAY_PAID) as HB_COPAY_PAID
 ,sum(HB_COPAY_DUE) as HB_COPAY_DUE
 ,sum(PB_PREPAY_COLL) as PB_PREPAY_COLL
 ,sum(PB_PREPAY_PAID) as PB_PREPAY_PAID
 ,sum(PB_PREPAY_DUE) as PB_PREPAY_DUE
 ,sum(HB_PREPAY_COLL) as HB_PREPAY_COLL
 ,sum(HB_PREPAY_PAID) as HB_PREPAY_PAID
 ,sum(HB_PREPAY_DUE) as HB_PREPAY_DUE
 ,sum(PB_PREV_BAL_COLL) as PB_PREV_BAL_COLL
 ,sum(PB_PREV_BAL_PAID) as PB_PREV_BAL_PAID
 ,sum(PB_PREV_BAL_DUE) as PB_PREV_BAL_DUE
 ,sum(HB_PREV_BAL_COLL) as HB_PREV_BAL_COLL
 ,sum(HB_PREV_BAL_PAID) as HB_PREV_BAL_PAID
 ,sum(HB_PREV_BAL_DUE) as HB_PREV_BAL_DUE

from PAT_ENC enc
left join FRONT_END_PMT_COLL_HX hx on hx.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
left join CLARITY_DEP dep_enc on dep_enc.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = dep_enc.REV_LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join ZC_DISP_ENC_TYPE disp on disp.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
left join CLARITY_DEP dep_login on dep_login.DEPARTMENT_ID = hx.LOGIN_DEPARTMENT_ID

where enc.CONTACT_DATE between '8/01/2018' and DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0)-1
and sa.RPT_GRP_TEN in (11,13,16,17,18,19)
and enc.APPT_STATUS_C in (2,5,6) --2: Completed, 5: Left without seen, 6: Arrived
and hx.LOGIN_DEPARTMENT_ID is not null
and enc.ENC_TYPE_C not in (3,2106920036,21001783,2505)
and hx.EVENT_TYPE_C = 0 -- Collection Event

group by enc.CONTACT_DATE
 ,dep_login.DEPARTMENT_ID
 ,dep_login.DEPARTMENT_NAME
 ,dep_login.SPECIALTY
 ,disp.NAME
 ,enc.PAT_ENC_CSN_ID
 ,hx.COLL_WORKFLOW_TYPE_C

order by enc.CONTACT_DATE
 ,dep_login.DEPARTMENT_ID
 ,dep_login.DEPARTMENT_NAME
 ,dep_login.SPECIALTY
 ,disp.NAME
 ,enc.PAT_ENC_CSN_ID
 ,hx.COLL_WORKFLOW_TYPE_C
