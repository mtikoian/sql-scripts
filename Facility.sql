/*updated on 12/7/16 to only include records with gl location.*/

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
select distinct coalesce(convert(varchar,dep.DEPARTMENT_ID), '000000000') as 'DEPARTMENT_ID'
 ,'MHPG' as 'CORPORATE_ID' 
 ,'CORPORATE' as 'CORPORATE_NAME' 
 ,convert(varchar,sa.SERV_AREA_ID) as 'MARKET_ID'
 ,case when sa.SERV_AREA_ID = 19 then 'KENTUCKY' else coalesce(convert(varchar,sa.SERV_AREA_NAME), 'NO SERVICE AREA NAME') end as 'MARKET_NAME'
 ,convert(varchar,loc.gl_prefix) + '-' + convert(varchar, sa.serv_area_id) as 'LOCATION_ID'
 ,convert(varchar,loc.gl_prefix) + '-' + convert(varchar, sa.serv_area_id) as 'LOCATION_NAME'
 ,convert(varchar,loc.gl_prefix) + '-' + convert(varchar, sa.serv_area_id) + '-' + case when dep.specialty_dep_C is null then '0' else convert(varchar, dep.SPECIALTY_DEP_C) end as 'SPECIALTY_ID'
 ,convert(varchar,loc.gl_prefix) + '-' + convert(varchar, sa.serv_area_id) + '-' + case when dep.specialty_dep_c is null then 'Other' else dep.SPECIALTY end as 'SPECIALTY_NAME'
 ,coalesce(convert(varchar,dep.gl_prefix),'80000') + '-'  + coalesce(convert(varchar,dep.DEPARTMENT_ID), '000000000') + '-' + coalesce(dep.department_name, 'NO DEPARTMENT NAME')  as 'DEPARTMENT_NAME'


from clarity_sa sa
left join clarity_loc loc on loc.serv_area_id = sa.serv_area_id
left join clarity_dep dep on dep.rev_loc_id = loc.loc_id

where sa.serv_area_id in (11,13,16,17,18,19) 
and dep.department_id is not null
and loc.gl_prefix is not null
and dep.department_name not like '%mhpx%'
and dep.department_name not like '%mdcx%'
)a


order by corporate_id, market_id, location_id, specialty_id, department_id


