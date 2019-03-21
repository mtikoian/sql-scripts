select
 age.TX_ID as 'Transaction ID'
,ztt.NAME as 'Transaction Type'
,det.NAME as 'Credit\Debit'
,pat.PAT_MRN_ID as 'Patient MRN'
,pat.PAT_NAME as 'Patient Name'
,acct.ACCOUNT_ID as 'Account ID'
,acct.ACCOUNT_NAME as 'Account Name'
,upper(sa.NAME) as 'Region'
,loc.LOC_NAME as 'Location'
,dep.DEPARTMENT_Name as 'Departmetn'
,cast(age.ORIG_SERVICE_DATE as date) as 'Service Date'
,cast(age.ORIG_POST_DATE as date) as 'Post Date'
,cast(age.POST_DATE as date) as 'Aging Date'
,datediff(d,age.ORIG_SERVICE_DATE,age.POST_DATE) as 'Aging Days by Service Date'
,datediff(d,age.ORIG_POST_DATE,age.POST_DATE) as 'Aging Days by Post Date'
,orig_epm.PAYOR_ID as 'Original Payor ID'
,orig_epm.PAYOR_NAME as 'Original Payor'
,curr_epm.PAYOR_ID as 'Current Payor ID'
,curr_epm.PAYOR_NAME as 'Current Payor'
,age.AMOUNT as 'Outstanding Amount'

from CLARITY_TDL_AGE age
left join PATIENT pat on pat.PAT_ID = age.INT_PAT_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = age.ACCOUNT_ID
left join ZC_DETAIL_TYPE det on det.DETAIL_TYPE = age.DETAIL_TYPE
left join CLARITY_EPM orig_epm on orig_epm.PAYOR_ID = age.ORIGINAL_PAYOR_ID
left join CLARITY_EPM curr_epm on curr_epm.PAYOR_ID = age.CUR_PAYOR_ID
left join ZC_TRAN_TYPE ztt on ztt.TRAN_TYPE = age.TRAN_TYPE
left join CLARITY_LOC loc on loc.LOC_ID = age.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = age.DEPT_ID
where age.POST_DATE = '12/31/2018'
and age.SERV_AREA_ID in (11,13,16,17,18,19)

order by age.ORIG_SERVICE_DATE