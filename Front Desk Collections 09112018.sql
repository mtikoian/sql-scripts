declare @startdate date  = '8/15/2018' 
		,@enddate date = dateadd(d,0,datediff(d,0,getdate())-1); ---yesterday

--FIND ENCOUNTERS-----------------------------
with cteEncounter as
(

select distinct
 enc.ACCOUNT_ID
,enc.CONTACT_DATE

from PAT_ENC enc
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID

where enc.CONTACT_DATE >= @startdate
and enc.CONTACT_DATE <= @enddate
and loc.RPT_GRP_TEN in (11,13,16,17,18,19)
and enc.ACCOUNT_ID is not null
and enc.CANCEL_REASON_C is null 
and enc.APPT_STATUS_C in (2,6) -- ARRIVED OR COMPLETED
and enc.ACCOUNT_ID = 101280805 -- TEST ACCOUNT

),

--FIND COPAY-------------------------------
cteCopay as
(

select
 enc.ACCOUNT_ID
,cast(enc.CONTACT_DATE as date) as CONTACT_DATE
,sum(case when prc.benefit_group in ('Office Visit','PB Copay','Copay') then enc.COPAY_DUE else 0 end) as COPAY_DUE
,sum(case when prc.benefit_group in ('Office Visit','PB Copay','Copay') then enc.COPAY_COLLECTED else 0 end) as COPAY_COLLECTED

from cteEncounter 
inner join PAT_ENC enc on enc.ACCOUNT_ID = cteEncounter.ACCOUNT_ID and enc.CONTACT_DATE = cteEncounter.CONTACT_DATE
inner join CLARITY_PRC prc on prc.PRC_ID = enc.APPT_PRC_ID

where enc.COPAY_DUE > 0

group by
 enc.ACCOUNT_ID
,enc.CONTACT_DATE

),

--FIND PAYMENTS------------------------------
ctePayment as
(

select 
 arpb_tx.ACCOUNT_ID
,cast(arpb_tx.SERVICE_DATE as date) as SERVICE_DATE
,sum(arpb_tx.AMOUNT) * -1 as PATIENT_PAYMENT
,min(bal.PATIENT_BALANCE) as PB_BALANCE

from cteEncounter
inner join ClarityCHPUtil.rpt.PB_DAILY_ACCOUNT_PATIENT_BALANCE bal on bal.ACCOUNT_ID = cteEncounter.ACCOUNT_ID and bal.UPDATE_DATE = cteEncounter.CONTACT_DATE
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.ACCOUNT_ID = cteEncounter.ACCOUNT_ID and arpb_tx.SERVICE_DATE = cteEncounter.CONTACT_DATE and arpb_tx.TX_TYPE_C = 2 and arpb_tx.PROC_ID = 7084


--where convert(int, enc.ENC_TYPE_C) in (50, 101, 1001, 1003, 1200, 1214, 2)  
--			    /*Included Encounter Types
--				Anti-coag visit
--				Procedure visit
--				Office Visit
--				Routine Prenatal
--				Postpartum Visit
--				Walk-In
--				Appointment
--				Clinical Support -- removed 9/11/18
--				PAT Telephone -- removed 9/11/18
--				Post-op Telephone --- removed 9/11/18
--				*/

group by 
 arpb_tx.ACCOUNT_ID
,arpb_tx.SERVICE_DATE

)

select 
*
from cteEncounter enc
left join cteCopay copay on copay.ACCOUNT_ID = enc.ACCOUNT_ID and copay.CONTACT_DATE = enc.CONTACT_DATE
left join ctePayment pay on pay.ACCOUNT_ID = enc.ACCOUNT_ID and pay.SERVICE_DATE = enc.CONTACT_DATE


order by 
 enc.ACCOUNT_ID asc
,enc.CONTACT_DATE