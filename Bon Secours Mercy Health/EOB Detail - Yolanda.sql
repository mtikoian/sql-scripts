select
-- top 100
 --eob.TDL_ID
 tdl.TX_ID as CHARGE_ETR
,date.YEAR_MONTH_STR as MONTH_OF_SERVICE
,tdl.ORIG_SERVICE_DATE as SERVICE_DATE
,upper(sa.NAME) as REGION
--,tdl.POST_DATE
,eap.PROC_CODE as PROCEDURE_CODE
,eap.PROC_NAME as PROCEDURE_DESC
--,eob.TX_ID as PAYMENT_ETR
--,eob.LINE
,epm.PAYOR_NAME as PRIMARY_PAYOR
,fc.FINANCIAL_CLASS_NAME as FINANCIAL_CLASS
,tdl.ORIG_AMT as CHARGE_AMOUNT
,tdl2.PROCEDURE_QUANTITY as UNITS
,sum(coalesce(eob.CVD_AMT,0)) as ALLOWED_AMT
,sum(coalesce(eob.NONCVD_AMT,0)) as NON_ALLOWED_AMT
,sum(coalesce(eob.DED_AMT,0)) as DEDUCTIBLE_AMT
,sum(coalesce(eob.COPAY_AMT,0)) as COPAY_AMT
,sum(coalesce(eob.COINS_AMT,0)) as COINSURANCE_AMT
,sum(coalesce(eob.COB_AMT,0)) as COB_AMT
--,eob.ACTION_AMT
,sum(coalesce(eob.PAID_AMT,0)) as PAID_AMT
--,rmc_act.REMIT_CODE_NAME as ACT_WIN_RMC
--,rmc_den.REMIT_CODE_NAME as WIN_DENIAL_ID
--,NON_PRIMARY_SYS_YN
--,NON_PRIMARY_USR_YN


from PMT_EOB_INFO_I eob
inner join CLARITY_TDL_TRAN tdl on tdl.TDL_ID = eob.TDL_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY_RMC rmc_act on rmc_act.REMIT_CODE_ID = eob.ACT_WIN_RMC_ID
left join CLARITY_RMC rmc_den on rmc_den.REMIT_CODE_ID = eob.WIN_DENIAL_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.MATCH_PAYOR_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = tdl.ORIG_SERVICE_DATE
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = epm.FINANCIAL_CLASS
left join CLARITY_TDL_TRAN tdl2 on tdl2.TX_ID = tdl.TX_ID and tdl2.DETAIL_TYPE = 1

where tdl.ORIG_SERVICE_DATE >= '1/1/2018'
and tdl.ORIG_SERVICE_DATE <= '8/31/2018'
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and (eob.NON_PRIMARY_SYS_YN <> 'Y' or eob.NON_PRIMARY_SYS_YN is null)
--and tdl.TX_ID = 192988390
--and tdl.TX_ID = 193000880

group by
 --eob.TDL_ID
 tdl.TX_ID
,date.YEAR_MONTH_STR
,tdl.ORIG_SERVICE_DATE
,upper(sa.NAME)
--,tdl.POST_DATE
,eap.PROC_CODE
,eap.PROC_NAME
--,eob.TX_ID as PAYMENT_ETR
--,eob.LINE
,epm.PAYOR_NAME
,fc.FINANCIAL_CLASS_NAME
,tdl.ORIG_AMT
,tdl2.PROCEDURE_QUANTITY