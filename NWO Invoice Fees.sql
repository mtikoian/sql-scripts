select
 tdl.TX_ID as 'Charge ID'
,tdl.ORIG_SERVICE_DATE as 'Date of Service'
,tdl.MATCH_TRX_ID as 'Payment ID'
,tdl.POST_DATE as 'Date of Payment'
,eap.PROC_NAME + ' [' + eap.PROC_CODE + ']' as 'Payment Type'
,tdl.AMOUNT * - 1as 'Payment Amount'
,datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) as 'AR Days'
,case when datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) <= 90 then '0-90'
      when datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) >= 91 and datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) <= 120 then '91-120' 
	  when datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) >= 121 and datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) <= 180 then '121-180' 
	  when datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) >= 181 then '181+'
	  else '' end as 'AR Bucket'
,case when datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) <= 90 then tdl.AMOUNT * .05 * -1
      when datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) >= 91 and datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) <= 120 then tdl.AMOUNT * .06 * -1
	  when datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) >= 121 and datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) <= 180 then tdl.AMOUNT * .07 * -1 
	  when datediff(d,tdl.ORIG_SERVICE_DATE,tdl.POST_DATE) >= 181 then tdl.AMOUNT * .07 * -1
	  else '' end as 'Invoice Fee'
,eap2.PROC_NAME + ' [' + eap2.PROC_CODE + ']' as 'Procedure'
,sa.SERV_AREA_NAME + ' [' + cast(sa.SERV_AREA_ID as nvarchar) + ']' as 'Service Area'
,loc.LOC_NAME + ' [' + cast(loc.LOC_ID as nvarchar) + ']' as 'Location'
,dep.DEPARTMENT_NAME + ' [' + cast(dep.DEPARTMENT_ID as nvarchar) + ']' as 'Department'
,ser.PROV_NAME + ' [' + ser.PROV_ID + ']' as 'Billing Provider'
,id.IDENTITY_ID as 'Patient MRN'
,pat.PAT_NAME as 'Patient Name'
,acct.ACCOUNT_ID as 'Account ID'
,acct.ACCOUNT_NAME as 'Account Name'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.MATCH_PROC_ID
left join CLARITY_EAP eap2 on eap2.PROC_ID = tdl.PROC_ID
left join CLARITY_SA sa on sa.SERV_AREA_ID = tdl.SERV_AREA_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
left join IDENTITY_ID id on id.PAT_ID = tdl.INT_PAT_ID
left join PATIENT pat on pat.PAT_ID = tdl.INT_PAT_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = tdl.ACCOUNT_ID

where tdl.SERV_AREA_ID = 1614 -- Northwest Ohio Primary Care

and tdl.DETAIL_TYPE = 20 -- Charge matched to Payment
and tdl.ORIG_SERVICE_DATE <= '11/30/2018'
and tdl.POST_DATE >= '12/1/2018'
and tdl.POST_DATE <= '2/28/2019'
and id.IDENTITY_TYPE_ID = 0

order by tdl.TX_ID