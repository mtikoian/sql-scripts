/*Need a report dating back from 1/1/17 - 6/29/18 which captures the following:

Criteria:
ETR 149 = 11, 13, 16, 17, 18 OR 19 
AND
Where ETR 45 Falls Between (ETR 100 -> EPT 18380 -> LAR 160 (Start Date) & 170 (End Date) OR If LAR 160 & 170 Are Both Blank) AND Where ETR 31 -> TAR 15306 Does not Contain WQ IDs 22735, 22733, 22731, 25255, 27460, 22919, 22738, 20827 OR 22739

I will end up needing a whole load of items from multiple different master files in the output, so hit me up when you can to discuss.
*/

select distinct
 arpb_tx.TX_ID
--,ORIGINATING_TAR_ID
,cast(arpb_tx.SERVICE_DATE as date) as SERVICE_DATE
--,arpb_tx.PATIENT_ID
,upper(sa.NAME) as REGION
,loc.LOC_NAME
,dep.DEPARTMENT_NAME
,pos.POS_NAME
,ser.PROV_NAME as BILLING_PROVIDER
,arpb_tx.ACCOUNT_ID
,acct.ACCOUNT_NAME
,eap.PROC_CODE
,eap.PROC_NAME
,edg1.DX_NAME as DX_1
,edg2.DX_NAME as DX_2
,edg3.DX_NAME as DX_3
,arpb_tx.MODIFIER_ONE
,arpb_tx.MODIFIER_TWO
,enroll.ENROLLMENT_ID
,info.ENROLL_START_DT
,info.ENROLL_END_DT
,pac.WORKQUEUE_ID

from ARPB_TRANSACTIONS arpb_tx
left join PAT_RSH_ENROLL enroll on enroll.PAT_ID = arpb_tx.PATIENT_ID
left join ENROLL_INFO info on info.ENROLL_ID = enroll.ENROLLMENT_ID
left join ARPB_TX_MODERATE atm on atm.TX_ID = arpb_tx.TX_ID
left join PRE_AR_CHG_HX pac on pac.TAR_ID = atm.ORIGINATING_TAR_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = arpb_tx.ACCOUNT_ID
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_EDG edg1 on edg1.DX_ID = arpb_tx.PRIMARY_DX_ID
left join CLARITY_EDG edg2 on edg2.DX_ID = arpb_tx.DX_TWO_ID
left join CLARITY_EDG edg3 on edg3.DX_ID = arpb_tx.DX_THREE_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join CLARITY_POS pos on pos.POS_ID = arpb_tx.POS_ID
left join CLARITY_SER ser on ser.PROV_ID = arpb_tx.BILLING_PROV_ID

where arpb_tx.SERVICE_DATE >= '1/1/2017'
and arpb_tx.SERVICE_DATE <= '6/29/2018'
and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
and arpb_tx.TX_TYPE_C = 1
and arpb_tx.VOID_DATE is null
and enroll.ENROLLMENT_ID is not null
and arpb_tx.AMOUNT > 0
and info.RESEARCH_STUDY_ID <> 53
and ((arpb_tx.SERVICE_DATE >= info.ENROLL_START_DT 
and arpb_tx.SERVICE_DATE <= info.ENROLL_END_DT)
or info.ENROLL_START_DT is null or info.ENROLL_END_DT is null)

--and arpb_tx.TX_ID = 215507707

and (pac.WORKQUEUE_ID not in (22735, 22733, 22731, 25255, 27460, 22919, 22738, 20827, 22739, 28483)
or pac.WORKQUEUE_ID is null)
