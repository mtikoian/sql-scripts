/*EKG report criteria = DOS over last 12 months, Youngstown rev locations for PB in both SA13 and SA19, CPT code 93010

columns to include = account, tx number, post date, service date, procedure, original amount, activity type, service area, rev location, department, billing provider, service provider and Tx ID

*/

DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('5/1/2017')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('5/13/2018')

select
 arpb_tx.ACCOUNT_ID as 'Account ID'
,acct.ACCOUNT_NAME as 'Account Name'
,arpb_tx.TX_ID as 'Charge ID'
,cast(arpb_tx.SERVICE_DATE as date) as 'Date of Service'
,cast(arpb_tx.POST_DATE as date) as 'Post Date'
,cast(arpb_tx.VOID_DATE as date) as 'Void Date'
,eap.PROC_CODE as 'Charge Code'
,eap.PROC_NAME as 'Charge Description'
,arpb_tx.AMOUNT as 'Charge Amount'
,upper(sa.NAME) as 'Region'
,arpb_tx.LOC_ID as 'Revenue Location ID'
,loc.LOC_NAME as 'Revenue Location Name'
,arpb_tx.DEPARTMENT_ID as 'Department ID'
,dep.DEPARTMENT_NAME as 'Department Name'
,dep.GL_PREFIX as 'Department GL'
,ser_bill.PROV_ID as 'Billing Provider ID'
,ser_bill.PROV_NAME as 'Billing Provider Name'
,ser_perf.PROV_ID as 'Service Provider ID'
,ser_perf.PROV_NAME as 'Service Provider Name'
,arpb_tx.MODIFIER_ONE as 'Modifier 1'
,arpb_tx.MODIFIER_TWO as 'Modifier 2'
,arpb_tx.MODIFIER_THREE as 'Modifier 3'
,arpb_tx.MODIFIER_FOUR as 'Modifier 4'
,arpb_tx.PROCEDURE_QUANTITY as 'Charge Quantity'


from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join CLARITY_SER ser_bill on ser_bill.PROV_ID = arpb_tx.BILLING_PROV_ID
left join CLARITY_SER ser_perf on ser_perf.PROV_ID = arpb_tx.SERV_PROVIDER_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join ACCOUNT acct on acct.ACCOUNT_ID = arpb_tx.ACCOUNT_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
where arpb_tx.POST_DATE >= @start_date
and arpb_tx.POST_DATE <= @end_date
and loc.RPT_GRP_TEN in (13,19)
and arpb_tx.TX_TYPE_C = 1
and eap.PROC_CODE = '93010'

order by 
 arpb_tx.ACCOUNT_ID