select 

 id.IDENTITY_ID as 'PAT_MRN'
,pat.PAT_NAME
,pac.ACCOUNT_ID
,pac.COVERAGE_ID
,cvg.PAYOR_ID
,epm.PAYOR_NAME
,zat.NAME as ACCOUNT_TYPE
,rel.NAME as 'GUARANTOR RELATION TO PATIENT'

from PAT_ACCT_CVG pac
left join ACCOUNT acct on acct.ACCOUNT_ID = pac.ACCOUNT_ID
left join COVERAGE cvg on cvg.COVERAGE_ID = pac.COVERAGE_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = cvg.PAYOR_ID
left join ZC_ACCOUNT_TYPE zat on zat.ACCOUNT_TYPE_C = pac.ACCOUNT_TYPE_C
left join PATIENT pat on pat.PAT_ID = pac.PAT_ID
left join ZC_GUAR_REL_TO_PAT rel on rel.GUAR_REL_TO_PAT_C = pac.GUAR_PAT_REL
left join IDENTITY_ID id on id.PAT_ID = pat.PAT_ID

where acct.SERV_AREA_ID = 615
and epm.PAYOR_NAME like '%MOLINA%'
and id.IDENTITY_TYPE_ID = 0

order by acct.ACCOUNT_ID