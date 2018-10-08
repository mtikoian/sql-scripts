select
 cast(enc.contact_date as date) as contact_date
,cast(tdl.orig_service_date as date) as service_date
,tdl.tx_id
,stat.name as appt_status
,eap.proc_code
,eap.proc_name
,pat.pat_mrn_id
,tdl.amount
from clarity_tdl_tran tdl
left join pat_enc enc on enc.pat_enc_csn_id = tdl.pat_enc_csn_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join patient pat on pat.pat_id = tdl.int_pat_id
left join zc_appt_status stat on stat.appt_status_c = enc.appt_status_c
where enc.appt_status_c = 2
and tdl.detail_type in (1,10)
and enc.contact_date >= '1/1/2017'
and enc.contact_date <> tdl.orig_service_date
--and pat.pat_mrn_id = 'E1493586'
order by tdl.tx_id