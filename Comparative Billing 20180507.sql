declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-12')
declare @end_date as date = EPIC_UTIL.EFN_DIN('t-1')

select distinct
 case when loc.loc_id in (11106,11124,11149) then 'SPRINGFIELD' 
      when loc.loc_id in (18120,18121,19120,19127) then 'DEFIANCE'
	  else upper(sa.NAME) end as 'REGION'
,pac.TAR_ID as 'SESSION ID'
,pac.SERVICE_DATE as 'SERVICE DATE'
,pac.FILE_DATE as 'FILE DATE'
,pac.CHARGE_LINE as 'CHARGE LINE'
,pac.TX_ID as 'CHARGE ID'
,pat.PAT_NAME + ' [' + pat.PAT_MRN_ID + ']' as 'PATIENT'
,ser.PROV_NAME + ' [' + ser.PROV_ID + ']' as 'BILLING PROVIDER'
,eap_orig.PROC_NAME + ' [' + eap_orig.PROC_CODE + ']' as 'ORIGINAL PROCEDURE'
,eap.PROC_NAME + ' [' + eap.PROC_CODE + ']' as 'CHARGE PROCEDURE'
,paop.ORG_CHG_MOD as 'ORIGINAL MODIFIER'
,case when arpb_tx.MODIFIER_ONE is null then ''
      when arpb_tx.MODIFIER_TWO is null then arpb_tx.MODIFIER_ONE
	  when arpb_tx.MODIFIER_THREE is null then arpb_tx.MODIFIER_ONE + ', ' + arpb_tx.MODIFIER_TWO
	  when arpb_tx.MODIFIER_FOUR is null then arpb_tx.MODIFIER_ONE + ', ' + arpb_tx.MODIFIER_TWO + ', ' + arpb_tx.MODIFIER_THREE
	  else arpb_tx.MODIFIER_ONE + ', ' + arpb_tx.MODIFIER_TWO + ', ' + arpb_tx.MODIFIER_THREE + arpb_tx.MODIFIER_FOUR
	  end as 'CHARGE MODIFIER'
,upper(edg.DX_NAME) + ' [' + edg.CURRENT_ICD10_LIST + ']' as 'ORIGINAL DX'
,upper(edg_chg.DX_NAME) + ' [' + edg_chg.CURRENT_ICD10_LIST + ']' as 'CHARGE DX'
,emp.NAME as 'USER'
,upper(atcrh.CR_HX_USER_COMMENT) as 'COMMENT'

from PRE_AR_CHG pac 
left join PRE_AR_CHG_2 pac2 on pac2.TAR_ID = pac.TAR_ID and pac2.CHARGE_LINE = pac.CHARGE_LINE
left join PRE_AR_ORG_PX paop on paop.TAR_ID = pac.TAR_ID and paop.LINE = pac.CHARGE_LINE
left join PRE_AR_ORG_DX dx on dx.TAR_ID = pac.TAR_ID and dx.LINE = pac.CHARGE_LINE
left join CLARITY_EDG edg on edg.DX_ID = dx.ORG_DX_ID
left join CLARITY_EAP eap on eap.PROC_ID = pac.PROC_ID 
left join CLARITY_EAP eap_orig on eap_orig.PROC_ID = paop.ORG_CHG_PROC_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = pac.TX_ID and arpb_tx.TX_TYPE_C = 1
left join CHG_REVIEW_DX crd on crd.TAR_ID = pac.TAR_ID and crd.LINE= pac2.CHARGE_LINE
left join CLARITY_EDG edg_chg on edg_chg.DX_ID = crd.DX_ID
left join ARPB_TX_CHG_REV_HX atcrh on atcrh.TX_ID = pac.TX_ID and atcrh.CR_HX_ACTIVITY_C = 2 -- REVIEW
left join CLARITY_EMP emp on emp.USER_ID = atcrh.CR_HX_USER_ID
left join PATIENT pat on pat.PAT_ID = pac.PAT_ID
left join CLARITY_SER ser on ser.PROV_ID = pac.BILL_PROV_ID
left join CLARITY_LOC loc on loc.LOC_ID = pac.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where pac.FILE_DATE >= @start_date
and pac.FILE_DATE <= @end_date
--and pac.TAR_ID in (303143019, 303810489, 303529559, 302651936)
and pac.SERV_AREA_ID in (11,13,16,17,18,19)
and pac.CHARGE_STATUS_C = 2 -- FILED AFTER REVIEW
and pac.TAR_ID = 313179594
order by pac.TAR_ID
,pac.CHARGE_LINE
