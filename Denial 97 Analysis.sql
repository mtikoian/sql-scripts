/*

,arpb_tx.modifier_one as 'Modifier one'
,arpb_tx.modifier_two as 'Modifier Two'
*/


DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select *

from 
(
select 
	 case when loc.rpt_grp_two in ('11106','11124','11149')  then 'SPRINGFIELD'
	 when loc.rpt_grp_two in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11151','11132','11138') then 'CINCINNATI'
	 when loc.rpt_grp_two in ('13104','13105','13116') then 'YOUNGSTOWN'
	 when loc.rpt_grp_two in ('16102','16103','16104') then 'LIMA'
	 when loc.rpt_grp_two in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.rpt_grp_two in ('18120','18121') then 'DEFIANCE'
	 when loc.rpt_grp_two in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.loc_id in ('18110') then 'TOLEDO' -- MRG
	 when loc.rpt_grp_two in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.rpt_grp_two in ('19107','19108','19116','19118') then 'KENTUCKY' -- KY OTHER ENTITIES
	 end as 'REGION'
	,loc.rpt_grp_three + '[ ' + loc.rpt_grp_two + ']' as 'Location'
	,dep.rpt_grp_two + '[ ' + dep.rpt_grp_one + ']' as 'Department'
	,dep.specialty as 'Specialty'
	,cast(varc.service_date as date) as 'Date of Service'
	,cast(varc.match_chg_post_date as date) as 'Chg Post Date'
	,pat.pat_mrn_id as 'Patient MRN'
	,varc.match_chg_tx_id as 'Chg Id'
	,varc.match_chg_orig_amt as 'Chg Amt'
	,varc.CPT_CODE as 'CPT Code'
	,eap.proc_name as 'Procedure Desc'	
	,varc.PAYOR_FIN_CLASS_NM_WID
	,varc.PLAN_NM_WID
	,varc.BILLING_PROV_NM_WID
	,cast(varc.PAYMENT_POST_DATE as date) as 'Pymnt Post Date'
	,varc.payment_tx_id as 'Pymnt Id'
	,varc.payment_amount as 'Pymnt Amt'
	,rmc.remit_code_id as 'Remit Code'
	,rmc.remit_code_name as 'Remit Desc'
	,varc.remit_code_cat_nm_wid as 'Remit Category'
	,ROW_NUMBER() OVER(PARTITION BY varc.match_chg_tx_id ORDER BY varc.payment_post_date asc) as Row#


from 

V_ARPB_REMIT_CODES varc
left join PMT_EOB_INFO_I eob on eob.TX_ID = varc.PAYMENT_TX_ID and eob.LINE = varc.EOB_LINE
left join CLARITY_RMC rmc on rmc.REMIT_CODE_ID = varc.REMIT_CODE_ID
left join CLARITY_RMC rmc1 on rmc1.REMIT_CODE_ID = varc.REMARK_CODE_1_ID
--left join CLARITY_RMC rmc2 on rmc2.REMIT_CODE_ID = varc.REMARK_CODE_2_ID
--left join CLARITY_RMC rmc3 on rmc3.REMIT_CODE_ID = varc.REMARK_CODE_3_ID
--left join CLARITY_RMC rmc4 on rmc4.REMIT_CODE_ID = varc.REMARK_CODE_4_ID
left join CLARITY_DEP dep on dep.department_id = varc.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.loc_id = varc.LOC_ID
left join DATE_DIMENSION date on date.CALENDAR_DT_STR = varc.PAYMENT_POST_DATE
left join patient pat on pat.pat_id = varc.pat_id
left join clarity_eap eap on eap.proc_id = varc.proc_id

where 
varc.PAYMENT_POST_DATE >= @start_date
and varc.PAYMENT_POST_DATE <= @end_date
and loc.rpt_grp_ten in (11)
and rmc.remit_code_id = 97
--and varc.match_chg_tx_id in (179436867,179546486,180043545,180105275,180105935)
)a

where a.row# = 1