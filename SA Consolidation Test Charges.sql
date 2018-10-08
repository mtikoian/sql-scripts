/*
Coffee, Decaf- E6035885
Latte, Benny- E6022647
Mocha, Medicaid- E6033996
*/

select
 tdl.pat_id
,pat.pat_name
,tdl.orig_service_date
,tdl.amount
,tdl.serv_area_id as 'Orig SA ID'
,serv.serv_area_name as 'Orig SA Name'
,tdl.loc_id as 'Orig Loc ID'
,loc.loc_name as 'Orig Loc Name'
,tdl.dept_id as 'Orig Dept ID'
,dep.department_name as 'Orig Dept Name'
,sa.rpt_grp_ten as 'Grp SA ID'
,sa.name as 'Grp SA Name'
,loc.rpt_grp_two as 'Grouper Loc ID'
,loc.rpt_grp_three as 'Grouper Loc Name'
,dep.rpt_grp_one as 'Grouper Dept ID'
,dep.rpt_grp_two as 'Grouper Dept Name'


from CLARITY_TDL_TRAN tdl
left join patient pat on pat.pat_id = tdl.int_pat_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_sa serv on serv.serv_area_id = tdl.serv_area_id

where 
--tdl.pat_id in
--('E6024464','E6014330','E6022668','E6014281','E6058334','E6035885','E6022647','E6033996','E6015092','E6035886','E6014296')
 tdl.account_id = '100051332'
and tdl.orig_service_date >= '12/6/16'
and tdl.detail_type = 1