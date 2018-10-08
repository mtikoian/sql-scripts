/*We need a report for all Aetna payers of the top 50 CPT codes (volume and dollars) with the corresponding allowed amount. 
I'm going to ask managed care for a report of the contracted rates for the same codes so we can bump the reports 
up against each other. Of course, the turnaround time is quick. We need to report back by 5/9 so we need to have the report 
finished by then.
*/

select 
 upper(sa.name) as 'REGION'
,loc.LOC_NAME as 'LOCATION'
,dep.DEPARTMENT_NAME as 'DEPARTMENT'
,cast(tdl.ORIG_SERVICE_DATE as date) as 'SERVICE_DATE'
,tdl.TX_ID as 'TX_ID'
,tdl.ACCOUNT_ID
,acct.ACCOUNT_NAME
,'AETNA' as 'PAYOR'
,epm.PAYOR_NAME
,eap.PROC_NAME
,eap.PROC_CODE
,tdl.ORIG_AMT as 'CHARGE_AMOUNT'
,eob.CVD_AMT as 'ALLOWED_AMOUNT'


from CLARITY_TDL_TRAN tdl
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join PMT_EOB_INFO_I eob on eob.TDL_ID = tdl.TDL_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = tdl.ACCOUNT_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where tdl.DETAIL_TYPE in (20)
and tdl.ORIGINAL_PAYOR_ID in (1003,2222,3004,4239,4240,4309,4329,4358,4359)
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and tdl.ORIG_SERVICE_DATE >= '1/1/2017'
and tdl.ORIG_SERVICE_DATE <= '3/31/2018'
