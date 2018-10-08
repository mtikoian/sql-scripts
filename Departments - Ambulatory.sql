select 
 dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,coalesce(dep.GL_PREFIX,'') as 'DEPARTMENT_GL'
,loc.LOC_ID
,loc.LOC_NAME
,coalesce(loc.GL_PREFIX,'') as 'LOCATION_GL'
,sa.RPT_GRP_TEN as 'REGION_ID'
,upper(sa.NAME) as 'REGION_NAME'

from CLARITY_LOC loc
left join CLARITY_DEP dep on dep.REV_LOC_ID = loc.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where loc.RPT_GRP_SIX = 100
and loc.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and dep.DEPARTMENT_ID is not null

order by dep.DEPARTMENT_ID