select *
from referral_source
where referring_prov_id = 'e1012'

select distinct referral_source_id, referral_id, tx_id
from clarity_tdl_tran
where referral_source_id = 'e1012'
and tx_id = 80213857

select prov_id, prov_name
from clarity_ser
where prov_id = 'e1012'