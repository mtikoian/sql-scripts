DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-6')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select 

varc.MATCH_CHG_TX_ID
	,pat.PAT_MRN_ID as 'PAT_ID'
	,varc.ACCOUNT_ID
	,varc.MATCH_CHG_TX_NUM
	,varc.DEPT_NM_WID
	,varc.LOC_NM_WID
	,varc.MATCH_CHG_ORIG_AMT
	,varc.BILLING_PROV_NM_WID
	,eap_chg.proc_code + ' [' + eap_chg.proc_name + ']' as CPT_CODE
	,varc.PAYMENT_POST_DATE
	,varc.PAYMENT_TX_ID
	,varc.INVOICE_NUM
	,varc.EOB_CODES
	--,varc.REMIT_CODE_NAME
	,varc.REMIT_ACTION_NAME
	,varc.REMIT_CODE_CAT_NAME
	,varc.REMIT_CODE_TYPE_NAME
	,eob.DENIAL_CODES
	,varc.PAYOR_NM_WID
	,varc.PAYOR_FIN_CLASS_NM_WID
	,varc.PLAN_NM_WID
	,varc.NON_PRIMARY_YN
	,varc.EOB_ICN
	,varc.SERV_AREA_ID
	,varc.REMIT_ACTION
	,varc.REMIT_CODE_TYPE_C
	,varc.REMIT_AMOUNT
	,varc.SERVICE_DATE
	,dep.rpt_grp_two + '[ ' + dep.rpt_grp_one + ']' as 'Department'
	,loc.rpt_grp_three + '[ ' + loc.rpt_grp_two + ']' as 'Location'
	,varc.SOURCE_AREA_NAME
	--,rmc1.REMIT_CODE_NAME
	--,rmc2.REMIT_CODE_NAME
	--,rmc3.REMIT_CODE_NAME
	--,rmc4.REMIT_CODE_NAME
	,varc.BILL_AREA_NM_WID
	,varc.FIN_SUBDIV_NM_WID
	,varc.FIN_DIV_NM_WID
	--,rmc4.RMC_EXTERNAL_ID
	--,rmc1.RMC_EXTERNAL_ID
	--,rmc2.RMC_EXTERNAL_ID
	--,rmc3.RMC_EXTERNAL_ID
	,varc.POS_NM_WID
	,rmc.PREVENTABLE_YN
	,loc.rpt_grp_two as LOC_ID
	,date.MONTH_NUMBER
	,date.MONTHNAME_YEAR
	,case when loc.rpt_grp_two in ('11106','11124','11149')  then 'SPRINGFIELD'
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
	--,case when rmc4.RMC_EXTERNAL_ID is not null then rmc1.RMC_EXTERNAL_ID + ', ' + rmc2.RMC_EXTERNAL_ID + ', ' + rmc3.RMC_EXTERNAL_ID + ', ' + rmc4.RMC_EXTERNAL_ID
	--	  when rmc3.RMC_EXTERNAL_ID is not null then rmc1.RMC_EXTERNAL_ID + ', ' + rmc2.RMC_EXTERNAL_ID + ', ' + rmc3.RMC_EXTERNAL_ID
	--	  when rmc2.RMC_EXTERNAL_ID is not null then rmc1.RMC_EXTERNAL_ID
	--	  end as 'REMARK CODE LIST' -- incorrect
	,case when rmc1.remit_code_name is not null then rmc1.remit_code_name else varc.remit_code_name end as 'Reason Code'

from 

clarity.dbo.V_ARPB_REMIT_CODES varc
left join clarity.dbo.PMT_EOB_INFO_I eob on eob.TX_ID = varc.PAYMENT_TX_ID and eob.LINE = varc.EOB_LINE
left join clarity.dbo.CLARITY_RMC rmc on rmc.REMIT_CODE_ID = varc.REMIT_CODE_ID
left join clarity.dbo.CLARITY_RMC rmc1 on rmc1.REMIT_CODE_ID = varc.REMARK_CODE_1_ID
--left join CLARITY_RMC rmc2 on rmc2.REMIT_CODE_ID = varc.REMARK_CODE_2_ID
--left join CLARITY_RMC rmc3 on rmc3.REMIT_CODE_ID = varc.REMARK_CODE_3_ID
--left join CLARITY_RMC rmc4 on rmc4.REMIT_CODE_ID = varc.REMARK_CODE_4_ID
left join clarity.dbo.CLARITY_DEP dep on dep.department_id = varc.DEPARTMENT_ID
left join clarity.dbo.CLARITY_LOC loc on loc.loc_id = varc.LOC_ID
left join clarity.dbo.DATE_DIMENSION date on date.CALENDAR_DT_STR = varc.PAYMENT_POST_DATE
left join clarity.dbo.PATIENT pat on pat.pat_id = varc.pat_id
left join clarity.dbo.CLARITY_EAP eap on eap.proc_id = varc.proc_id
left join clarity.dbo.ARPB_TRANSACTIONS arpb_tx on arpb_tx.tx_id = varc.match_chg_tx_id
left join clarity.dbo.clarity_eap eap_chg on eap_chg.proc_id = arpb_tx.tx_id 
where 
varc.PAYMENT_POST_DATE >= @start_date
and varc.PAYMENT_POST_DATE <= @end_date
and loc.rpt_grp_ten in (1,11,13,16,17,18,19)
and varc.REMIT_ACTION = 9





