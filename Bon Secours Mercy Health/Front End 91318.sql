declare @startdate date  = '8/15/2018' 
		,@enddate date = dateadd(d,0,datediff(d,0,getdate())-1); ---yesterday


with CteCopay as
(
select
 ACCOUNT_ID
,PAT_ENC_CSN_ID
,cast(CONTACT_DATE as date) as CONTACT_DATE
,CHECKIN_TIME
,APPT_STATUS
,ENC_TYPE
,DEPARTMENT_NAME
,SPECIALTY
,COPAY_COLLECTED
,COPAY_DUE
,case when ROW# = 1 then coalesce(PB_BALANCE,0) else 0 end as PB_BALANCE
,case when ROW# = 1 then coalesce(HB_BALANCE,0) else 0 end as HB_BALANCE

from

(
select 
 enc.ACCOUNT_ID
,enc.PAT_ENC_CSN_ID
,enc.CONTACT_DATE
,enc.CHECKIN_TIME
,appt_status.NAME as APPT_STATUS
,enc_type.NAME as ENC_TYPE
,dep.DEPARTMENT_NAME
,dep.SPECIALTY
,case when prc.benefit_group in ('Office Visit','PB Copay','Copay') then enc.COPAY_COLLECTED else 0 end as COPAY_COLLECTED
,case when prc.benefit_group in ('Office Visit','PB Copay','Copay') then enc.COPAY_DUE else 0 end as COPAY_DUE
,case when PATIENT_BALANCE < 0 then 0 else PATIENT_BALANCE end as PB_BALANCE
,case when HB_SELFPAY_BALANCE < 0 then 0 else HB_SELFPAY_BALANCE end as HB_BALANCE
,ROW_NUMBER() OVER(PARTITION BY enc.ACCOUNT_ID, enc.CONTACT_DATE ORDER BY enc.PAT_ENC_CSN_ID ASC) as ROW#

from PAT_ENC enc
left join CLARITY_DEP dep on enc.DEPARTMENT_ID= dep.DEPARTMENT_ID 
left join CLARITY_LOC loc on loc.LOC_ID = dep.REV_LOC_ID
left join ClarityCHPUtil.rpt.PB_DAILY_ACCOUNT_PATIENT_BALANCE bal on bal.ACCOUNT_ID = enc.ACCOUNT_ID and bal.UPDATE_DATE = enc.CONTACT_DATE and PATIENT_BALANCE > 0
left join ZC_DISP_ENC_TYPE enc_type on enc_type.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
left join ZC_APPT_STATUS appt_status on appt_status.APPT_STATUS_C = enc.APPT_STATUS_C
left join CLARITY_PRC prc on prc.PRC_ID = enc.APPT_PRC_ID

where 
enc.APPT_STATUS_C in (2,6) -- ARRIVED OR COMPLETED
and enc.CANCEL_REASON_C is null 
and enc.CONTACT_DATE between @startdate and @enddate
and loc.RPT_GRP_TEN in (11,13,16,17,18,19)
and enc.ACCOUNT_ID is not null
and enc_type.NAME not in ('Hospital encounter','Community Outreach','Scheduled Telephone Encounter','Erroneous Encounter')
--and enc.PAT_ENC_CSN_ID in (180128007,180209008,180209381,168099850,100500018)-- TEST DATE
--and enc.ACCOUNT_ID = 1493493

)a
),

CtePayment as
(
select
 arpb_tx.ACCOUNT_ID
,cast(arpb_tx.SERVICE_DATE as date) as SERVICE_DATE
,sum(arpb_tx.AMOUNT)*-1 as PATIENT_PAYMENT
from ARPB_TRANSACTIONS arpb_tx
where arpb_tx.TX_TYPE_C = 2
and arpb_tx.PROC_ID = 7084
and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
group by
 arpb_tx.ACCOUNT_ID
,arpb_tx.SERVICE_DATE
)

select
 a.ACCOUNT_ID
,a.PAT_ENC_CSN_ID
,a.CONTACT_DATE
,a.APPT_STATUS
,a.ENC_TYPE
,a.DEPARTMENT_NAME
,a.SPECIALTY
,a.COPAY_COLLECTED
,a.COPAY_DUE
,case when a.ROW# = 1 then coalesce(PATIENT_PAYMENT,0) else 0 end as PATIENT_PAYMENT
,a.PB_BALANCE
,a.HB_BALANCE
from
(
select copay.*
,pay.PATIENT_PAYMENT
,ROW_NUMBER() OVER(PARTITION BY copay.ACCOUNT_ID, copay.CONTACT_DATE ORDER BY copay.PAT_ENC_CSN_ID ASC) as ROW#
from CteCopay copay
left join CtePayment pay on pay.ACCOUNT_ID = copay.ACCOUNT_ID and pay.SERVICE_DATE = copay.CONTACT_DATE

)a