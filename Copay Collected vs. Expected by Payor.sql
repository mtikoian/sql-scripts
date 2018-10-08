select 
 PAT_ENC_CSN_ID
,CONTACT_DATE
,cov.PAYOR_ID
,COPAY_COLLECTED
,COPAY_DUE
from V_SCHED_APPT vsa
left join COVERAGE cov on cov.COVERAGE_ID = vsa.COVERAGE_ID
where COPAY_DUE > 0
and appt_status_c = 2 -- completed
and contact_date >= '1/1/2017'
and contact_date <= '12/31/2017'
and serv_area_id in (11,13,16,17,18,19)

order by PAT_ENC_CSN_ID