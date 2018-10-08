declare @start_date as date = EPIC_UTIL.EFN_DIN('t-4')
declare @end_date as date = EPIC_UTIL.EFN_DIN('t-4')

select distinct
-- ucl.CHARGE_SESSION_ID
--,pac2.CHRG_ROUTER_SRC_ID as UCL_ID
 case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD' else upper(sa.NAME) end as 'REGION'
,craa.TAR_ID as 'SESSION ID'
--,craa.DATA_FIELD_LINE
--,pac.CHARGE_LINE
--,pac.CHARGE_LINE as 'CLAIM LINE'
--,zcst.NAME as 'CHARGE SOURCE'
--,zcs.NAME as 'CHARGE STATUS'
--,pac.TX_ID as 'CHARGE ID'
,cast(pacline1.SERVICE_DATE as date) as 'SERVICE DATE'
,cast(pacline1.FILE_DATE as date) as 'FILE DATE'
--,pac.PAT_ID 
,pat.PAT_MRN_ID as 'PATIENT MRN'
,pat.PAT_NAME as 'PATIENT NAME'
,ser.PROV_NAME as 'BILLING PROVIDER'
,case when craa.OLD_VALUE = '<blank>' then '' else craa.OLD_VALUE end as 'ORIGINAL PROCEDURE'
,coalesce(craa.NEW_VALUE,'') as 'CHARGE PROCEDURE'
,case when emp_filed.user_id is not null then emp_filed.NAME else emp.NAME end as 'USER'
,pach.USER_COMMENT as 'COMMENT'

from CHG_REVIEW_ACT_AUD craa
left join PRE_AR_CHG pac on pac.TAR_ID = craa.TAR_ID and pac.CHARGE_LINE = craa.DATA_FIELD_LINE
left join PRE_AR_CHG pacline1 on pacline1.TAR_ID = craa.TAR_ID and pacline1.CHARGE_LINE = 1
left join PRE_AR_CHG_HX pach on pach.TAR_ID = pac.TAR_ID and pach.CHARGE_HX_LINE = pac.CHARGE_LINE
left join PATIENT pat on pat.PAT_ID = pacline1.PAT_ID
left join CLARITY_EAP eap on eap.PROC_ID = pac.PROC_ID
left join PRE_AR_CHG_2 pac2 on pac2.TAR_ID = pac.TAR_ID and pac2.CHARGE_LINE = pac.CHARGE_LINE
left join ZC_CHRG_SOURCE_TAR zcst on zcst.CHARGE_SOURCE_C = pac.CHARGE_SOURCE_C
left join CLARITY_UCL ucl on ucl.UCL_ID = pac2.CHRG_ROUTER_SRC_ID
left join ZC_CHARGE_STATUS zcs on zcs.CHARGE_STATUS_C = pac.CHARGE_STATUS_C
left join CLARITY_SER ser on ser.PROV_ID = pacline1.BILL_PROV_ID
--left join CHG_REVIEW_HX crh on crh.TAR_ID = craa.TAR_ID and crh.CHG_HX_ACTIVITY_C = 2 -- REVIEW
left join CLARITY_EMP emp on emp.user_id = pach.USER_ID
left join CLARITY_EMP emp_filed on emp_filed.user_id = pac.FILE_USER_ID
left join CLARITY_LOC loc on loc.LOC_ID = pacline1.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where craa.DATA_FIELD = 150 -- CHARGE PROCEDURE
--and craa.TAR_ID in (303143019, 303810489, 303529559, 302651936)
and pac.FILE_DATE >= @start_date
and pac.FILE_DATE <= @end_date
and loc.RPT_GRP_TEN in (11,13,16,17,18,19)