select 

department_id,
department_name,
rev_loc_id,
rpt_grp_one,
rpt_grp_two,
rpt_grp_three
 from clarity_dep where department_id = 935

 select 
 loc_id,
 loc_name,
 rpt_grp_two,
 rpt_grp_three,
 serv_area_id
 ,sa.rpt_grp_ten as 'Grp SA ID'
,sa.name as 'Grp SA Name'

 from

 clarity_loc loc
 left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
   where loc_id = 19119