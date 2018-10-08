/*
Need to know the encounters (patient medical record numbers) that were opened by Joni Ruffner, NP-C(RUFF010) 
and closed by Charles Wehbe, MD(WEHB000) for DOS 1/1/2018 to present.
*/

select 
 pat.PAT_MRN_ID
,enc.PAT_ENC_CSN_ID
,cast(enc.CONTACT_DATE as date) as CONTACT_DATE
,zdet.NAME as ENCOUNTER_TYPE
,enc.ENC_CLOSED_USER_ID
,cast(enc.ENC_CLOSE_DATE as date) as ENC_CLOSE_DATE
,enc.APPT_ENTRY_USER_ID
,enc.CHECKIN_USER_ID

from PAT_ENC enc
left join PATIENT pat on pat.PAT_ID = enc.PAT_ID
left join ZC_DISP_ENC_TYPE zdet on zdet.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
where enc.ENC_CLOSED_USER_ID = 'WEHB000'
and contact_date >= '1/1/2018'