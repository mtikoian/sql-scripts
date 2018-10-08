select 
 tdl.TX_ID as 'CHARGE ETR'
,cast(tdl.ORIG_SERVICE_DATE as date) as 'SERVICE DATE'
,cast(tdl.ORIG_POST_DATE as date) as 'POST DATE'
,upper(sa.NAME) as 'REGION'
,upper(loc.LOC_NAME) as 'LOCATION'
,upper(dep.DEPARTMENT_NAME) as 'DEPARTMENT'
,upper(pos.POS_NAME) as 'POS'
,coalesce(epm.PAYOR_NAME,'') as 'ORIGINAL PAYOR'
,eap.PROC_CODE as 'CPT CODE'
,eap.PROC_NAME as 'CPT DESC'
,sum(coalesce(case when tdl.DETAIL_TYPE in (1,10) then tdl.AMOUNT end,0)) as 'CHARGE AMT'
,sum(coalesce(case when tdl.DETAIL_TYPE = 20 then tdl.AMOUNT end,0))*-1 as 'PAYMENT AMT'
,sum(coalesce(case when tdl.DETAIL_TYPE = 21 then tdl.AMOUNT end,0))*-1 as 'ADJUSTMENT AMT'
,sum(cvd_amt) as 'CVD AMT'
--,sum(coalesce(case when tdl.ORIGINAL_PAYOR_ID = tdl.MATCH_PAYOR_ID then eob.NONCVD_AMT end,0)) as 'NONCVD AMT'
--,sum(coalesce(case when tdl.ORIGINAL_PAYOR_ID = tdl.MATCH_PAYOR_ID then eob.DED_AMT end,0)) as 'DED AMT'
--,sum(coalesce(case when tdl.ORIGINAL_PAYOR_ID = tdl.MATCH_PAYOR_ID then eob.COPAY_AMT end,0)) as 'COPAY AMT'
--,sum(coalesce(case when tdl.ORIGINAL_PAYOR_ID = tdl.MATCH_PAYOR_ID then eob.COINS_AMT end,0)) as 'COINS AMT'
--,sum(case when detail_type in (1) then arpb_tx.OUTSTANDING_AMT end) as 'OUTSTANDING AMT'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EPM epm on epm.PAYOR_ID = tdl.ORIGINAL_PAYOR_ID
left join CLARITY_LOC loc on loc.LOC_ID = tdl.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = tdl.DEPT_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_POS pos on pos.POS_ID = tdl.POS_ID
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID
left join PMT_EOB_INFO_I eob on eob.TDL_ID = tdl.TDL_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = tdl.TX_ID

where 
tdl.DETAIL_TYPE in (1,10,20,21)
and tdl.TX_ID = 152962915
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and tdl.AMOUNT <> 0
and tdl.ORIG_POST_DATE >= '1/1/2017'
and tdl.ORIG_POST_DATE <= '1/31/2017'

group by 
 tdl.TX_ID
,tdl.ORIG_SERVICE_DATE
,tdl.ORIG_POST_DATE
,sa.NAME
,loc.LOC_NAME
,dep.DEPARTMENT_NAME
,pos.POS_NAME
,epm.PAYOR_NAME
,eap.PROC_CODE
,eap.PROC_NAME

order by 
 tdl.TX_ID