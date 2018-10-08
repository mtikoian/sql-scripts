select 

dep.department_id
,dep.department_name
,loc.loc_id
,loc.loc_name
,sa.serv_area_id
,sa.serv_area_name

from clarity_dep dep 
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join clarity_sa sa on sa.serv_area_id = loc.serv_area_id


where 

sa.serv_area_id not in (11,13,16,17,18,19)