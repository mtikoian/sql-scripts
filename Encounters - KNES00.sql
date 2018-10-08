/*Looking for a report from June 1,2017 through today.
Would like the report to reflect all office visit encounters closed with 99999 LOS by Sue Knehr.( sign on : KNES00).
*/

select 
enc.enc_closed_user_id 'USER'
,enc.pat_enc_csn_id as 'PAT ENC CSN ID'
,cast(enc.enc_close_date as date) as 'ENC CLOSE DATE'
,enc_type.name as 'ENC TYPE'
,enc.los_proc_code as 'LOS PROC CODE'
,eap.proc_name as 'PROC DESC'

from pat_enc enc
left join clarity_eap eap on eap.proc_code = enc.los_proc_code
left join zc_disp_enc_type enc_type on enc_type.disp_enc_type_c = enc.enc_type_c
where enc.enc_closed_user_id = 'KNES00'
and enc.enc_close_date >= '06/01/2017'
and enc.los_proc_code = '99999'

order by enc.enc_close_date