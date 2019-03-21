with appt as

(
select *

from 

(
select 
a.pat_id
,a.pat_enc_csn_id
,a.contact_date
,a.DEPARTMENT_ID
,ROW_NUMBER() OVER(PARTITION BY PAT_ID ORDER BY PAT_ENC_CSN_ID desc) AS Row#

from f_sched_appt a
left join clarity_ser s   on a.prov_id = s.prov_id 

where a.prov_id = '1612910' 
and a.appt_status_c in (2,6)  --completed or arrived
) a

where row# = 1
)

select 
 id.IDENTITY_ID as 'PATIENT MRN'
,pat.PAT_FIRST_NAME as 'FIRST NAME'
,pat.PAT_MIDDLE_NAME as 'MIDDLE NAME'
,pat.PAT_LAST_NAME as 'LAST NAME'
,appt.CONTACT_DATE as 'CONTACT DATE'
,ser.PROV_NAME as 'BILLING PROVIDER'
,dep.DEPARTMENT_NAME as 'DEPARTMENT'
,eap.PROC_CODE as 'PROCEDURE CODE'
,eap.PROC_NAME as 'PROCEDURE DESC'

from appt
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.PAT_ENC_CSN_ID = appt.PAT_ENC_CSN_ID
left join IDENTITY_ID id on id.PAT_ID = arpb_tx.PATIENT_ID
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_SER ser on ser.PROV_ID = arpb_tx.BILLING_PROV_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = appt.DEPARTMENT_ID
left join PATIENT pat on pat.PAT_ID = arpb_tx.PATIENT_ID

where arpb_tx.TX_TYPE_C = 1
and arpb_tx.PROC_ID = 23664
and id.IDENTITY_TYPE_ID = 0

order by id.IDENTITY_ID