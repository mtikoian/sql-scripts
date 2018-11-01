select 
 cast(age.POST_DATE as date) as DATE
,upper(sa.NAME) as REGION
,det.NAME as TYPE
,sum(age.AMOUNT) as AR

from CLARITY_TDL_AGE age
left join CLARITY_LOC loc on loc.LOC_ID = age.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join ZC_DETAIL_TYPE det on det.DETAIL_TYPE = age.DETAIL_TYPE

where age.POST_DATE = '8/31/2018'
and age.SERV_AREA_ID in (11,13,16,17,18,19)

group by 
 age.POST_DATE
,sa.NAME
,det.NAME

order by 
 age.POST_DATE
,sa.NAME
,det.NAME


--select 
-- cast(age.POST_DATE as date) as DATE
--,upper(sa.NAME) as REGION
--,pat.PAT_NAME as PATIENT
--,det.NAME as TYPE
--,sum(age.AMOUNT) as AR

--from CLARITY_TDL_AGE age
--left join CLARITY_LOC loc on loc.LOC_ID = age.LOC_ID
--left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
--left join ZC_DETAIL_TYPE det on det.DETAIL_TYPE = age.DETAIL_TYPE
--left join PATIENT pat on pat.PAT_ID = age.INT_PAT_ID

--where age.POST_DATE = '8/31/2018'
--and age.SERV_AREA_ID in (11,13,16,17,18,19)

--group by 
-- age.POST_DATE
--,sa.NAME
--,pat.PAT_NAME
--,det.NAME

--order by 
-- age.POST_DATE
--,sa.NAME
--,pat.PAT_NAME
--,det.NAME