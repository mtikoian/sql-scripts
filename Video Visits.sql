select 

 cast(enc.CONTACT_DATE as date) as 'CONTACT DATE'
,id.IDENTITY_ID as 'MRN'
,enc.PAT_ENC_CSN_ID as 'CSN'
,prc.PRC_ID as 'VISIT ID'
,prc.PRC_NAME as 'VISIT'
,zas.NAME as 'APPT STATUS'
,cast(arpb_tx.SERVICE_DATE as date) as 'SERVICE DATE'
,arpb_tx.TX_ID as 'CHG ID'
,arpb_tx.AMOUNT as 'CHG AMT'
,cast(arpb_tx.VOID_DATE as date) as 'VOID DATE'
,atmh.MTCH_TX_HX_ID as 'MATCHED ID'
,atmh.MTCH_TX_HX_D_CVG_ID
,cvg.PAYOR_ID
,epm.PAYOR_NAME
,atmh.MTCH_TX_HX_AMT
,arpb_tx.OUTSTANDING_AMT

from PAT_ENC enc
left join CLARITY_PRC prc on prc.PRC_ID = enc.APPT_PRC_ID
left join ZC_APPT_STATUS zas on zas.APPT_STATUS_C = enc.APPT_STATUS_C
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID and arpb_tx.TX_TYPE_C = 1
left join ARPB_TX_MATCH_HX atmh on atmh.TX_ID = arpb_tx.TX_ID
left join COVERAGE cvg on cvg.COVERAGE_ID = atmh.MTCH_TX_HX_D_CVG_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = cvg.PAYOR_ID
left join IDENTITY_ID id on id.PAT_ID = enc.PAT_ID


where enc.SERV_AREA_ID = 19
and enc.CONTACT_DATE >= '1/1/2019'
and prc.PRC_ID in ('2102','210110001')
and enc.CONTACT_DATE <= '1/31/2019'
and id.IDENTITY_TYPE_ID = 0
order by enc.CONTACT_DATE