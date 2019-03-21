select
 sa.SERV_AREA_NAME as 'Service Area'
,acct.ACCOUNT_ID as 'Account ID'
,acct.ACCOUNT_NAME as 'Account Name'
,inv.INVOICE_ID as 'Invoice ID'-- INV .1
,ibi.INV_NUM as 'Invoice Number'-- INV.101
,ibi.FROM_SVC_DATE as 'Service Date'-- INV. 106
,inv.INSURANCE_AMT as 'Insurance Amount'-- INV. 71
,inv.INIT_INSURANCE_BAL as 'Initial Insurance Balance'-- INV. 73
,ibi.FDF_ID as 'Electronic Claim Form ID'
,ecf.ELEC_FORM_NAME as 'Electronic Claim Form'-- INV. 109
,epm.PAYOR_ID as 'Payor ID'
,epm.PAYOR_NAME as 'Payor' -- INV. 104
,ibi.TAX_ID_NUM as 'Tax ID' -- INV. 186

from INVOICE inv
left join INV_BASIC_INFO ibi on ibi.INV_ID = inv.INVOICE_ID
left join CLARITY_SA sa on sa.SERV_AREA_ID = inv.SERV_AREA_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = ibi.EPM_ID
left join ELEC_CLM_FORM ecf on ecf.ELEC_FORM_ID = ibi.FDF_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = inv.ACCOUNT_ID

where inv.SERV_AREA_ID = 305
and ibi.EPM_ID = 1001
and ibi.TAX_ID_NUM = 311010725

order by inv.INVOICE_ID