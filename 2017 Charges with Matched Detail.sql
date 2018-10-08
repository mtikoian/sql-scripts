--charges for 2017 and matched EOB  Detail. Include Payor, Place of Service, DOS, Date Posted, Location .Need Charge, EOB Allowed Amount, Payments, and Adjustments,  Outstanding AR. This is for Ensemble. 

with charges as
(
select
 tdl.TX_ID
,tdl.ORIG_SERVICE_DATE
,tdl.POST_DATE
,tdl.LOC_ID
,tdl.DEPT_ID
,tdl.POS_ID
,tdl.ORIGINAL_PAYOR_ID
,tdl.PROC_ID
,tdl.AMOUNT

from CLARITY_TDL_TRAN tdl
left join ARPB_TRANSACTIONS void on void.TX_ID = tdl.TX_ID

where tdl.DETAIL_TYPE in (1,10)
and void.VOID_DATE is null
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
and tdl.POST_DATE >= '1/1/2017'
and tdl.POST_DATE <= '1/31/2017'
--and tdl.TX_ID = 152693947
and tdl.AMOUNT <> 0
)

select 
 charges.TX_ID as 'CHARGE ETR'
,max(cast(charges.ORIG_SERVICE_DATE as date)) as 'SERVICE DATE'
,max(cast(charges.POST_DATE as date)) as 'CHG POST DATE'
,max(upper(sa.NAME)) as 'REGION'
,max(loc.LOC_NAME) as 'LOCATION'
,max(dep.DEPARTMENT_NAME) as 'DEPARTMENT'
,max(pos.POS_NAME) as 'POS'
,max(eap_chg.PROC_CODE) as 'CPT CODE'
,max(eap_chg.PROC_NAME) as 'CPT DESC'
,max(charges.AMOUNT) as 'CHG AMT'
--,match.MTCH_TX_HX_ID as 'MATCHED ETR'
--,cast(arpb_tx.POST_DATE as date) as 'MATCHED POST DATE'
--,coalesce(epm.PAYOR_NAME,'') as 'TRANSACTION PAYOR'
--,match.MTCH_TX_HX_EOB_LINE
--,match.MTCH_TX_HX_AMT as 'MATCHED AMT'
,max(coalesce(epm.PAYOR_NAME,'')) as 'ORIGINAL PAYOR'
,sum(case when arpb_tx.TX_TYPE_C = 2 then match.MTCH_TX_HX_AMT else 0 end) as 'PAYMENT AMT'
,sum(case when arpb_tx.TX_TYPE_C = 3 then match.MTCH_TX_HX_AMT else 0 end) as 'ADJUSTMENT AMT'
--,eap.PROC_NAME as 'MATCHED PROCEDURE'
,sum(coalesce(eob.CVD_AMT,0)) as 'CVD AMT'
,sum(coalesce(eob.NONCVD_AMT,0)) as 'NONCVD AMT'
,sum(coalesce(eob.DED_AMT,0)) as 'DED AMT'
,sum(coalesce(eob.COPAY_AMT,0)) as 'COPAY AMT'
,sum(coalesce(eob.COINS_AMT,0)) as 'COINS AMT'
,max(coalesce(arpb_charge.OUTSTANDING_AMT,0)) as 'OUTSTANDING AMT'

from charges
left join ARPB_TX_MATCH_HX match on match.TX_ID = charges.TX_ID
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.TX_ID = match.MTCH_TX_HX_ID
left join PMT_EOB_INFO_I eob on eob.TX_ID = match.MTCH_TX_HX_ID and eob.LINE = match.MTCH_TX_HX_EOB_LINE
left join CLARITY_POS pos on pos.POS_ID = charges.POS_ID
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = charges.ORIGINAL_PAYOR_ID
left join ARPB_TRANSACTIONS arpb_charge on arpb_charge.TX_ID = charges.TX_ID
left join CLARITY_EAP eap_chg on eap_chg.PROC_ID = charges.PROC_ID
left join CLARITY_LOC loc on loc.LOC_ID = charges.LOC_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = charges.DEPT_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where match.MTCH_TX_HX_AMT <> 0

group by charges.TX_ID
order by charges.TX_ID