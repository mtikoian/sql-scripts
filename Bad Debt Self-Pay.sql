declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-17');
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-4');
--with collections as

--(

select 
 upper(sa.name) as 'Region'
,dep.rpt_grp_two as 'Department'
,dep.specialty as 'Specialty'
,dep16.name as 'Service Line'
,arpb_tx.tx_id as 'Chg ID'
,arpb_tx.account_id as 'Account'
,cast(arpb_tx.service_date as date) as 'Service Date'
,cast(arpb_tx.post_Date as date) as 'Chg Post Date'
,eap.proc_code as 'Proc Code'
,eap.proc_name as 'Proc Desc'
,arpb_tx.amount as 'Chg Amt'
--,col.line as 'Collection Line'
,coalesce(epm.payor_name,'Self-Pay') as 'Payor'
,zeha.name as 'Activity'
--,cast(ext_hx_act_date as date) as 'Date Sent to Collections'
,ext_hx_pat_amt as 'Collection Patient Amt'
,ext_hx_ins_amt as 'Collection Insurance Amt'
--,ROW_NUMBER() OVER(PARTITION BY arpb_tx.tx_id ORDER BY col.line desc) as Row#
,max(cast(ext_hx_act_date as date)) as 'Date Sent to Collections'

from arpb_transactions arpb_tx
left join arpb_tx_col_ext_hx col on col.tx_id = arpb_tx.tx_id and col.ext_hx_activity_c = 2 -- sent to agency
left join zc_ext_hx_activity zeha on zeha.ext_hx_activity_c = col.ext_hx_activity_c 
left join clarity_epm epm on epm.payor_id = arpb_tx.original_epm_id
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join clarity_dep dep on dep.department_id = arpb_tx.department_id
left join zc_dep_rpt_grp_16 dep16 on dep16.rpt_grp_sixteen_c = dep.rpt_grp_sixteen_c
left join clarity_loc loc on loc.loc_id = arpb_tx.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten

where arpb_tx.service_date >= @start_date
and arpb_tx.service_date >= @end_date
and sa.rpt_grp_ten in (11,13,16,17,18,19)
and tx_type_c = 1 -- charges
--and col.ext_hx_activity_c = 2 -- sent to agency
--and ext_hx_act_date >= @collection_date
and arpb_tx.original_epm_id is null -- self pay
and arpb_tx.void_date is null -- exclude voids
--and arpb_tx.tx_id = 171488926
and arpb_tx.amount > 0


group by
 sa.name
,dep.rpt_grp_two
,dep.specialty
,dep16.name
,arpb_tx.tx_id
,arpb_tx.service_date
,arpb_tx.post_Date
,eap.proc_code
,eap.proc_name
,arpb_tx.amount
,epm.payor_name
,zeha.name
,ext_hx_pat_amt
,ext_hx_ins_amt

order by 
arpb_tx.tx_id

--)

--select * from collections where row# = 1