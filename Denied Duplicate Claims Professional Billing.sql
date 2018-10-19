select

TX_ID
,ht.HSP_ACCOUNT_ID
,acct.GUARANTOR_ID
from HSP_TRANSACTIONS ht
left join HSP_ACCOUNT acct on acct.HSP_ACCOUNT_ID = ht.HSP_ACCOUNT_ID

where TX_ID = 59112249



select * from 
CLARITY_TDL_TRAN where ACCOUNT_ID = 101124495
and orig_service_Date = '5/3/2018'
and detail_type = 20
and modifier_one = '26'