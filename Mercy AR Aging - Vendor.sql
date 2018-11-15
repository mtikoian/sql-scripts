select
*
from
(
select 
 age.tx_id as 'ETR ID'
 ,age.INT_PAT_ID 'PAT ID'
,upper(sa.name) as 'REGION'
--,dep.SPECIALTY as 'DEPARTMENT SPECIALTY'
,spec.NAME as 'PROVIDER SPECIALTY'
,cast(age.orig_service_date as date) as 'SERVICE DATE'
,cast(age.post_date as date) as 'POST DATE'
,datediff(dd,age.orig_service_date, age.post_date) as 'AR Days'
,eap.PROC_CODE as 'PROCEDURE CODE'
,eap.PROC_NAME as 'PROCEDURE DESC'
,age.MODIFIER_ONE as 'MODIFIER 1'
,age.MODIFIER_TWO as 'MODIFIER 2'
,age.MODIFIER_THREE as 'MODIFIER 3'
,age.MODIFIER_FOUR as 'MODIFIER 4'
,edg1.CURRENT_ICD10_LIST as 'DX 1'
,edg2.CURRENT_ICD10_LIST as 'DX 2'
,edg3.CURRENT_ICD10_LIST as 'DX 3'
,edg4.CURRENT_ICD10_LIST as 'DX 4'
,orig_fc.FINANCIAL_CLASS_NAME as 'ORIGINAL FC'
,curr_fc.FINANCIAL_CLASS_NAME as 'CURRENT FC'
,age.ORIG_AMT as 'CHARGE AMT'
,age.amount as 'AR AMOUNT'
,det.TITLE as 'AR TYPE'
,varc.REMIT_CODE_NAME 'REMIT CODE'
,cast(varc.PAYMENT_POST_DATE as date) as 'REMIT DATE'
,varc.PAYOR_FIN_CLASS_NAME as 'FINANCIAL CLASS'
,varc.PAYOR_NAME as 'PAYOR'
,varc.PLAN_NAME as 'PLAN'
,varc.ACTION_LINE as 'LINE'
,ROW# = ROW_NUMBER() OVER (PARTITION BY age.TX_ID ORDER BY varc.ACTION_LINE DESC)

from clarity_tdl_age age
left join clarity_loc loc on loc.loc_id = age.loc_id
left join zc_loc_rpt_grp_10 sa on sa.RPT_GRP_TEN = loc.rpt_grp_ten
left join zc_detail_type det on det.DETAIL_TYPE = age.DETAIL_TYPE
left join clarity_fc orig_fc on orig_fc.FINANCIAL_CLASS = age.ORIGINAL_FIN_CLASS
left join clarity_fc curr_fc on curr_fc.FINANCIAL_CLASS = age.ORIGINAL_FIN_CLASS
left join clarity_eap eap on eap.PROC_ID = age.PROC_ID
left join clarity_edg edg1 on edg1.DX_ID = age.DX_ONE_ID
left join clarity_dep dep on dep.DEPARTMENT_ID = age.DEPT_ID
left join ZC_SPECIALTY spec on spec.SPECIALTY_C = age.PROV_SPECIALTY_C
left join clarity_edg edg2 on edg2.DX_ID = age.DX_TWO_ID
left join clarity_edg edg3 on edg3.DX_ID = age.DX_THREE_ID
left join CLARITY_EDG edg4 on edg4.DX_ID = age.DX_FOUR_ID
left join V_ARPB_REMIT_CODES varc on varc.MATCH_CHG_TX_ID = age.TX_ID

where post_date = '10/31/18'
and loc.RPT_GRP_TEN in (11,13,16,17,18,19)
and datediff(dd,age.orig_service_date, age.post_date) >= 60
and age.ORIG_AMT <= 250
and age.ORIGINAL_FIN_CLASS <> 4 -- REMOVE SELF PAY
and age.ORIG_AMT = age.AMOUNT -- Original Amount = AR Amount
and eap.TYPE_C = 1 -- charge procedures
--and age.TX_ID = 6675041
--and age.TX_ID = 210074214
)a

where ROW# = 1 