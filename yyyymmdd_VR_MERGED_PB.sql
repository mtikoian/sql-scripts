DECLARE @START_DATE AS DATE = EPIC_UTIL.EFN_DIN('06/30/2014')
DECLARE @END_DATE AS DATE = EPIC_UTIL.EFN_DIN('08/31/2014')

select 

DISTINCT
COALESCE(TDL.DEPT_ID,000000000) AS COMPANY_CODE
,COALESCE(CAST(TDL.TX_ID AS VARCHAR(10)),'000000000') + '-' + COALESCE(CAST(TDL.ACCOUNT_ID AS VARCHAR(10)),'000000000') AS NEW_RCA_ACCOUNT_NUMBER
,COALESCE(CAST(TDL.TX_ID AS VARCHAR(10)),'000000000') + '-' + COALESCE(CAST(acct_merge.merge_account_id AS VARCHAR(10)),'000000000') AS OLD_RCA_ACCOUNT_NUMBER

from clarity_tdl_tran tdl
inner join acct_merge on acct_merge.account_id = tdl.account_id

where post_date >= @START_DATE
and post_date <= @END_DATE
and detail_type IN (3,12,2,5,11,20,22,32,33,4,6,13,21,23,30,31)
and tdl.serv_area_id in (11,13,16,17,18,19)
and acct_merge.merge_date >= @START_DATE
and amount <> 0


union 


SELECT       COALESCE(TDL.DEPARTMENT_ID,000000000) AS COMPANY_CODE
            ,COALESCE(CAST(TDL.TX_ID AS VARCHAR(10)),'000000000') + '-' + COALESCE(CAST(TDL.ACCOUNT_ID AS VARCHAR(10)),'000000000') AS OLD_RCA_ACCOUNT_NUMBER
            ,COALESCE(CAST(VDL.TX_ID AS VARCHAR(10)),'000000000') + '-' + COALESCE(CAST(TDL.ACCOUNT_ID AS VARCHAR(10)),'000000000') AS NEW_RCA_ACCOUNT_NUMBER

FROM        ARPB_TRANSACTIONS               TDL
            INNER JOIN ARPB_TX_VOID                  VDL  ON TDL.TX_ID = VDL.OLD_ETR_ID

WHERE       tdl.void_date >= @start_date
			and tdl.void_date <= @end_date
			and tdl.service_area_id in (11,13,16,17,18,19)

