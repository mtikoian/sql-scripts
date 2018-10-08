select

	 'MHPG' as CORPORATE_ID
	,'CORPORATE' as CORPORATE_NAME
	,'UNDIST' as MARKET_ID
	,'UNDIST' as MARKET_NAME
	,'UNDIST' as LOCATION_ID
	,'UNDIST' as LOCATION_NAME
	,'UNDIST' as SPECIALTY_ID
	,'UNDIST' as SPECIALTY_NAME
	,'000000000' as DEPARTMENT_ID
	,'UNDIST' as DEPARTMENT_NAME

union all

select 
	 convert(varchar(255),CORPORATE_ID)
	,convert(varchar(50),CORPORATE_NAME)
	,convert(varchar(255),MARKET_ID)
	,convert(varchar(50),MARKET_NAME)
	,convert(varchar(255),LOCATION_ID)
	,convert(varchar(50),LOCATION_NAME)
	,convert(varchar(255),SPECIALTY_ID)
	,convert(varchar(50),SPECIALTY_NAME)
	,convert(varchar(255),DEPARTMENT_ID)
	,convert(varchar(255),DEPARTMENT_NAME)

from 

(
select  
  distinct
  coalesce(convert(varchar,dep.DEPARTMENT_ID), '000000000') as 'DEPARTMENT_ID'
 ,'MHPG' as 'CORPORATE_ID' 
 ,'CORPORATE' as 'CORPORATE_NAME'
 ,convert(varchar, sa.RPT_GRP_TEN) as 'MARKET_ID'
 ,convert(varchar, upper(sa.NAME)) as 'MARKET_NAME'
 ,convert(varchar, loc.GL_PREFIX) + '-' + convert(varchar, sa.RPT_GRP_TEN) as 'LOCATION_ID'
 ,convert(varchar, loc.GL_PREFIX) + '-' + convert(varchar, sa.RPT_GRP_TEN) as 'LOCATION_NAME'
 ,convert(varchar, loc.GL_PREFIX) + '-' + convert(varchar, sa.RPT_GRP_TEN) + '-' + case when dep.SPECIALTY_DEP_C is null then '0' else convert(varchar, dep.SPECIALTY_DEP_C) end as 'SPECIALTY_ID'
 ,convert(varchar, loc.GL_PREFIX) + '-' + convert(varchar, sa.RPT_GRP_TEN) + '-' + case when dep.SPECIALTY_DEP_C is null then 'Other' else dep.SPECIALTY end as 'SPECIALTY_NAME'
 ,coalesce(convert(varchar, dep.GL_PREFIX),'80000') + '-'  + coalesce(convert(varchar, dep.DEPARTMENT_ID), '000000000') + '-' + coalesce(dep.DEPARTMENT_NAME, 'NO DEPARTMENT NAME')  as 'DEPARTMENT_NAME'
from CLARITY_DEP dep
left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
where sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)
and loc.RPT_GRP_SIX = 100
)a

order by CORPORATE_ID, MARKET_ID, LOCATION_ID, SPECIALTY_ID, DEPARTMENT_ID
