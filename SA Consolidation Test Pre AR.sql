select 
 pac.pat_id
,pat.pat_name
,pac.amount
,pac.serv_area_id as 'Orig SA ID'
,serv.serv_area_name as 'Orig SA Name'
,pac.loc_id as 'Orig Loc ID'
,loc.loc_name as 'Orig Loc Name'
,pac.proc_dept_id as 'Orig Dept ID'
,dep.department_name as 'Orig Dept Name'
,sa.rpt_grp_ten as 'Grp SA ID'
,sa.name as 'Grp SA Name'
,loc.rpt_grp_two as 'Grouper Loc ID'
,loc.rpt_grp_three as 'Grouper Loc Name'
,dep.rpt_grp_one as 'Grouper Dept ID'
,dep.rpt_grp_two as 'Grouper Dept Name'

 from pre_ar_chg pac
 left join patient pat on pat.pat_id = pac.pat_id
left join clarity_loc loc on loc.loc_id = pac.loc_id
left join clarity_dep dep on dep.department_id = pac.proc_dept_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_sa serv on serv.serv_area_id = pac.serv_area_id


where account_id = 100051332