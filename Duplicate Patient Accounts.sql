with pat as
(
select 
PAT_REC_OF_GUAR_ID
,count(*) as count
from account acct
where serv_area_id = 1312
and pat_rec_of_guar_id is not null
group by pat_rec_of_guar_id
having count(*) > 1
)


select 
pat.PAT_REC_OF_GUAR_ID,
ACCOUNT_ID, 
ACCOUNT_NAME,
zat.name as 'ACCOUNT_TYPE',
SERV_AREA_ID

from pat
left join account acct on acct.pat_rec_of_guar_id = pat.pat_rec_of_guar_id
left join 	ZC_ACCOUNT_TYPE zat on zat.ACCOUNT_TYPE_C = acct.ACCOUNT_TYPE_C
where serv_area_id = 1312
order by pat.PAT_REC_OF_GUAR_ID