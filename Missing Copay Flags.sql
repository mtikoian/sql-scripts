
select 
 distinct
 zbtf.NAME as 'Flag Type'
,pat.PAT_NAME as 'Patient Name'
,id.IDENTITY_ID as 'MRN'
,cast(enc.CONTACT_DATE as date) as 'Encounter Date'
,zdet.NAME as 'Encounter Type'
,emp.NAME as 'Entered By'
,pff.ACCT_NOTE_INSTANT as 'Flag Created'
,pff.LAST_UPDATE_INST as 'Last Update'
,za.NAME as 'Flag Status'
,pff.PAT_ENC_CSN_ID as 'Encounter ID'
,dep.DEPARTMENT_ID as 'Department ID'
,dep.DEPARTMENT_NAME as 'Department'
,ser.PROV_ID as 'Visit Provider ID'
,ser.PROV_NAME as 'Visit Provider'

from PATIENT_FYI_FLAGS pff 
left join ZC_BPA_TRIGGER_FYI zbtf on zbtf.BPA_TRIGGER_FYI_C = pff.PAT_FLAG_TYPE_C
left join PATIENT pat on pat.PAT_ID = pff.PATIENT_ID
left join IDENTITY_ID id on id.PAT_ID = pat.PAT_ID
left join CLARITY_EMP emp on emp.USER_ID = pff.ENTRY_PERSON_ID
left join ZC_ACTIVE za on za.ACTIVE_C = pff.ACTIVE_C
left join PAT_ENC enc on (enc.PAT_ENC_CSN_ID = pff.PAT_ENC_CSN_ID) or (enc.PAT_ID = pff.PATIENT_ID and cast(enc.CONTACT_DATE as date) = cast(pff.ACCT_NOTE_INSTANT as date) and enc.CHECKIN_USER_ID = pff.ENTRY_PERSON_ID)
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join CLARITY_SER ser on ser.PROV_ID = enc.VISIT_PROV_ID
left join ZC_DISP_ENC_TYPE zdet on zdet.DISP_ENC_TYPE_C = enc.ENC_TYPE_C

where pff.PAT_FLAG_TYPE_C in ('117001','117002','117003') -- First Copay Missed, Second Copay Missed, Third Copay Missed
and id.IDENTITY_TYPE_ID = 0

order by id.IDENTITY_ID, cast(enc.CONTACT_DATE as date)