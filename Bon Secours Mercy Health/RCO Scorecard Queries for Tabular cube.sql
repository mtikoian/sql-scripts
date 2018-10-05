--first pass denials
select 
 varc.DEPARTMENT_ID as 'Department ID'
,dep.DEPARTMENT_NAME as 'Department'
,varc.LOC_ID as 'Location ID'
,loc.LOC_NAME as 'Location'
,sa.RPT_GRP_TEN as 'Region ID'
,upper(sa.NAME) as 'Region'
,varc.PAYMENT_POST_DATE as 'Payment Post Date'
,case when rmc1.remit_code_name is not null then upper(zrcc.name) else upper(remit_code_cat_name) end as 'Remit Code Category'
,varc.REMIT_AMOUNT as 'Remit Amount'

from 

clarity.dbo.V_ARPB_REMIT_CODES varc
--left join clarity.dbo.PMT_EOB_INFO_I eob on eob.TX_ID = varc.PAYMENT_TX_ID and eob.LINE = varc.EOB_LINE
left join clarity.dbo.CLARITY_RMC rmc on rmc.REMIT_CODE_ID = varc.REMIT_CODE_ID
left join clarity.dbo.CLARITY_RMC rmc1 on rmc1.REMIT_CODE_ID = varc.REMARK_CODE_1_ID
left join clarity.dbo.ZC_RMC_CODE_CAT zrcc on zrcc.RMC_CODE_CAT_C = rmc1.CODE_CAT_C
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = varc.DEPARTMENT_ID
left join CLARITY_LOC loc on loc.LOC_ID = varc.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN

where 
varc.PAYMENT_POST_DATE >= '12/1/2017'
and varc.PAYMENT_POST_DATE <= '05/31/2018'
and varc.SERV_AREA_ID in (11,13,16,17,18,19)
and varc.REMIT_ACTION in (9,14)
and varc.REMIT_AMOUNT >= 0

--copay

select 
 dep.DEPARTMENT_ID
,dep.REV_LOC_ID
,enc.PAT_ENC_CSN_ID
,enc.CONTACT_DATE
,tdl.AMOUNT as 'COPAY_COLLECTED'
,enc.COPAY_DUE

from pat_enc enc
left join clarity_prc prc on prc.prc_id = enc.appt_prc_id
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
left join CLARITY_TDL_TRAN tdl on tdl.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID and tdl.PROC_ID = 7108 and tdl.DETAIL_TYPE = 2 and enc.CONTACT_DATE = tdl.POST_DATE


where appt_status_c in (2,6) -- Arrived or Completed
and  enc.contact_date >= '1/1/2017'
and enc.contact_date <= '12/31/2017'
and prc.benefit_group in ('Office Visit','PB Copay','Copay')
and enc.copay_due > 0
and enc.pat_enc_csn_id <> 131850458
and dep.department_id not in (
 19290028
,19290022
,11101323
,11101447
,11101321
,11101501
,11101448
,11101322
,11106145
,11106141
,18101244
,19390123
)
and enc.SERV_AREA_ID in (11,13,16,17,18,19)