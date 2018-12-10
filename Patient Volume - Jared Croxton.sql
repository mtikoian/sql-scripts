/*
patient name
unique MRN
Payor 
Location(Place of Service)
place of service type
department

*/

select 
 ser.PROV_ID as 'BILLING PROVIDER ID'
,ser.PROV_NAME as 'BILLING PROVIDER'
,cast(arpb_tx.SERVICE_DATE as date) as 'SERVICE DATE'
,arpb_tx.TX_ID as 'CHARGE ID'
,pat.PAT_ID 'EPIC PATIENT ID'
,pat.PAT_MRN_ID as 'MRN'
,pat.PAT_NAME as 'PATIENT'
,fc.FINANCIAL_CLASS_NAME as 'FINANCIAL CLASS'
,epm.PAYOR_NAME as 'ORIGINAL PAYOR'
,pos.POS_NAME as 'PLACE OF SERVICE'
,pos.POS_TYPE as 'POS TYPE'
,arpb_tx.LOC_ID as 'LOCATION ID'
,loc.LOC_NAME as 'LOCATION'
,arpb_tx.DEPARTMENT_ID as 'DEPARTMENT ID'
,dep.DEPARTMENT_NAME as 'DEPARTMENT'
,cast(arpb_tx.VOID_DATE as date) as 'VOID DATE'

from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_SER ser on ser.PROV_ID = arpb_tx.BILLING_PROV_ID
left join PATIENT pat on pat.PAT_ID = arpb_tx.PATIENT_ID
left join CLARITY_EPM epm on epm.PAYOR_ID = arpb_tx.ORIGINAL_EPM_ID
left join CLARITY_POS pos on pos.POS_ID = arpb_tx.POS_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID 
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = arpb_tx.ORIGINAL_FC_C
where arpb_tx.BILLING_PROV_ID in ('3058050','1657906','1616929')
--arpb_tx.BILLING_PROV_ID = '1006962'
and arpb_tx.SERVICE_DATE >= '10/1/2014'
and arpb_tx.SERVICE_DATE <= '12/31/2014'
and arpb_tx.TX_TYPE_C = 1

order by ser.PROV_ID, arpb_tx.SERVICE_DATE