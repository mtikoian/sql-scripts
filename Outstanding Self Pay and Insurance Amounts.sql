select
orig_service_date
,account_id
,pat_id
,detail_type
,amount
,patient_amount
,insurance_amount
from clarity_tdl_age
where serv_area_id = 402
and tdl_extract_date = '2015-02-01'
and account_id = 1897742

order by account_id

select * from arpb_transactions where account_id = 1897742