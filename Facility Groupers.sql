select 
distinct
sa.rpt_grp_ten as 'Service Area ID'
,sa.name as 'Service Area Name'
,loc.rpt_grp_two as 'Location ID'
,loc.rpt_grp_three as 'Location Name'
,loc.gl_prefix as 'Location GL'
,dep.rpt_grp_one as 'Department ID'
,dep.rpt_grp_two as 'Department Name'
,dep.gl_prefix as 'Department GL'
,dep.specialty as 'Department Specialty'

from 
clarity_loc loc
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_dep dep on dep.rpt_grp_three = loc.rpt_grp_two

where 

sa.rpt_grp_ten in (11,13,16,17,18,19)
--and dep.rpt_grp_one = '18101257'
--and dep.rpt_grp_one = '18101244'
--and dep.rpt_grp_one = '18120062'
and dep.rpt_grp_one = '13104117'

select * from clarity_loc where rpt_grp_two = 13104