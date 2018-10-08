/*
We need a report that will pull any line item charge with DOS 01/01/2016 through 12/31/2016 
that had a denial/reason code 97 where the adjustment equaled the total charge. It would  need to include the Date of Service,
 patient MRN, billing provider, the procedure code, DOS, original payer and if possible the user that submitted it out of a WQ.
*/

DECLARE @start_date as date = EPIC_UTIL.EFN_DIN('mb-1')
DECLARE @end_date as date = EPIC_UTIL.EFN_DIN('me-1')

select
 varc.MATCH_CHG_TX_ID
,varc.PAYMENT_TX_ID
,cast(varc.SERVICE_DATE as date) as 'SERVICE_DATE'
,varc.PAT_ID
,upper(sa.NAME) as 'REGION'
,varc.BILLING_PROV_NM_WID
,varc.REMIT_CODE_NM_WID
,eap.PROC_NAME + ' [' + varc.CPT_CODE + ']' as CPT_CODE
,varc.PAYOR_NM_WID
,varc.BILL_AMOUNT
,varc.REMIT_AMOUNT


from 

V_ARPB_REMIT_CODES varc
left join CLARITY_LOC loc on loc.LOC_ID = varc.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join CLARITY_EAP eap on eap.PROC_CODE = varc.CPT_CODE

where 
varc.SERVICE_DATE >= @start_date
and varc.SERVICE_DATE <= @end_date
and varc.REMIT_CODE_ID = 97
and varc.SERV_AREA_ID in (11,13,16,17,18,19)
and varc.BILL_AMOUNT = varc.REMIT_AMOUNT
order by varc.SERVICE_DATE