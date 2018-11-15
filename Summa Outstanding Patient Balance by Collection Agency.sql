--237082

select 
 sa.SERV_AREA_NAME as 'REGION'
,arpb_tx.ACCOUNT_ID as 'ACCOUNT'
,cast(arpb_tx.SERVICE_DATE as date) as 'SERVICE DATE'
,cast(arpb_tx.POST_DATE as date) as 'POST DATE'
,cast(atm.FIRST_SELFPAY_DATE as date) as 'FIRST SELFPAY DATE'
,atm.EXT_CUR_AGENCY_ID as 'COLL AGENCY ID'
,col.COLL_AGENCY_NAME as 'COLL AGENCY'
,arpb_tx.PATIENT_AMT as 'OUSTANDING PATIENT AMT'
,wq.WORKQUEUE_NAME as 'WORKQUEUE'
,cast(acct.ASSIGNED_DATE as date) as 'ASSIGNED DATE'
,cast(acct.COMPLETED_DTTM as date) as 'COMPLETED DATE'
,epm.PAYOR_NAME as 'ORIGINAL PAYOR'

from ARPB_TRANSACTIONS arpb_tx
left join ARPB_TX_MODERATE atm on atm.TX_ID = arpb_tx.TX_ID
left join CL_COL_AGNCY col on col.COL_AGNCY_ID = atm.EXT_CUR_AGENCY_ID
left join CLARITY_SA sa on sa.SERV_AREA_ID = arpb_tx.SERVICE_AREA_ID
left join ACCT_WQ_TX_HX acct on acct.TX_ID = arpb_tx.TX_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = arpb_tx.PAYOR_ID
left join ACCT_WQ wq on wq.WORKQUEUE_ID = acct.WORKQUEUE_ID
where arpb_tx.PATIENT_AMT > 0
and arpb_tx.SERVICE_AREA_ID = 1312
--and arpb_tx.tx_id = 214115665 