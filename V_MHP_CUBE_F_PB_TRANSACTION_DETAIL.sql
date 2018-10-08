USE [ClarityCHPUtil]
GO

/****** Object:  View [Rpt].[V_MHP_CUBE_F_PB_TRANSACTION_DETAIL]    Script Date: 2/23/2016 1:13:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER view [Rpt].[V_MHP_CUBE_F_PB_TRANSACTION_DETAIL]


(
 [TDL_ID]
,[DETAIL_TYPE]
,[TYPE]
,[POST_DATE]
,[ORIGINAL_POST_DATE]
,[SERVICE_DATE]
,[TRANSACTION_ID]
,[TRANSACTION_TYPE]
,[TYPE_OF_SERVICE]
,[ACCOUNT_ID]
,[PATIENT_ID]
,[CURRENT_BENEFIT_PLAN_ID]
,[ORIGINAL_BENEFIT_PLAN_ID]
,[SERVICE_PROVIDER_ID]
,[BILLING_PROVIDER_ID]
,[PROCEDURE_ID]
,[PRIMARY_DIAGNOSIS_ID]
,[DEPARTMENT_ID]
,[LOCATION_ID]
,[PLACE_OF_SERVICE_ID]
,[BILL_AREA_ID]
,[CHARGE_SOURCE]
,[MATCH_TRANSACTION_ID]
,[MATCH_TRANSACTION_TYPE]
,[MATCH_LOCATION_ID]
,[MATCH_PAYOR_ID]
,[MATCH_PROCEDURE_ID]
,[MATCH_PROVIDER_ID]
,[AMOUNT]
,[PATIENT_AMOUNT]
,[INSURANCE_AMOUNT]
,[RELATIVE_VALUE_UNIT]
,[RVU_WORK]
,[RVU_OVERHEAD]
,[RVU_MALPRACTICE]
,[RVU_PROC_UNITS]
,[PROCEDURE_QUANTITY]
,[LAG_DAYS_SERVICE_TO_POST]
,[LAG_DAYS_SERVICE_TO_ENTRY]
,[LAG_DAYS_ENTRY_TO_POST]
,[EXPECTED_AMOUNT]
,[ALLOWED_AMT]
,[CHARGE_AMOUNT]
,[PAYMENT_AMOUNT]
,[MATCHED_PAYMENT_AMOUNT]
,[UNDISTRIBUTED_PAYMENT_AMOUNT]
,[ADJUSTMENT_AMOUNT]
,[CREDIT_ADJUSTMENT_AMOUNT]
,[MATCH_CREDIT_ADJUSTMENT_AMOUNT]
,[UNDIST_CREDIT_ADJUSTMENT_AMT]
,[DEBIT_ADJUSTMENT_AMOUNT]
,[USER_ID]
,[CPT_CODE]
,[PAYMENT_SOURCE]
,[REFERRAL_PROVIDER_ID]
,[TDL_NAMECOLUMN]
,[NET_CHARGE_AMOUNT]
,[VOID_AMOUNT]
,[TRANSACTION_NUMBER]
,[CHARGE_COUNT]
,[ACTIVE_AR_IN_OUT]
,[BAD_DEBT_PAYMENT]
,[BAD_DEBT_CREDIT_ADJUSTMENT]
,[BAD_DEBT_IN_OUT]
,[EXTERNAL_PAYMENT]
,[EXTERNAL_CREDIT_ADJUSTMENT]
,[EXTERNAL_AR_IN_OUT]
,[ORIGINAL_LAG_SERVICE_TO_POST]
,[ORIGINAL_LAG_SERVICE_TO_ENTRY]
,[ORIGINAL_LAG_ENTRY_TO_POST]
,[ORIGINAL_LAG_CHARGE_COUNT]
,[ORIGINAL_PAYOR_ID]
,[CREDIT_DEPARTMENT_ID]
,[CREDIT_BENEFIT_PLAN_ID]
,[CREDIT_ADJUSTMENT_PROCEDURE_ID]
,[DETAIL_TYPE_NAME]
,[TYPE_NAME]
,[DEBIT_ADJUSTMENT_PROCEDURE_ID]
,[CREDIT_LOCATION_ID]
,[SERVICE_AREA_ID]
)
AS
/*Copyright (C) 2015 Epic Systems Corporation
********************************************************************************
TITLE:   V_CUBE_F_TRANSACTION_DETAIL
PURPOSE: Fact table view for TDL with SSAS Cubes
AUTHOR:  Andrew Hilfiger
REVISION HISTORY: 
*amh 11/11 DLG#222358 - created
*rsh 02/12 DLG#230079 - add user_id column, remove tdl_amount column
*rsh 05/12 DLG#233057 - various new columns
*rsh 07/12 DLG#242404 - add original lag day measures, sbo amounts
*rsh 02/13 DLG#260689 - fix issues with self-pay payments
*rsh 05/13 DLG#270718 - remove covered_amount, change tdl.amount to tdl.active_ar_amount
*rsh 07/13 DLG#276998 - fix doubling of allowed amounts
*rsh 03/14 DLG#I8104953 - rewrite procedure columns and other misc updates
*EYZ 06/14 DLG#I8113943 - add match location column
*RSH 05/15 DLG#I8130004 - add service area ID
********************************************************************************
*/
With
first_entry_date as
(
 SELECT tar_id, min(ACTIVITY_DATE) as activity_date from [CLARITY]..PRE_AR_CHG_HX where ACTIVITY_C = 101 
 group by tar_id
) 
SELECT tdl.[TDL_ID]       --1
,tdl.[DETAIL_TYPE]       --2
,tdl.[TYPE]       --3
,tdl.[POST_DATE]           --4
,tdl.[ORIG_POST_DATE]   --5
,tdl.[ORIG_SERVICE_DATE]    --6
,tdl.[TX_ID]    --7
,tran_type.name    --8
,tdl.TYPE_OF_SERVICE    --9
,coalesce(tdl.[ACCOUNT_ID],-1)    --10
,coalesce(tdl.[INT_PAT_ID],'-1')    --11
,coalesce(tdl.[CUR_PLAN_ID],-1)    --12
,CASE 
WHEN (tdl.detail_type in (1,10,20,21) OR tdl.[ORIGINAL_PAYOR_ID] is null) then coalesce(tdl.[ORIGINAL_PLAN_ID],-2) 
ELSE COALESCE(tdl.[ORIGINAL_PLAN_ID],-1) END ORIGINAL_BENEFIT_PLAN_ID    --13
,coalesce(tdl.[PERFORMING_PROV_ID],'-1')    --14
,coalesce(tdl.[BILLING_PROVIDER_ID],'-1')    --15
,case when tdl.detail_type in (1,10,20,21) then coalesce(tdl.[PROC_ID],-1) else -3 end    --16
,coalesce(tdl.[DX_ONE_ID],-1)    --17
,coalesce(tdl.[DEPT_ID],-1)    --18
,coalesce(tdl.[LOC_ID],-2)    --19
,coalesce(tdl.[POS_ID],-3)    --20
,coalesce(tdl.[BILL_AREA_ID],-1)    --21
,coalesce(ucl.CHARGE_SOURCE_C,'8')    --22
,tdl.[MATCH_TRX_ID]    --23
,tdl.MATCH_TX_TYPE    --24
,coalesce(tdl.[MATCH_LOC_ID],-2)    --25
,case when tdl.detail_type in (20,21,22,23) then coalesce(tdl.[MATCH_PAYOR_ID],-1) else coalesce(tdl.ORIGINAL_PAYOR_ID,-1) end    --26
,case 
When tdl.DETAIL_TYPE in (2,5,11,32,33) then coalesce(tdl.PROC_ID,-1)
When tdl.DETAIL_TYPE in (20,22) AND (reversal_check.IS_REVERSED_C is null AND arpb2_match.REVERSED_PMT_TX_ID is null) then coalesce(tdl.MATCH_PROC_ID,-1)
When tdl.DETAIL_TYPE in (20,22) AND (reversal_check.IS_REVERSED_C is null AND arpb2_match.REVERSED_PMT_TX_ID is not null) then coalesce(tdl.PROC_ID,-1)
When tdl.DETAIL_TYPE in (20,22) AND (reversal_check.IS_REVERSED_C is not null) then coalesce(tdl.PROC_ID,-1)
ELSE -2 end  --27
,coalesce(tdl.[MATCH_PROV_ID],'-1')    --28
,tdl.[ACTIVE_AR_AMOUNT]    --29
,tdl.[PATIENT_AMOUNT]    --30
,tdl.[INSURANCE_AMOUNT]    --31
,case when tdl.detail_type in (1,10) then tdl.[RELATIVE_VALUE_UNIT] else 0 end    --32
,case when tdl.detail_type in (1,10) then tdl.[RVU_WORK]*tdl.[PROCEDURE_QUANTITY] else 0 end    --33
,case when tdl.detail_type in (1,10) then tdl.[RVU_OVERHEAD]*tdl.[PROCEDURE_QUANTITY] else 0 end    --34
,case when tdl.detail_type in (1,10) then tdl.[RVU_MALPRACTICE]*tdl.[PROCEDURE_QUANTITY] else 0 end    --35
,CASE WHEN tdl.DETAIL_TYPE = 1 THEN tdl.[RVU_PROC_UNITS]  WHEN tdl.DETAIL_TYPE=10 THEN tdl.[RVU_PROC_UNITS]*-1 END    --36
,tdl.[PROCEDURE_QUANTITY]    --37
,CASE
 WHEN tdl.DETAIL_TYPE in (1,10) THEN
  CASE 
  WHEN tdl.DETAIL_TYPE in (1) 
  THEN 
    CASE
    WHEN cast(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] as integer) < 0 
    THEN 0 
    ELSE cast(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] as integer) 
    END 
  WHEN tdl.DETAIL_TYPE in (10)
  THEN
    CASE
    WHEN - cast(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] as integer) > 0 
    THEN 0 
    ELSE - cast(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] as integer) 
    END
   END 
  END    --38
,null    --39
,null    --40
,case 
 when tdl.detail_type in (1) then coalesce(tdl.ALLOWED_AMOUNT,0) 
 when tdl.detail_type in (10) then -1*coalesce(tdl.ALLOWED_AMOUNT,0)
else 0 end    --41
,0    --42
,CASE WHEN tdl.DETAIL_TYPE IN (1) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as CHARGE_AMOUNT    --43
,CASE WHEN tdl.DETAIL_TYPE IN (2,5,11,20,22,32,33) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as PAYMENT_AMOUNT    --44
,CASE WHEN tdl.DETAIL_TYPE IN (5,20,22) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as MATCHED_PAYMENT_AMOUNT    --45
,CASE WHEN tdl.DETAIL_TYPE IN (2,11,32,33) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as UNDISTRIBUTED_PAYMENT_AMOUNT    --46
,CASE WHEN tdl.DETAIL_TYPE IN (3,4,6,12,13,21,23,30,31) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as ADJUSTMENT_AMOUNT    --47
,CASE WHEN tdl.DETAIL_TYPE IN (4,6,13,21,23,30,31) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as CREDIT_ADJUSTMENT_AMOUNT    --48
,CASE WHEN tdl.DETAIL_TYPE IN (6,21,23) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as MATCH_CREDIT_ADJUSTMENT_AMOUNT    --49
,CASE WHEN tdl.DETAIL_TYPE IN (4,13,30,31) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as UNDIST_ADJUSTMENT_AMT    --50
,CASE WHEN tdl.DETAIL_TYPE IN (3,12) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as DEBIT_ADJUSTMENT_AMOUNT    --51
,Case when tdl.detail_type in (20,21,22,23) then coalesce(arpb_match.user_id,'-1') else coalesce(tdl.user_id,'-1') end    --52
,coalesce(tdl.CPT_CODE,'Unspecified CPT Code')    --53
,coalesce(paysrc.name,'Unspecified Payment Source')    --54
,coalesce(ref.REF_PROVIDER_ID,'-1')    --55
,''    --56
,CASE WHEN tdl.DETAIL_TYPE IN (1,10) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as NET_CHARGE_AMOUNT    --57
,CASE WHEN tdl.DETAIL_TYPE IN (10) THEN tdl.ACTIVE_AR_AMOUNT ELSE 0 END as VOID_AMOUNT    --58
,tdl.[TX_NUM]    --59
, CASE WHEN tdl.DETAIL_TYPE=1 THEN 1
       WHEN tdl.DETAIL_TYPE=10 THEN -1
       ELSE 0 END as CHARGE_COUNT    --60
,CASE WHEN TDL.DETAIL_TYPE IN (20,21,22,23) AND hx.AR_CLASS_C IN (3,4) then TDL.ACTIVE_AR_AMOUNT ELSE 0 END as ACTIVE_AR_IN_OUT    --61
,CASE WHEN TDL.DETAIL_TYPE IN (20,22) then TDL.BAD_DEBT_AR_AMOUNT ELSE 0 END as BAD_DEBT_PAYMENT    --62
,CASE WHEN TDL.DETAIL_TYPE IN (21,23) AND (hx.AR_CLASS_C is null OR hx.AR_CLASS_C NOT IN (3,4)) then TDL.BAD_DEBT_AR_AMOUNT ELSE 0 END as BAD_DEBT_CREDIT_ADJUSTMENT    --63
,CASE WHEN TDL.DETAIL_TYPE IN (20,21,22,23) AND hx.AR_CLASS_C IN (3,4) then TDL.BAD_DEBT_AR_AMOUNT ELSE 0 END as BAD_DEBT_IN_OUT    --64
,CASE WHEN TDL.DETAIL_TYPE IN (20,22) THEN TDL.EXTERNAL_AR_AMOUNT ELSE 0 END as EXTERNAL_PAYMENT    --65
,CASE WHEN TDL.DETAIL_TYPE IN (21,23) AND (hx.AR_CLASS_C is null OR hx.AR_CLASS_C NOT IN (3,4)) THEN TDL.EXTERNAL_AR_AMOUNT ELSE 0 END as EXTERNAL_CREDIT_ADJUSTMENT    --66
,CASE WHEN TDL.DETAIL_TYPE IN (20,21,22,23) AND hx.AR_CLASS_C IN (3,4) THEN TDL.EXTERNAL_AR_AMOUNT ELSE 0 END as EXTERNAL_AR_IN_OUT    --67
,CASE WHEN tdl.DETAIL_TYPE in (1) and (void.OLD_ETR_ID IS NULL AND void.REPOSTED_ETR_ID IS NULL)
 THEN 
  CASE WHEN cast(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] as integer) < 0 
  THEN 0 
  ELSE cast(tdl.[ORIG_POST_DATE] - tdl.[ORIG_SERVICE_DATE] as integer) 
  END
 END as ORIGINAL_LAG_SERVICE_TO_POST    --68
,CASE WHEN tdl.DETAIL_TYPE in (1) and (void.OLD_ETR_ID IS NULL AND void.REPOSTED_ETR_ID IS NULL) 
 THEN 
  CASE WHEN cast(fed.[ACTIVITY_DATE] - tdl.[ORIG_SERVICE_DATE] as integer) < 0 
  THEN 0 
  ELSE cast(fed.[ACTIVITY_DATE] - tdl.[ORIG_SERVICE_DATE] as integer) 
 END    
END as ORIGINAL_LAG_SERVICE_TO_ENTRY --69
,CASE WHEN tdl.DETAIL_TYPE in (1) and (void.OLD_ETR_ID IS NULL AND void.REPOSTED_ETR_ID IS NULL) 
 THEN 
  CASE WHEN cast(tdl.[ORIG_POST_DATE] - fed.[ACTIVITY_DATE] as integer) < 0 
  THEN 0 
  ELSE cast(tdl.[ORIG_POST_DATE] - fed.[ACTIVITY_DATE] as integer) 
  END
 END as ORIGINAL_LAG_ENTRY_TO_POST       --70
,CASE WHEN tdl.DETAIL_TYPE=1 and (void.OLD_ETR_ID IS NULL AND void.REPOSTED_ETR_ID IS NULL) THEN 1
       ELSE 0 END as ORIGINAL_LAG_CHARGE_COUNT       --71
,coalesce(tdl.original_payor_id,-2) ORIGINAL_PAYOR_ID       --72
,case when tdl.detail_type in (20,21,22,23) then coalesce(arpb_match.department_id,-1) else coalesce(tdl.dept_id,-1) end       --73
,-1.00       --74
,case 
When tdl.DETAIL_TYPE in (4,6,13,30,31) then tdl.PROC_ID 
When tdl.DETAIL_TYPE in (21,23) AND reversal_check.IS_REVERSED_C is null then tdl.MATCH_PROC_ID 
When tdl.DETAIL_TYPE in (21,23) AND reversal_check.IS_REVERSED_C is not null then tdl.PROC_ID 
ELSE -4 end --75
,case 
when tdl.detail_type=1 then 'New Charge [1]'
when tdl.detail_type=2 then 'New Payment [2]'
when tdl.detail_type=3 then 'New Debit Adjustment [3]'
when tdl.detail_type=4 then 'New Credit Adjustment [4]'
when tdl.detail_type=5 then 'Payment Reversal [5]'
when tdl.detail_type=6 then 'Credit Adjustment Reversal [6]'
when tdl.detail_type=10 then 'Voided Charge [10]'
when tdl.detail_type=11 then 'Voided Payment [11]'
when tdl.detail_type=12 then 'Voided Debit Adjustment [12]'
when tdl.detail_type=13 then 'Voided Credit Adjustment [13]'
when tdl.detail_type=20 then 'Match/Unmatch (Charge -> Payment) [20]' 
when tdl.detail_type=21 then 'Match/Unmatch (Charge -> Credit Adjustment) [21]'
when tdl.detail_type=22 then 'Match/Unmatch (Debit Adjustment -> Payment) [22]'
when tdl.detail_type=23 then 'Match/Unmatch (Debit Adjustment -> Credit Adjustment) [23]'
when tdl.detail_type=30 then 'Match/Unmatch (Credit Adjustment -> Charge) [30]'
when tdl.detail_type=31 then 'Match/Unmatch (Credit Adjustment -> Debit Adjustment) [31]'
when tdl.detail_type=32 then 'Match/Unmatch (Payment -> Charge) [32]'
when tdl.detail_type=33 then 'Match/Unmatch (Payment -> Debit Adjustment) [33]'
end DETAIL_TYPE_NAME  --76
,case 
when tdl.detail_type in (1,3,4) then 'Post'
when tdl.detail_type in (2) and tx2.REVERSED_PMT_TX_ID is null then 'Post'
when tdl.detail_type in (2) and tx2.REVERSED_PMT_TX_ID is not null then 'Void/Reversal'
when tdl.detail_type in (5,6,10,11,12,13) then 'Void/Reversal'
when tdl.detail_type in (20,21,22,23) then 'Distribution - Service'
when tdl.detail_type in (30,31,32,33) then 'Distribution - Undistributed'
end [Type] --77
,Case
when tdl.detail_type in (3,12,22,23) then coalesce(tdl.proc_id,-1)
else -5 end --78
,case when tdl.detail_type in (20,21,22,23) then coalesce(arpb_match.loc_id,-2) else coalesce(tdl.loc_id,-2) end       --79
,coalesce(tdl.serv_area_id,-1) --80
FROM [CLARITY]..[CLARITY_TDL_TRAN] tdl
left outer join [CLARITY]..ARPB_TRANSACTIONS tx
on tdl.TX_ID = tx.TX_ID
left outer join [CLARITY]..CLARITY_UCL ucl
on tx.CHG_ROUTER_SRC_ID = ucl.UCL_ID
left outer join [CLARITY]..ARPB_TX_MODERATE moderate
on tdl.TX_ID = moderate.TX_ID
left outer join [CLARITY]..ARPB_AGING_HISTORY hx
on hx.tx_id=tdl.match_trx_id AND tdl.post_date>=hx.SNAP_START_DATE and tdl.POST_DATE<=HX.SNAP_END_DATE
left outer join [CLARITY]..ARPB_TX_VOID void 
on tdl.tx_ID=void.TX_ID
left outer join first_entry_date fed 
on fed.TAR_ID=moderate.ORIGINATING_TAR_ID
left outer join [CLARITY]..ZC_PAYMENT_SOURCE paysrc
on tdl.payment_source_c=paysrc.payment_source_c
left outer join [CLARITY]..ARPB_TRANSACTIONS arpb_match
on tdl.match_trx_id=arpb_match.tx_id
left outer join [CLARITY]..ZC_TRAN_TYPE tran_type
on tdl.tran_type = tran_type.tran_type
left outer join [CLARITY]..ARPB_TRANSACTIONS2 tx2
on tdl.TX_ID = tx2.TX_ID
left outer join [CLARITY]..ARPB_TRANSACTIONS2 arpb2_match on arpb2_match.tx_id=tdl.match_trx_id
left outer join [CLARITY]..ARPB_TX_MATCH_HX match_hx on tdl.tx_id=match_hx.tx_id and tdl.matcH_trx_id=match_hx.mtch_tx_hx_id and match_hx.MTCH_TX_HX_UN_DT is null AND TDL.ACTION_MATCH_LINE = match_hx.LINE
left outer join [CLARITY]..ARPB_TX_VOID reversal_check on match_hx.mtch_tx_hx_id = reversal_check.tx_id
left outer join [CLARITY]..REFERRAL_SOURCE ref on ref.REFERRING_PROV_ID=tdl.referral_source_id
where tdl.DETAIL_TYPE<39 and tdl.tran_type<=3
AND tdl.post_date>=DATEADD(YEAR,-2,DATEADD(YEAR, DATEDIFF(YEAR,0,GETDATE()), 0))

and tdl.serv_area_id in (11,13,16,17,18,19,21)
GO


