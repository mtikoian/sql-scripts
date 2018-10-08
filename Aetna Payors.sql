/*We need a report for all Aetna payers of the top 50 CPT codes (volume and dollars) with the corresponding allowed amount. 
I'm going to ask managed care for a report of the contracted rates for the same codes so we can bump the reports 
up against each other. Of course, the turnaround time is quick. We need to report back by 5/9 so we need to have the report 
finished by then.
*/

select 
 'AETNA' as 'PAYOR'
,epm.PAYOR_NAME
,eap.PROC_NAME
,eap.PROC_CODE
,sum(tdl.ORIG_AMT) as 'CHARGE_AMOUNT'
,sum(eob.CVD_AMT) as 'ALLOWED_AMOUNT'
,count(tdl.TX_ID) as 'COUNT'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join PMT_EOB_INFO_I eob on eob.TDL_ID = tdl.TDL_ID

where tdl.DETAIL_TYPE in (20)
and tdl.ORIGINAL_PAYOR_ID in (1003,2222,3004,4239,4240,4309,4329,4358,4359)
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and tdl.ORIG_SERVICE_DATE >= '1/1/2017'
and tdl.ORIG_SERVICE_DATE <= '3/31/2018'
group by
 epm.PAYOR_NAME
,eap.PROC_NAME
,eap.PROC_CODE