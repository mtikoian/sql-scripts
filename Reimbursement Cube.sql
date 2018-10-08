declare @start_date as date = EPIC_UTIL.EFN_DIN('1/1/2016')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select
 date.year_month as 'YEAR-MONTH'
,date.CALENDAR_DT_STR as 'SERVICE DATE'
,sa.name + ' [' + sa.rpt_grp_ten + ']'  as 'REGION'
,loc.rpt_grp_three + ' [' + loc.rpt_grp_two + ']' as 'LOCATION'
,dep.rpt_grp_two + ' [' + dep.rpt_grp_one + ']' as 'DEPARTMENT'
,dep.specialty as 'SPECIALTY'
,pos.rpt_grp_two + ' [' + pos.rpt_grp_one + ']' as 'PLACE OF SERVICE'
,var.pos_type as 'POS TYPE'
,eap.proc_code + ' - ' + eap.proc_name as 'PROCEDURE'
,epm.payor_name + ' [' + cast(epm.payor_id as varchar) + ']' as 'PAYOR'
,var.plan_name + ' [' + cast(var.plan_id as varchar) + ']' as 'PLAN'
,zfc.name + ' [' + cast(zfc.financial_class as varchar) + ']'  as 'FINIANCIAL CLASS'
,ser.prov_name + ' [' + cast(ser.prov_id as varchar) + ']' as 'PROVIDER'
,var.PAYMENT_TX_ID as 'PAYMENT ID'
,var.EOB_ALLOWED_AMOUNT as 'ALLOWED'
,var.EOB_PAID_AMOUNT as 'PAID'
,var.EOB_COPAY_AMOUNT as 'COPAY'
,var.EOB_COINS_AMOUNT as 'CO-INSURANCE'
,var.EOB_COB_AMOUNT as 'COORDINATION OF BENEFITS'
,var.EOB_DEDUCT_AMOUNT as 'DEDUCTIBLE'
,var.EXPECT_REIMB_AMOUNT as 'EXPECTED'
,var.MODIFIER_ONE as 'MODIFIER 1'
,var.MODIFIER_TWO as 'MODIFIER 2'
,var.MODIFIER_THREE as 'MODIFIER 3'
,var.MODIFIER_FOUR as 'MODIFIER 4'
,var.CLAIM_STATUS as 'CLAIM STATUS'
,var.INV_STATUS as 'INVOICE STATUS'
from Clarity.dbo.V_ARPB_REIMBURSEMENT var
left join Clarity.dbo.CLARITY_EPM epm on epm.PAYOR_ID = var.PAYOR_ID
left join Clarity.dbo.ZC_FINANCIAL_CLASS zfc on zfc.FINANCIAL_CLASS = epm.FINANCIAL_CLASS
left join Clarity.dbo.CLARITY_EAP eap on eap.PROC_ID = var.PROC_ID
left join Clarity.dbo.DATE_DIMENSION date on date.CALENDAR_DT_STR = var.SERVICE_DTTM
left join Clarity.dbo.CLARITY_LOC loc on loc.LOC_ID = var.LOC_ID
left join Clarity.dbo.CLARITY_DEP dep on dep.DEPARTMENT_ID = var.DEPT_ID
left join Clarity.dbo.ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join Clarity.dbo.CLARITY_POS pos on pos.POS_ID = var.POS_ID
left join Clarity.dbo.CLARITY_SER ser on ser.PROV_ID = var.PROV_ID
where var.SERVICE_DTTM >= @start_date
and var.SERVICE_DTTM <= @end_date
and sa.RPT_GRP_TEN in (1,11,13,16,17,18,19)
