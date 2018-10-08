/*Yep, that’s what it says. Although, this takes into account undistributed debit adjustments as well 
(things like NSF fees, form fees, etc.). It might be more accurate to say 
(TX_TYPE_C =2 or (TX_TYPE_C = 3 and DEBIT_CREDIT_FLAG = Credit))
*/

select 
 arpb_tx.post_date as 'Post Date'
,case when loc.rpt_grp_two in ('11106','11124','11149')  then 'SPRINGFIELD'
	 when loc.rpt_grp_ten in ('11') then 'CINCINNATI'
	 when loc.rpt_grp_ten in ('13') then 'YOUNGSTOWN'
	 when loc.rpt_grp_ten in ('16') then 'LIMA'
	 when loc.rpt_grp_ten in ('17') then 'LORAIN'
	 when loc.rpt_grp_two in ('18120','18121') then 'DEFIANCE'
	 when loc.rpt_grp_ten in ('18')  then 'TOLEDO'
	 when loc.rpt_grp_ten in ('19') then 'KENTUCKY' 
	 when loc.rpt_grp_ten in ('1') then 'MERCY HEALTH' 
	 else 'UNKNOWN REGION'
	 end as 'Region'
,case when loc.rpt_grp_three is null then 'UNKNOWN LOCATION'
	else upper(loc.rpt_grp_three) + ' [' + loc.gl_prefix + ']' end as 'Location'
,case when dep.rpt_grp_two is null then 'UNKNOWN DEPARTMENT' 
	else upper(dep.rpt_grp_two) + ' [' + dep.gl_prefix + ']' end as 'Department'
,eap.proc_code + ' - ' + eap.proc_name as 'Procedure Code'
,sum(amount) as 'Total Undistributetd Amount'
,sum(case when tx_type_c = 2 then amount else 0 end) as 'Undistributed Payments'
,sum(case when tx_type_c = 3 then amount else 0 end) as 'Undistributed Adjustments'
from arpb_transactions arpb_tx
left join clarity_loc loc on loc.loc_id = arpb_tx.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_dep dep on dep.department_id = arpb_tx.department_id
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
where tx_type_c in (2,3)
and amount <> 0 
and total_match_amt = 0
and sa.rpt_grp_ten in (1,11,13,16,17,18,19)
and void_date is null

group by
 loc.rpt_grp_two
,loc.rpt_grp_ten
,loc.rpt_grp_three
,dep.rpt_grp_two
,loc.gl_prefix
,dep.gl_prefix
,eap.proc_code
,eap.proc_name
,arpb_tx.post_date

order by
 loc.rpt_grp_two
,loc.rpt_grp_ten
,loc.rpt_grp_three
,dep.rpt_grp_two
,loc.gl_prefix
,dep.gl_prefix
,eap.proc_code
,eap.proc_name
,arpb_tx.post_date
