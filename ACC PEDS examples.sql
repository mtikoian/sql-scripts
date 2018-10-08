select distinct pat_name, contact_date, enc.department_id, pat_enc_csn_id, dest.name as destination from pat_enc enc
left join patient pat on pat.pat_id = enc.pat_id
left join clarity_ucl ucl on ucl.ept_csn = enc.pat_enc_csn_id
left join ZC_CHG_DESTINATION dest on dest.CHG_DESTINATION_C = ucl.CHG_DESTINATION_C
where enc.department_id = 13105154
and contact_date = '2016-05-17'
and dest.name = 'HMHP PEDS PRO FEES'
order by pat_name
