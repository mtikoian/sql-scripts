select
 date.MONTHNAME_YEAR as 'MONTH'
,date.YEAR_MONTH as 'YEAR-MONTH'
,loc.REGION
,loc.LOC_NAME as 'LOCATION'
,dep.DEPARTMENT_NAME as 'DEPARTMENT'
,tdl.ORIG_SERVICE_DATE as 'SERVICE DATE'
,tdl.POST_DATE as 'POST DATE'
,tdl.DETAIL_TYPE as 'DETAIL TYPE'
,eap.PROC_CODE as 'CPT CODE'
,eap.PROC_NAME as 'PROCEDURE'
,eap_match.PROC_NAME as 'PROCEDURE - MATCHED'
,case when tdl.DETAIL_TYPE in (1,10) then tdl.AMOUNT end as 'CHARGE'
,case when tdl.DETAIL_TYPE in (1,10) and month(tdl.POST_DATE) = month(tdl.ORIG_SERVICE_DATE) then tdl.AMOUNT else 0 end as 'CURRENT CHARGE'
,(case when tdl.DETAIL_TYPE in (1,10) then tdl.AMOUNT else 0 end) - (case when tdl.DETAIL_TYPE in (1,10) and month(tdl.POST_DATE) = month(tdl.ORIG_SERVICE_DATE) then tdl.AMOUNT else 0 end) as 'LATE CHARGE'
,case when tdl.DETAIL_TYPE in (1,10,3,12,4,6,13,21,23,30,31) then tdl.AMOUNT end as 'NET REVENUE'
,case when tdl.DETAIL_TYPE in (2,5,11,20,22,32,33) then tdl.AMOUNT end *-1 as 'PAYMENT'
,case when tdl.DETAIL_TYPE in (2,5,11,20,22,32,33) then tdl.PATIENT_AMOUNT else 0 end as 'PATIENT PAYMENT'
,case when tdl.DETAIL_TYPE in (2,5,11,20,22,32,33) then tdl.INSURANCE_AMOUNT else 0 end as 'INSURANCE PAYMENT'
,case when tdl.DETAIL_TYPE in (4,6,13,21,23,30,31) then tdl.AMOUNT else 0 end as 'CREDIT ADJUSTMENT'
,case when tdl.DETAIL_TYPE in (3,12) then tdl.AMOUNT else 0 end as 'DEBIT ADJUSTMENT'
,tdl.AMOUNT as 'NET CHANGE IN AR'
,case when tdl.DETAIL_TYPE <= 13 and (eap.GL_NUM_DEBIT in ('BAD','BADRECOVERY') or eap.GL_NUM_CREDIT in ('BAD','BADRECOVERY')) then tdl.AMOUNT end *-1 as 'BAD DEBT'
,case when tdl.DETAIL_TYPE <= 13 and (eap.GL_NUM_DEBIT in ('CHARITY') or eap.GL_NUM_CREDIT in ('CHARITY')) then tdl.AMOUNT end *-1 as 'CHARITY'
,case when eap_match.PROC_CODE in ('4017','4018','4019','4020','4021','3011','3012','3013','3014','3015','3018','3019','3052','5036') then tdl.AMOUNT end *-1 as 'FINAL DENIAL'
,case when tdl.DETAIL_TYPE in (1,10) and fc.FINANCIAL_CLASS_NAME in ('MEDICARE','MEDICARE MANAGED') then tdl.AMOUNT end as 'MEDICARE CHARGE'
,case when tdl.DETAIL_TYPE in (1,10) and fc.FINANCIAL_CLASS_NAME in ('MEDICAID','MEDICAID MANAGED') then tdl.AMOUNT end as 'MEDICAID CHARGE'
,case when tdl.DETAIL_TYPE in (1,10) and fc.FINANCIAL_CLASS_NAME in ('COMMERCIAL','MANAGED CARE') then tdl.AMOUNT end as 'COMMERCIAL CHARGE'
,case when tdl.DETAIL_TYPE in (1,10) and fc.FINANCIAL_CLASS_NAME in ('BX Traditional','BX Managed') then tdl.AMOUNT end as 'BLUE_CROSS CHARGE'
,case when tdl.DETAIL_TYPE in (1,10) and fc.FINANCIAL_CLASS_NAME = 'OTHER' then tdl.AMOUNT end as 'OTHER CHARGE'
,case when tdl.DETAIL_TYPE in (1,10) and fc.FINANCIAL_CLASS_NAME = 'SELF-PAY' then tdl.AMOUNT end as 'SELF PAY CHARGE'

from CLARITY.dbo.CLARITY_TDL_TRAN tdl
left join CLARITY.dbo.CLARITY_EAP eap_match on eap_match.PROC_ID = tdl.MATCH_PROC_ID
left join CLARITY.dbo.CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join CLARITY.dbo.CLARITY_FC fc on fc.FINANCIAL_CLASS = tdl.ORIGINAL_FIN_CLASS
left join CLARITYCHPUTIL.rpt.V_PB_LOCATIONS loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITYCHPUTIL.rpt.V_PB_DEPARTMENTS dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY.dbo.DATE_DIMENSION date on date.CALENDAR_DT = tdl.POST_DATE

where tdl.POST_DATE >= '3/1/2018'
and tdl.POST_DATE <= '5/31/2018'
and tdl.DETAIL_TYPE <= 33
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)