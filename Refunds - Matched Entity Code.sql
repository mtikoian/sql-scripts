declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select
 tdl.tx_id as 'TX_ID'
,tdl.int_pat_id as 'INT PAT ID'
,acct.account_name + ' [' + cast(acct.account_id as varchar) + ']' as 'Account Name'
, '[' + eap.proc_code  + '] ' +  eap.proc_name  as 'Procedure Name'
,tdl.amount as 'Refund Amount'
,atr.refund_addr_name as 'REFUND NAME'
,atr.refund_addr_city as 'REFUND_ADDR_CITY'
,state.abbr as 'ABBR'
,tdl.post_date as 'POST DATE'
,emp.name as 'Provider'
,dep.department_name + ' [' + cast(dep.department_id as nvarchar) + ']' as 'Dept Name'
,sa.rpt_grp_ten as 'SERV_AREA_ID'
,@start_date as 'START DATE'
,@end_date as 'END DATE'
,loc_match.GL_PREFIX as 'ENTITY CODE'

from clarity_tdl_tran tdl
left join account acct on acct.account_id = tdl.account_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_loc loc_match on loc_match.loc_id = tdl.match_loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join arpb_tx_refund atr on atr.tx_id = tdl.tx_id
left join zc_state state on state.state_c = atr.refund_addr_state_c
left join clarity_emp emp on emp.user_id = tdl.user_id
left join clarity_dep dep on dep.department_id = tdl.dept_id

where
detail_type in (22)
and post_date >= @start_date
and post_date <= @end_date
and sa.rpt_grp_ten in (1,11,13,16,17,18,19)
and tdl.credit_gl_num = 'REFUND'

order by 
tdl.tx_id
