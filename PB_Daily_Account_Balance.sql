insert into rpt.PB_DAILY_ACCOUNT_PATIENT_BALANCE

select 
 acct.ACCOUNT_ID
,acct.PATIENT_BALANCE
,acct.HB_SELFPAY_BALANCE
,cast(getdate() as date) as UPDATE_DATE
from CLARITY.dbo.ACCOUNT acct
where PATIENT_BALANCE <> 0 or HB_SELFPAY_BALANCE <> 0
;