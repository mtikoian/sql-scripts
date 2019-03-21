select

 inv.INVOICE_ID
,ibi.INV_NUM
,ibi.EAF_POS_ID
,addl.POS_CODE
,addl.MODIFIER_ONE
,pos.POS_TYPE
,addl.TRANSACTION_LIST
,addl.FROM_SVC_DATE
from INVOICE inv
left join INV_BASIC_INFO ibi on ibi.INV_ID = inv.INVOICE_ID
left join INV_CLM_LN_ADDL addl on addl.INVOICE_ID = inv.INVOICE_ID
left join CLARITY_POS pos on pos.POS_ID = ibi.EAF_POS_ID
where addl.MODIFIER_ONE = 'GT'

and addl.FROM_SVC_DATE >= '1/1/2019'