declare @start_date as date = EPIC_UTIL.EFN_DIN('yb')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select

 sa.name as 'Service Area'
,loc.gl_prefix as 'Location GL'
,dep.gl_prefix as 'Department GL'
,dep.rpt_grp_two as 'Department Name'
,icd9_code as 'ICD9 Code'
,current_icd10_list as 'ICD10 Code'
,dx_name as 'Diagnosis'
,@start_date as 'Start Date'
,@end_date as 'End Date'
,sum(amount) as 'Amount'
,count(tx_id) as 'Quantity'

from arpb_transactions arpb
left join clarity_dep dep on dep.department_id = arpb.department_id
left join clarity_edg edg on edg.dx_id = arpb.primary_dx_id
left join clarity_loc loc on loc.loc_id = arpb.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten

where post_date >= @start_date
and post_date <= @end_date

and tx_type_c = 1
and dep.gl_prefix in  
('422355', '440355', '440360', '471352', '471355', '480000', '495356', 
 '500361', '630358', '630359', '630360', '630361', '630362', '630364', 
 '630366', '790360', '790362', '790363', '790364', '790365', '790366', 
 '790367', '790371', '790377', '790382', '790383', '790388', '790391', 
 '790395', '818362')
and arpb.void_date is null
and loc.gl_prefix <> '6749'

group by 

sa.rpt_grp_ten
,sa.name
,loc.gl_prefix
,dep.gl_prefix
,dep.rpt_grp_two
,icd9_code
,current_icd10_list
,dx_name

order by sa.rpt_grp_ten, count(tx_id) desc
