/*Copyright (C) 2015 MERCY HEALTH
********************************************************************************
TITLE:   V_MH_PB_CUBE_D_DEPARTMENT
PURPOSE: Dimension table view for Departments with SSAS Cubes
AUTHOR:  Dustin Plowman
REVISION HISTORY: 
*dsp 4/19/16 - created
********************************************************************************
*/


select 
	coalesce(cast(sa.serv_area_id as VARCHAR),'0') + '-' + coalesce(cast(loc.loc_id as VARCHAR),'0') + '-' + coalesce(cast(dep.department_id as VARCHAR),'0') as 'ID'
   ,sa.SERV_AREA_NAME + ' [' + CAST(sa.SERV_AREA_ID as VARCHAR) + ']' as 'SERVICE AREA NAME'
   ,cast(loc.LOC_ID as VARCHAR) as 'LOCATION ID'
   ,loc.LOC_NAME + ' [' + CAST(loc.LOC_ID as VARCHAR) + ']' as 'LOCATION NAME'
   ,case when loc.GL_PREFIX is null then loc.LOC_NAME else loc.GL_PREFIX + ' - ' + loc.LOC_NAME end as 'LOCATION GL'
   ,coalesce(cast(dep.DEPARTMENT_ID as VARCHAR),'Unspecified Department ID') as 'DEPARTMENT ID'
   ,case when dep.DEPARTMENT_NAME is null then 'Unspecified Department Name' else dep.DEPARTMENT_NAME + ' [' + CAST(dep.DEPARTMENT_ID as VARCHAR) + ']' end as 'DEPARTMENT NAME'
   ,case when dep.GL_PREFIX is null then coalesce(dep.DEPARTMENT_NAME,'Unspecified Department Name') else dep.GL_PREFIX + ' - ' + dep.DEPARTMENT_NAME end as 'DEPARTMENT GL'
   ,coalesce(spec.NAME,'Unspecified Specialty') as 'SPECIALTY'

from clarity_sa sa
left join clarity_loc loc on loc.serv_area_id = sa.serv_area_id
left join clarity_dep dep on dep.rev_loc_id = loc.loc_id
left outer join ZC_DEP_SPECIALTY spec on dep.SPECIALTY_DEP_C = spec.DEP_SPECIALTY_C

where sa.serv_area_id in (11,13,16,17,18,19)

union

select
	coalesce(cast(sa.serv_area_id as VARCHAR),'0') + '-' + coalesce(cast(loc.loc_id as VARCHAR),'0') + '-' + coalesce(cast(dep.department_id as VARCHAR),'0') as 'ID'
   ,sa.SERV_AREA_NAME + ' [' + CAST(sa.SERV_AREA_ID as VARCHAR) + ']' as 'SERVICE AREA NAME'
   ,cast(loc.LOC_ID as VARCHAR) as 'LOCATION ID'
   ,loc.LOC_NAME + ' [' + CAST(loc.LOC_ID as VARCHAR) + ']' as 'LOCATION NAME'
   ,case when loc.GL_PREFIX is null then loc.LOC_NAME else loc.GL_PREFIX + ' - ' + loc.LOC_NAME end as 'LOCATION GL'
   ,coalesce(cast(dep.DEPARTMENT_ID as VARCHAR),'Unspecified Department ID') as 'DEPARTMENT ID'
   ,case when dep.DEPARTMENT_NAME is null then 'Unspecified Department Name' else dep.DEPARTMENT_NAME + ' [' + CAST(dep.DEPARTMENT_ID as VARCHAR) + ']' end as 'DEPARTMENT NAME'
   ,case when dep.GL_PREFIX is null then coalesce(dep.DEPARTMENT_NAME,'Unspecified Department Name') else dep.GL_PREFIX + ' - ' + dep.DEPARTMENT_NAME end as 'DEPARTMENT GL'
   ,coalesce(spec.NAME,'Unspecified Specialty') as 'SPECIALTY'

from clarity_sa sa
left join clarity_loc loc on loc.serv_area_id = sa.serv_area_id
left join clarity_dep dep on dep.department_id = loc.default_dept_id
left outer join ZC_DEP_SPECIALTY spec on dep.SPECIALTY_DEP_C = spec.DEP_SPECIALTY_C

where sa.serv_area_id in (11,13,16,17,18,19)

union 

select
	coalesce(cast(sa.serv_area_id as VARCHAR),'0') + '-' + coalesce(cast(loc.loc_id as VARCHAR),'0') + '-' + coalesce(cast(dep.department_id as VARCHAR),'0') as 'ID'
   ,sa.SERV_AREA_NAME + ' [' + CAST(sa.SERV_AREA_ID as VARCHAR) + ']' as 'SERVICE AREA NAME'
   ,cast(loc.LOC_ID as VARCHAR) as 'LOCATION ID'
   ,loc.LOC_NAME + ' [' + CAST(loc.LOC_ID as VARCHAR) + ']' as 'LOCATION NAME'
   ,case when loc.GL_PREFIX is null then loc.LOC_NAME else loc.GL_PREFIX + ' - ' + loc.LOC_NAME end as 'LOCATION GL'
   ,coalesce(cast(dep.DEPARTMENT_ID as VARCHAR),'Unspecified Department ID') as 'DEPARTMENT ID'
   ,case when dep.DEPARTMENT_NAME is null then 'Unspecified Department Name' else dep.DEPARTMENT_NAME + ' [' + CAST(dep.DEPARTMENT_ID as VARCHAR) + ']' end as 'DEPARTMENT NAME'
   ,case when dep.GL_PREFIX is null then coalesce(dep.DEPARTMENT_NAME,'Unspecified Department Name') else dep.GL_PREFIX + ' - ' + dep.DEPARTMENT_NAME end as 'DEPARTMENT GL'
   ,coalesce(spec.NAME,'Unspecified Specialty') as 'SPECIALTY'

from clarity_sa sa
left join clarity_loc loc on loc.serv_area_id = sa.serv_area_id
left join clarity_dep dep on dep.serv_area_id = loc.loc_id
left outer join ZC_DEP_SPECIALTY spec on dep.SPECIALTY_DEP_C = spec.DEP_SPECIALTY_C

where sa.serv_area_id in (11,13,16,17,18,19)

