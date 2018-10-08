declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 
declare @12month as date = EPIC_UTIL.EFN_DIN('mb-13') ;

-->>>>>>>>  DECLARE MERCY REGIONS <<<<<<<<<<<
with region as
(
select *
from
(
select 

case when loc.loc_id in (11106,11124,11149,19147)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,1114,11142,11143,11144,11146,11151,11132,11138,19151,19154,19148,19155,19156,19149,19150) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104,19132,19133,19134) then 'LIMA'
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN'
	 when loc.loc_id in (18120,18121,19120,19127) then 'DEFIANCE'
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19128,19129,19130,19131,19121,19122,19123,19124)  then 'TOLEDO'
	 when loc.loc_id in (19101,19102,19106) then 'KENTUCKY' 
	 when loc.loc_id in (131201,131202) then 'SUMMA'
	 end as 'REGION'
,LOC.LOC_ID
from CLARITY_LOC LOC
)a

where a.region is not null

),

main as
(select 
Region
-->>>>>>>>  MERCY VISITS  <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) 
	and (tdl.cpt_code>='96150' and tdl.cpt_code<='96154' or 
                tdl.cpt_code>='90800' and tdl.cpt_code<='90884' or 
                tdl.cpt_code>='90886' and tdl.cpt_code<='90899' or 
                tdl.cpt_code>='99024' and tdl.cpt_code<='99069' or 
                tdl.cpt_code>='99071' and tdl.cpt_code<='99079' or 
                tdl.cpt_code>='99081' and tdl.cpt_code<='99144' or 
                tdl.cpt_code>='99146' and tdl.cpt_code<='99149' or 
                tdl.cpt_code>='99151' and tdl.cpt_code<='99172' or 
                tdl.cpt_code>='99174' and tdl.cpt_code<='99291' or 
                tdl.cpt_code>='99293' and tdl.cpt_code<='99359' or 
                tdl.cpt_code>='99375' and tdl.cpt_code<='99480' or 
				tdl.cpt_code='98969' or
                tdl.cpt_code='99361' or 
                tdl.cpt_code='99373' or 
				tdl.cpt_code='90791' or 
				tdl.cpt_code='90792' or 
				tdl.cpt_code='99495' or 
				tdl.cpt_code='99496' or 
                tdl.cpt_code='G0402' or 
                tdl.cpt_code='G0406' or 
                tdl.cpt_code='G0407' or 
                tdl.cpt_code='G0408' or 
                tdl.cpt_code='G0409' or 
                tdl.cpt_code='G0438' or 
                tdl.cpt_code='G0439'
				)
then tdl.procedure_quantity end) as 'MERCY VISITS'

-->>>>> Calculation for Total Charges <<<<<--
,sum(case when tdl.detail_type in (1,10) then tdl.amount end) as 'TOTAL CHARGES'

-->>>>>>>>  Calculation for Net Revenue  <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10,3,12,4,6,13,21,23,30,31) then tdl.amount end) as 'NET REVENUE'

-->>>>>>>>  Calculation for Payments  <<<<<<<<<<<
,sum(case when tdl.detail_type in (2,5,11,20,22,32,33) then tdl.amount end)*-1 as 'TOTAL PAYMENTS'

-->>>>>>>>  Calculation for Bad Debt  <<<<<<<<<<<
,sum(case when tdl.detail_type <= 13 and (eap.gl_num_debit in ('bad','badrecovery') or eap.gl_num_credit in ('bad','badrecovery')) then tdl.amount
		  end)*-1 as 'BAD DEBT'

-->>>>>>>>  Calculation for Charity  <<<<<<<<<<<
,sum(case when tdl.detail_type <= 13 and (eap.gl_num_debit in ('charity') or eap.gl_num_credit in ('charity')) then tdl.amount
		  end)*-1 as 'CHARITY'

-->>>>>>>>  Calculation for Admin  <<<<<<<<<<<
,sum(case when tdl.detail_type <= 13 and (eap.gl_num_debit in ('admin') or eap.gl_num_credit in ('admin')) then tdl.amount
		  end)*-1 as 'ADMIN'

-->>>>>>>>  Calculation for 1st Denial - Duplicate <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'DUPLICATE' then tdl.action_amount end) as '1st DENIAL - DUPLICATE'

-->>>>>>>>  Calculation for 1st Denial - Eligibility/Registration <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'ELIGIBILITY/REGISTRATION' then tdl.action_amount end) as '1st DENIAL - ELIGIBILITY/REGISTRATION'

-->>>>>>>>  Calculation for 1st Denial - Authorization <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'AUTHORIZATION' then tdl.action_amount end) as '1st DENIAL - AUTHORIZATION'

-->>>>>>>>  Calculation for 1st Denial - Enrollment <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'ENROLLMENT' then tdl.action_amount end) as '1st DENIAL - ENROLLMENT'

-->>>>>>>>  Calculation for 1st Denial - NonCovered <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'NON-COVERED' then tdl.action_amount end) as '1st DENIAL - NON COVERED'

-->>>>>>>>  Calculation for 1st Denial - Past Timely Filing <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'PAST TIMELY FILING' then tdl.action_amount end) as '1st DENIAL - PAST TIMELY FILING'

-->>>>>>>>  Calculation for 1st Denial - Additional Documentation <<<<<<<<<<<
,sum(case when tdl.detail_type = 44 and rmc_code.name = 'ADDITIONAL DOCUMENTATION NEEDED' then tdl.action_amount end) as '1st DENIAL - ADDITIONAL DOCUMENTATION NEEDED'

-->>>>>>>>  Calculation for Final Denial  <<<<<<<<<<<
,sum(case when eap_match.proc_code in ('4017','4018','4019','4020','4021','3011','3012','3013','3014','3015','3018','3019','3052','5036') then tdl.amount end)*-1 as 'FINAL DENIAL'

-->>>>>>>>  Calculation for Cash Patient CoPay  <<<<<<<<<<<
,sum(case when tdl.detail_type in (11,12,13,2,3,4,5,6) and (tdl.debit_gl_num = 'CASH' or tdl.credit_gl_num = 'CASH') and eap.proc_name = 'CO-PAYMENT (ACCOUNT)' then tdl.amount end)*-1 as 'CASH PATIENT COPAY'

-->>>>>>>>  Calculation for Total Patient Cash Posting  <<<<<<<<<<<
,sum(case when tdl.detail_type in (11,12,13,2,3,4,5,6) and (tdl.debit_gl_num = 'CASH' or tdl.credit_gl_num = 'CASH') and (eap.proc_name = 'CO-PAYMENT (ACCOUNT)' or eap.proc_name = 'PATIENT PAYMENT (ACCOUNT)') then tdl.amount end)*-1 as 'TOTAL PATIENT CASH POSTING'
              
-->>>>>>>>  Calculation for Payor Mix - BX Managed  <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'BX MANAGED' then tdl.amount end) as 'BX MGD CHARGES'

-->>>>>>>>  Calculation for Payor Mix - BX Traditional  <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'BX TRADITIONAL' then tdl.amount end) as 'BX TRD CHARGES'

-->>>>>>>>  Calculation for Payor Mix - Commercial <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'COMMERCIAL' then tdl.amount end) as 'COMMERCIAL CHARGES'

-->>>>>>>>  Calculation for Payor Mix - Managed Care <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'MANAGED CARE' then tdl.amount end) as 'MANAGED CARE CHARGES'

-->>>>>>>>  Calculation for Payor Mix - Medicaid <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'MEDICAID' then tdl.amount end) as 'MEDICAID CHARGES'

-->>>>>>>>  Calculation for Payor Mix - Medicaid Mgd <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'MEDICAID MANAGED' then tdl.amount end) as 'MEDICAID MANAGED CHARGES'

-->>>>>>>>  Calculation for Payor Mix - Medicare <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'MEDICARE' then tdl.amount end) as 'MEDICARE CHARGES'

-->>>>>>>>  Calculation for Payor Mix - Medicare Mgd <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'MEDICARE MANAGED' then tdl.amount end) as 'MEDICARE MGD CHARGES'

-->>>>>>>>  Calculation for Payor Mix - Other <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'OTHER' then tdl.amount end) as 'OTHER CHARGES'

-->>>>>>>>  Calculation for Payor Mix - Self Pay <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and fc.name = 'SELF-PAY' then tdl.amount end) as 'SELF PAY CHARGES'

-->>>>>>>>  Calculation for Payor Mix - Worker's Comp Pay <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) and (left(fc.name,6) = 'WORKER') then tdl.amount end) as 'WORKERS COMP CHARGES'

from region
inner join clarity_tdl_tran tdl on tdl.loc_id = region.loc_id
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on department_id = tdl.dept_id
left join clarity_rmc rmc on rmc.remit_code_id = tdl.reason_code_id
left join zc_rmc_code_cat rmc_code on rmc_code.rmc_code_cat_c = rmc.code_cat_c
left join zc_orig_fin_class fc on fc.original_fin_class = tdl.original_fin_class

where

tdl.post_date >= @start_date
and tdl.post_date <= @end_date


group by
region

),

ar as

(select 
	
Region
-->>>>>>>>  Calculation for Self Pay AR Aging > 90 Days  <<<<<<<<<<<
,sum(case when age.detail_type in (60,61) and age.post_date - age.orig_service_date > 90 then age.patient_amount end) as 'PATIENT AR > 90'

-->>>>>>>>  Calculation for Total Self Pay AR  <<<<<<<<<<<
,sum(case when age.detail_type in (60,61) then age.patient_amount end) as 'TOTAL SELF PAY AR'

-->>>>>>>>  Calculation for Insurance AR Aging > 90 Days  <<<<<<<<<<<
,sum(case when age.detail_type in (60,61) and post_date - age.orig_service_date > 90 then age.insurance_amount end) as 'INSURANCE AR > 90'

-->>>>>>>>  Calculation for Insurance Pay AR  <<<<<<<<<<<
,sum(case when age.detail_type in (60,61) then age.insurance_amount end) as 'INSURANCE PAY AR'

from region
inner join clarity_tdl_age age on age.loc_id = region.loc_id
left join clarity_loc loc on loc.loc_id = age.loc_id
left join clarity_dep dep on dep.department_id = age.dept_id

where 
age.post_date >= @start_date
and age.post_date <= @end_date


group by
region

),

copay as
(select 
region
,sum(enc.copay_collected) as 'COPAY COLLECTED'
,sum(enc.copay_due) as 'COPAY DUE'

from pat_enc enc
left join clarity_dep dep on dep.department_id = enc.department_id
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join clarity_prc prc on prc.prc_id = enc.appt_prc_id
inner join region on region.loc_id = loc.loc_id

where appt_status_c in (2,6) -- Arrived or Completed
and  enc.contact_date >= @start_date
and enc.contact_date <= @end_date
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
group by
region

),

enc as
(select 
	
region

-->>>>>>>>  Calculation for Open Encounters < 8 days  <<<<<<<<<<<
--,sum(case when datediff(day,enc.contact_date,@end_date) < 8 then 1 end) as '< 8 Days'

,sum(case when enc_closed_yn = 'y' and datediff(day,enc.contact_date, enc_close_date) < 8 then 1
		  when enc_closed_yn = 'n' and datediff(day,enc.contact_date, @end_date) < 8 then 1 end) as '< 8 Days'

-->>>>>>>>  Calculation for Open Encounters 8 - 30 days  <<<<<<<<<<<
--,sum(case when datediff(day,enc.contact_date,@end_date) > 7 and datediff(day,enc.contact_date,@end_date) < 31 then 1 end) as '8 - 30 Days'

,sum(case when enc_closed_yn = 'y' and datediff(day,enc.contact_date,enc_close_date) > 7 and datediff(day,enc.contact_date,enc_close_Date) < 31 then 1
		  when enc_closed_yn = 'n' and datediff(day,enc.contact_date,@end_date) > 7 and datediff(day,enc.contact_date,@end_date) < 31 then 1 end) as '8 - 30 Days'

-->>>>>>>>  Calculation for Open Encounters 31 - 90 days  <<<<<<<<<<<
--,sum(case when datediff(day,enc.contact_date,@end_date) > 30 and datediff(day,enc.contact_date,@end_date) < 91 then 1 end) as '31 - 90 Days'

,sum(case when enc_closed_yn = 'y' and datediff(day,enc.contact_date,enc_close_date) > 30 and datediff(day,enc.contact_date,enc_close_Date) < 91 then 1
		  when enc_closed_yn = 'n' and datediff(day,enc.contact_date,@end_date) > 30 and datediff(day,enc.contact_date,@end_date) < 91 then 1 end) as '31 - 90 Days'
-->>>>>>>>  Calculation for Open Encounters 91 - 365 days  <<<<<<<<<<<
--,sum(case when datediff(day,enc.contact_date,@end_date) > 90 and datediff(day,enc.contact_date,@end_date) < 366 then 1 end) as '91 - 365 Days'

,sum(case when enc_closed_yn = 'y' and datediff(day,enc.contact_date,enc_close_date) > 90 and datediff(day,enc.contact_date,enc_close_Date) < 366 then 1
		  when enc_closed_yn = 'n' and datediff(day,enc.contact_date,@end_date) > 90 and datediff(day,enc.contact_date,@end_date) < 366 then 1 end) as '91 - 365 Days'
from pat_enc enc
left join clarity_ser ser on ser.prov_id = enc.visit_prov_id
left join clarity_dep dep on dep.department_id = enc.department_id
left join zc_disp_enc_type zdet on zdet.disp_enc_type_c = enc.enc_type_c
left join patient pat on pat.pat_id = enc.pat_id
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
inner join region on region.loc_id = loc.loc_id

where (enc_closed_yn = 'n' or (enc_closed_yn = 'y' and enc_close_date > @end_date))
--enc.enc_closed_yn = 'n'
and ser.prov_type in ('Physician','Nurse Practitioner','Physician Assistant','Certified Nurse Midwife','Podiatrist')
and disp_enc_type_c in ('1000','1003','101','1200','1201','1214','2502','62','72','210177','2')
and enc.contact_date >= @12month
and enc.contact_date <= @end_date
and enc.appt_status_c in (2,6)


group by
region
),

lag as
(
select
 REGION
,sum([days lag]) as 'Lag Days'
,sum([Distinct Count]) as 'Distinct Count'
,convert(decimal(18,2),round(convert(decimal(18,2),round(sum([days lag]),2))/convert(decimal(18,2),round(sum([Distinct Count]),2)),2)) as [Avg Lag Days]

from

(select *

from
(select
region
,loc.loc_name as 'LOCATION'
,dep.department_name as 'DEPARTMENT'
,date.monthname_year as 'MONTH'
,pos.pos_name as 'POS_NAME'
,pat.pat_mrn_id as 'PAT_MRN_ID'
,tdl.charge_slip_number as 'CHARGE_SLIP_NUMBER'
,tdl.pat_enc_csn_id as 'ORIG_CSN'
,tdl.pat_id as 'ORIG_PAT_ID'
,arpb_match.pat_enc_csn_id as 'MATCHED_CSN'
,tdl.orig_service_date as 'ORIG_SERVICE_DATE'
,tdl.post_Date as 'POST_DATE'          
,min(arpb_match.post_date) as 'Earliest Post Date'                 

-->>>>>>>>  Calculation for Total Charges  <<<<<<<<<<<
,sum(case when tdl.detail_type in (1,10) then tdl.amount end) as 'Total Charges'

,case when tdl.post_date = min(arpb_match.post_date) then datediff(day,tdl.orig_service_date,tdl.post_date) end as 'Days Lag'

,case when tdl.post_date = min(arpb_match.post_date) then 1 
      when tdl.post_date = tdl.orig_service_date then 1
	  else 0
	  end as 'Distinct Count'

from region
inner join clarity_tdl_tran tdl on tdl.loc_id = region.loc_id
left join arpb_transactions arpb_match on arpb_match.patient_id = tdl.int_pat_id and tdl.orig_service_date = arpb_match.service_date
left join patient pat on pat.pat_id = tdl.int_pat_id
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join date_dimension date on date.calendar_dt_str = tdl.post_date
where

tdl.post_date >= @start_date
and tdl.post_date <=@end_date
and tdl.detail_type in (1,10)


group by
	region
	,loc.loc_name
	,dep.department_name
	,date.monthname_year
    ,pos.pos_name
	,pat.pat_mrn_id
	,tdl.charge_slip_number
	,tdl.pat_enc_csn_id
	,tdl.pat_id
	,arpb_match.pat_enc_csn_id
	,tdl.orig_service_date
	,tdl.post_date

) as t

group by 
region
,location
,department
,month
,pos_name
,pat_mrn_id
,charge_slip_number
,orig_csn
,orig_pat_id
,matched_csn
,orig_service_date
,post_date
,[earliest post date]
,[total charges]
,[days lag]
,[distinct count]
) as lag

group by region

),

review as
( SELECT 
region,

-->>>>>>>>  Calculation for Total Charge Review Days  <<<<<<<<<<<

              sum(datediff(day, V_ARPB_CHG_REVIEW_WQ.ENTRY_DATE, V_ARPB_CHG_REVIEW_WQ.EXIT_DATE)) as "Total Charge Review Days",

-->>>>>>>>  Calculation for Distinct count Lag Charges  <<<<<<<<<<<

              Count("ARPB_TRANSACTIONS"."Account_ID") as "Distinct count Lag Charges",

-->>>>>>>>  Calculation for Lag Days  <<<<<<<<<<<

              sum(datediff(day, V_ARPB_CHG_REVIEW_WQ.ENTRY_DATE, V_ARPB_CHG_REVIEW_WQ.EXIT_DATE))/Count("ARPB_TRANSACTIONS"."Account_ID") as "Review Days"


 FROM region
 inner join "Clarity"."dbo"."ARPB_TRANSACTIONS" ARPB_TRANSACTIONS on arpb_transactions.loc_id = region.loc_id
  LEFT OUTER JOIN clarity_loc loc ON ARPB_TRANSACTIONS.LOC_ID=LOC.LOC_ID
LEFT OUTER JOIN (select proc_id,proc_code,proc_cat_id,proc_name from "Clarity"."dbo".CLARITY_EAP) CLARITY_EAP ON ARPB_TRANSACTIONS.PROC_ID=CLARITY_EAP.PROC_ID
LEFT OUTER JOIN (select proc_cat_id,proc_cat_name from "Clarity"."dbo".EDP_PROC_CAT_INFO) EDP_PROC_CAT_INFO ON CLARITY_EAP.PROC_CAT_ID=EDP_PROC_CAT_INFO.PROC_CAT_ID
LEFT OUTER JOIN (select pos_type_c,pos_id,pos_name from "Clarity"."dbo".CLARITY_POS) CLARITY_POS ON ARPB_TRANSACTIONS.POS_ID=CLARITY_POS.POS_ID
LEFT OUTER JOIN "Clarity"."dbo".ZC_POS_TYPE ZC_POS_TYPE ON CLARITY_POS.POS_TYPE_C=ZC_POS_TYPE.POS_TYPE_C
LEFT OUTER JOIN (select specialty_dep_c,department_id,department_name from "Clarity"."dbo".CLARITY_DEP) CLARITY_DEP ON ARPB_TRANSACTIONS.DEPARTMENT_ID=CLARITY_DEP.DEPARTMENT_ID
LEFT OUTER JOIN "Clarity"."dbo".ZC_SPECIALTY_DEP ZC_SPECIALTY_DEP ON CLARITY_DEP.SPECIALTY_DEP_C=ZC_SPECIALTY_DEP.SPECIALTY_DEP_C
LEFT OUTER JOIN (select prov_id,prov_name from "Clarity"."dbo".CLARITY_SER) BILLING_PROVIDER ON ARPB_TRANSACTIONS.BILLING_PROV_ID=BILLING_PROVIDER.PROV_ID
LEFT OUTER JOIN (select prov_id,prov_name from "Clarity"."dbo".CLARITY_SER) SERVICE_PROVIDER ON ARPB_TRANSACTIONS.SERV_PROVIDER_ID=SERVICE_PROVIDER.PROV_ID
LEFT OUTER JOIN (select serv_area_id,serv_area_name from "Clarity"."dbo".CLARITY_SA) CLARITY_SA ON ARPB_TRANSACTIONS.SERVICE_AREA_ID=CLARITY_SA.SERV_AREA_ID
LEFT OUTER JOIN "Clarity"."dbo".ARPB_TRANSACTIONS2 ARPB_TRANSACTIONS2 ON ARPB_TRANSACTIONS.TX_ID=ARPB_TRANSACTIONS2.TX_ID
LEFT OUTER JOIN (select fin_div_id,fin_div_nm from "Clarity"."dbo".FIN_DIV) FIN_DIV ON ARPB_TRANSACTIONS2.FIN_DIV_ID=FIN_DIV.FIN_DIV_ID
LEFT OUTER JOIN (select fin_subdiv_id,fin_subdiv_nm from "Clarity"."dbo".FIN_SUBDIV) FIN_SUBDIV ON ARPB_TRANSACTIONS2.FIN_SUBDIV_ID=FIN_SUBDIV.FIN_SUBDIV_ID
LEFT OUTER JOIN (select bill_area_id,record_name from "Clarity"."dbo".BILL_AREA) BILL_AREA ON ARPB_TRANSACTIONS.BILL_AREA_ID=BILL_AREA.BILL_AREA_ID
LEFT OUTER JOIN "Clarity"."dbo".ARPB_TX_MODERATE ARPB_TX_MODERATE ON ARPB_TX_MODERATE.TX_ID=ARPB_TRANSACTIONS.TX_ID /*need this to get TAR id to link to CR view */
LEFT OUTER JOIN "Clarity"."dbo".V_ARPB_CHG_REVIEW_WQ V_ARPB_CHG_REVIEW_WQ ON ARPB_TX_MODERATE.SOURCE_TAR_ID=V_ARPB_CHG_REVIEW_WQ.TAR_ID
LEFT OUTER JOIN "Clarity"."dbo".CLARITY_UCL CLARITY_UCL ON ARPB_TRANSACTIONS.CHG_ROUTER_SRC_ID=CLARITY_UCL.UCL_ID
LEFT OUTER JOIN "Clarity"."dbo".ZC_CHG_SOURCE_UCL ZC_CHG_SOURCE_UCL ON CLARITY_UCL.CHARGE_SOURCE_C=ZC_CHG_SOURCE_UCL.chg_source_ucl_c
LEFT OUTER JOIN "Clarity"."dbo".ZC_CHRG_SOURCE_TAR ZC_CHRG_SOURCE_TAR ON V_ARPB_CHG_REVIEW_WQ.SOURCE_C=ZC_CHRG_SOURCE_TAR.CHARGE_SOURCE_C
LEFT OUTER JOIN "Clarity"."dbo".DATE_DIMENSION dt on dt.CALENDAR_DT=ARPB_TRANSACTIONS.POST_DATE
LEFT OUTER JOIN "Clarity"."dbo".DATE_DIMENSION dts on dts.CALENDAR_DT=ARPB_TRANSACTIONS.SERVICE_DATE
LEFT OUTER JOIN "Clarity"."dbo".ARPB_TX_VOID ARPB_TX_VOID ON ARPB_TX_VOID.TX_ID=ARPB_TRANSACTIONS.TX_ID

       
WHERE  ARPB_TRANSACTIONS.TX_TYPE_C=1 
and (ARPB_TX_VOID.OLD_ETR_ID IS NULL and ARPB_TX_VOID.REPOSTED_ETR_ID IS NULL and ARPB_TX_VOID.REPOST_TYPE_C IS NULL and ARPB_TX_VOID.RETRO_CHARGE_ID IS NULL)

--and '{?Service or Post Date}'='Service Date'
--and ARPB_TRANSACTIONS.SERVICE_DATE between EPIC_UTIL.EFN_DIN('{?StartDate}') AND EPIC_UTIL.EFN_DIN('{?EndDate}')


--7/31/16 DSP Added 1312
and loc.rpt_grp_ten in (11,13,16,17,18,19,21,1312) and
("ARPB_TRANSACTIONS"."SERVICE_DATE">=@start_date AND 
 "ARPB_TRANSACTIONS"."SERVICE_DATE"<=@end_date)


group by
region
),


ver as
(  SELECT 
region,

              sum(1) as "Total Encounter",

              sum(case when "ZC_REG_STATUS"."NAME"='Verified' then 1 end) as "Verified"



FROM  
((((("Clarity"."dbo"."PAT_ENC" "PAT_ENC" INNER JOIN "Clarity"."dbo"."PAT_ENC_2" "PAT_ENC_2" ON ("PAT_ENC"."PAT_ENC_CSN_ID"="PAT_ENC_2"."PAT_ENC_CSN_ID") AND ("PAT_ENC"."CONTACT_DATE"="PAT_ENC_2"."CONTACT_DATE")) 
                                                                                   INNER JOIN "Clarity"."dbo"."ZC_APPT_STATUS" "ZC_APPT_STATUS" ON "PAT_ENC"."APPT_STATUS_C"="ZC_APPT_STATUS"."APPT_STATUS_C") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."PATIENT" "PATIENT" ON "PAT_ENC"."PAT_ID"="PATIENT"."PAT_ID") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."CLARITY_DEP" dep ON "PAT_ENC"."DEPARTMENT_ID"=dep."DEPARTMENT_ID") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."VERIFICATION" "VERIFICATION" ON "PAT_ENC_2"."ENC_VERIFICATION_ID"="VERIFICATION"."RECORD_ID") 
                                                                                   LEFT OUTER JOIN "Clarity"."dbo"."ZC_REG_STATUS" "ZC_REG_STATUS" ON "VERIFICATION"."VERIF_STATUS_C"="ZC_REG_STATUS"."REG_STATUS_C"
																				   left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
																				   inner join region on region.loc_id = loc.loc_id
 WHERE 
              ("PAT_ENC"."APPT_STATUS_C"=2 OR "PAT_ENC"."APPT_STATUS_C"=6) AND 
              ("PAT_ENC"."CONTACT_DATE">=@start_date AND 
               "PAT_ENC"."CONTACT_DATE"<=@end_date) AND 
              ("PAT_ENC"."ENC_TYPE_C"='1000' OR "PAT_ENC"."ENC_TYPE_C"='1001' OR "PAT_ENC"."ENC_TYPE_C"='1003' OR "PAT_ENC"."ENC_TYPE_C"='101' OR "PAT_ENC"."ENC_TYPE_C"='108' OR "PAT_ENC"."ENC_TYPE_C"='11' OR "PAT_ENC"."ENC_TYPE_C"='1200' OR "PAT_ENC"."ENC_TYPE_C"='1201' OR "PAT_ENC"."ENC_TYPE_C"='121' OR "PAT_ENC"."ENC_TYPE_C"='1214' OR "PAT_ENC"."ENC_TYPE_C"='2' OR "PAT_ENC"."ENC_TYPE_C"='201' OR "PAT_ENC"."ENC_TYPE_C"='21005' OR "PAT_ENC"."ENC_TYPE_C"='210177' OR "PAT_ENC"."ENC_TYPE_C"='2102' OR "PAT_ENC"."ENC_TYPE_C"='2501' OR "PAT_ENC"."ENC_TYPE_C"='2502' OR "PAT_ENC"."ENC_TYPE_C"='283' OR "PAT_ENC"."ENC_TYPE_C"='49' OR "PAT_ENC"."ENC_TYPE_C"='51' OR "PAT_ENC"."ENC_TYPE_C"='81') -- removed 50 on 11/17/17

-- ORDER BY "PAT_ENC"."SERV_AREA_ID", "CLARITY_DEP"."REV_LOC_ID", "PATIENT"."PAT_MRN_ID"

group by
region

)

select 
 main.[REGION]
,main.[MERCY VISITS]
,main.[TOTAL CHARGES]
,main.[NET REVENUE]
,main.[TOTAL PAYMENTS]
,main.[BAD DEBT]
,main.[CHARITY]
,main.[ADMIN]
,main.[1st DENIAL - DUPLICATE]
,main.[1st DENIAL - ELIGIBILITY/REGISTRATION]
,main.[1st DENIAL - AUTHORIZATION]
,main.[1st DENIAL - ENROLLMENT]
,main.[1st DENIAL - NON COVERED]
,main.[1st DENIAL - PAST TIMELY FILING]
,main.[1st DENIAL - ADDITIONAL DOCUMENTATION NEEDED]
,main.[FINAL DENIAL]
,main.[CASH PATIENT COPAY]
,main.[TOTAL PATIENT CASH POSTING]
,main.[BX MGD CHARGES]
,main.[BX TRD CHARGES]
,main.[COMMERCIAL CHARGES]
,main.[MANAGED CARE CHARGES]
,main.[MEDICAID CHARGES]
,main.[MEDICAID MANAGED CHARGES]
,main.[MEDICARE CHARGES]
,main.[MEDICARE MGD CHARGES]
,main.[OTHER CHARGES]
,main.[SELF PAY CHARGES]
,main.[WORKERS COMP CHARGES]
,ar.[PATIENT AR > 90]
,ar.[TOTAL SELF PAY AR]
,ar.[INSURANCE AR > 90]
,ar.[INSURANCE PAY AR]
,copay.[COPAY COLLECTED]
,copay.[COPAY DUE]
,enc.[< 8 Days]
,enc.[8 - 30 Days]
,enc.[31 - 90 Days]
,enc.[91 - 365 Days]
,lag.[Lag Days]
,lag.[Distinct Count]
,lag.[Avg Lag Days]
,review.[Total Charge Review Days]
,review.[Distinct count Lag Charges]
,review.[Review Days]
,ver.[Total Encounter]
,ver.[Verified]

from main
left join ar on ar.region = main.region
left join copay on copay.region = main.region
left join enc on enc.region = main.region
left join lag on lag.region = main.region
left join review on review.region= main.region
left join ver on ver.region = main.region

order by main.region