with charges as
(
select 
 arpb_tx.TX_ID as 'Charge ID'
,coalesce(cast(arpb_tx.PAT_ENC_CSN_ID as nvarchar),'') as 'Patient Encounter'
,disp.NAME as 'Encounter Type'
,eap.PROC_CODE as 'CPT'
,coalesce(arpb_tx.MODIFIER_ONE,'') as 'CPT Modifier1'
,eap.PROC_NAME as 'Procedure Code Description'
,convert(varchar(10), cast(arpb_tx.SERVICE_DATE as date), 101) as 'Date of Service'
,convert(varchar(10), cast(arpb_tx.POST_DATE as date), 101) as 'Charge Post Date'
--,'' as 'Date of Payment'
,convert(varchar(10), cast(pat.BIRTH_DATE as date), 101) as 'Patient DOB'
,gen.ABBR as 'Patient Gender'
,cov.SUBSCR_NUM as 'Patient ID'
,fc.FINANCIAL_CLASS_NAME as 'Insurance Type'
,ser2.NPI as 'NPI'
,ser.PROV_NAME as 'Service Provider Name'
,dep.SPECIALTY as 'Specialty'
,dep.DEPARTMENT_NAME as 'Practice Name'
,upper(sa.NAME) as 'REGION'
,arpb_tx.AMOUNT as 'Charges'
,case when loc.RPT_GRP_TEN = '11' then '311007881'
	  when loc.RPT_GRP_TEN = '13' then '320306944' 
	  when loc.RPT_GRP_TEN = '16' then '262788491'
	  when loc.RPT_GRP_TEN = '17' then '270995585'
	  when loc.RPT_GRP_TEN = '18' then '264779623'
	  when loc.RPT_GRP_TEN = '19' then '263807038' 
	  else '' end as 'TIN'
from ARPB_TRANSACTIONS arpb_tx
left join CLARITY_EAP eap on eap.PROC_ID = arpb_tx.PROC_ID
left join PATIENT pat on pat.PAT_ID = arpb_tx.PATIENT_ID
left join CLARITY_DEP dep on dep.DEPARTMENT_ID = arpb_tx.DEPARTMENT_ID
left join ZC_SEX gen on gen.RCPT_MEM_SEX_C = pat.SEX_C
left join CLARITY_FC fc on fc.FINANCIAL_CLASS = arpb_tx.ORIGINAL_FC_C
left join CLARITY_SER ser on ser.PROV_ID = arpb_tx.SERV_PROVIDER_ID
left join CLARITY_SER_2 ser2 on ser2.PROV_ID = ser.PROV_ID
left join PAT_ENC enc on enc.PAT_ENC_CSN_ID = arpb_tx.PAT_ENC_CSN_ID
left join ZC_DISP_ENC_TYPE disp on disp.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
left join COVERAGE cov on cov.COVERAGE_ID = arpb_tx.ORIGINAL_CVG_ID
left join CLARITY_LOC loc on loc.LOC_ID = arpb_tx.LOC_ID
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
where 
--charges
arpb_tx.TX_TYPE_C = 1
--exclude voids
and arpb_tx.VOID_DATE is null
-- service date between 1/1/17 - 12/31/17
and arpb_tx.SERVICE_DATE >= '1/1/2017'
and arpb_tx.SERVICE_DATE <= '12/31/2017'
-- Mercy service area's
and arpb_tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
-- Original Financial Class = Medicare
and arpb_tx.ORIGINAL_FC_C in ('2')
-- exclude $0 charegs
and arpb_tx.AMOUNT <> 0
),

payments as
(
select
 charges.[Charge ID]
,sum(tdl.AMOUNT)*-1 as 'Payments'
from charges
inner join CLARITY_TDL_TRAN tdl on tdl.TX_ID = charges.[Charge ID]
where tdl.DETAIL_TYPE = 20 -- charge matched to payments
-- Action Financial Class = Medicare or Medicare Managed
and tdl.ACTION_FIN_CLASS in ('2') 
and tdl.POST_DATE >= '1/1/2017'
and tdl.POST_DATE <= '3/31/2018'
group by charges.[Charge ID]
)

--records 1,509,402
select 
charges.*, payments.Payments
from charges
left join payments on payments.[Charge ID] = charges.[Charge ID]
order by charges.[Charge ID]