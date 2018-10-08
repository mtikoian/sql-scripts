select
department_id
,department_name
,rev_loc_id
,record_status
from 
clarity_dep
where rev_loc_id is null
and (record_status not in (1,2,3,4,5,6,7)
or record_status is null)
