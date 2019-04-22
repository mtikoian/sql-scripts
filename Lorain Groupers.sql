select
 dep.DEPARTMENT_ID
,dep.DEPARTMENT_NAME
,loc.LOC_ID
,loc.LOC_NAME
,coalesce(try_cast(dep.RPT_GRP_ONE as numeric),dep.DEPARTMENT_ID) as DEPARTMENT_GROUPER_ID
,coalesce(dep.RPT_GRP_TWO, dep.DEPARTMENT_NAME) as DEPARTMENT_GROUPER_NAME
,coalesce(try_cast(loc.RPT_GRP_TWO as numeric), loc.LOC_ID) as LOC_GROUPER_ID
,coalesce(loc.RPT_GRP_THREE, loc.LOC_NAME) as LOC_GROUPER_NAME

from CLARITY_DEP dep
left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID

where dep.DEPARTMENT_ID in (17106104,19290055,17106101,19290082)

order by coalesce(try_cast(dep.RPT_GRP_ONE as numeric),dep.DEPARTMENT_ID)