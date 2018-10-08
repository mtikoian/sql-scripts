--declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
--declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

declare @start_date as date = EPIC_UTIL.EFN_DIN('1/1/2016')
declare @end_date as date = EPIC_UTIL.EFN_DIN('5/19/2017')

select

 [SERVICE AREA]
,[LOCATION]
,[DEPARTMENT]
,[PROCEDURE]
,[MODIFIER ONE]
,[ACCOUNT]
,[CHARGE ETR ID]
,[SERVICE DATE]
,[MONTH-YEAR]
,[PATIENT]
,[ORIGINAL PAYOR]
,max([CHARGE]) as 'CHARGE'
,max([COVERED]) as 'COVERED'
,max([NON COVERED]) as 'NON COVERED'
,max([DEDUCTIBLE]) as 'DEDUCTIBLE'
,max([COPAY]) as 'COPAY'
,max([CO-INSURANCE]) as 'CO-INSURANCE'
,sum([PATIENT PAYMENTS]) as 'PATIENT PAYMENTS'
,sum([INSURANCE PAYMENTS]) as 'INSURANCE PAYMENTS'
,sum([ADJUSTMENTS]) as 'ADJUSTMENTS'

from 

(
select

 sa.serv_area_name + ' - ' + cast(sa.serv_area_id as varchar) as 'SERVICE AREA'
,loc.loc_name + ' - ' + cast(loc.loc_id as varchar) as 'LOCATION'
,dep.department_name + ' - ' + cast(dep.department_id as varchar) as 'DEPARTMENT'
,eap_charges.proc_name + ' - ' + eap_charges.proc_code as 'PROCEDURE'
,arpb_tx_charges.modifier_one as 'MODIFIER ONE'
,arpb_tx_charges.account_id as 'ACCOUNT'
,arpb_tx_charges.tx_id as 'CHARGE ETR ID'
,cast(arpb_tx_charges.service_date as date) as 'SERVICE DATE'
,dd.monthname_year as 'MONTH-YEAR'
,pat.pat_name as 'PATIENT'
,epm_orig.payor_name + ' - ' + cast(epm_orig.payor_id as varchar) as 'ORIGINAL PAYOR'
,coalesce(arpb_tx_charges.amount,0) as 'CHARGE'
,coalesce(eob.cvd_amt,0) as 'COVERED'
,coalesce(eob.noncvd_amt,0) as 'NON COVERED'
,coalesce(eob.ded_amt,0) as 'DEDUCTIBLE'
,coalesce(eob.copay_amt,0) as 'COPAY'
,coalesce(eob.coins_amt,0) as 'CO-INSURANCE'
,case when arpb_tx_payments.tx_type_c = 2 and arpb_tx_payments.cpt_code in ('1000','1001','1006') then coalesce(arpb_tx_match.mtch_tx_hx_pat_amt,0) else 0 end as 'PATIENT PAYMENTS'
,case when arpb_tx_payments.tx_type_c = 2 and arpb_tx_payments.cpt_code = '2000' then coalesce(arpb_tx_match.mtch_tx_hx_ins_amt,0) else 0 end as 'INSURANCE PAYMENTS'
,case when arpb_tx_payments.tx_type_c = 3 then coalesce(arpb_tx_match.mtch_tx_hx_amt,0) else 0 end as 'ADJUSTMENTS'
,coalesce(arpb_tx_charges.outstanding_amt,0) as 'OUTSTANDING'

from arpb_transactions arpb_tx_charges
left join arpb_tx_match_hx arpb_tx_match on arpb_tx_match.tx_id = arpb_tx_charges.tx_id
left join patient pat on pat.pat_id = arpb_tx_charges.patient_id
left join clarity_eap eap_charges on eap_charges.proc_id = arpb_tx_charges.proc_id
left join clarity_loc loc on loc.loc_id = arpb_tx_charges.loc_id
left join clarity_dep dep on dep.department_id = arpb_tx_charges.department_id
left join clarity_sa sa on sa.serv_area_id = arpb_tx_charges.service_area_id
left join clarity_epm epm_orig on epm_orig.payor_id = arpb_tx_charges.original_epm_id
left join date_dimension dd on dd.calendar_dt = arpb_tx_charges.service_date
left join pmt_eob_info_i eob on eob.tx_id = arpb_tx_match.mtch_tx_hx_id and eob.line = arpb_tx_match.mtch_tx_hx_eob_line
left join arpb_transactions arpb_tx_payments on arpb_tx_payments.tx_id = arpb_tx_match.mtch_tx_hx_id

where arpb_tx_charges.outstanding_amt = 0
and arpb_tx_charges.tx_type_c = 1
and arpb_tx_charges.service_date >= @start_date
and arpb_tx_charges.service_date <= @end_date
and sa.serv_area_id in (11,13,16,17,18,19)
and (
eap_charges.proc_code = '99444'
or (eap_charges.proc_code between '99201' and '99215' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '99231' and '99233' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '99307' and '99310' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '96150' and '96154' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '90832' and '90834' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '90791' and '90792' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '90963' and '90970' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '97802' and '97804' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '99406' and '99407' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '99495' and '99498' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '90845' and '90847' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between '99354' and '99357' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between 'G0438' and 'G0439' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between 'G0508' and 'G0509' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between 'G0425' and 'G0427' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between 'G0406' and 'G0408' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between 'G0420' and 'G0421' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between 'G0396' and 'G0397' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code between 'G0442' and 'G0447' and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code in ('G0459','G0270') and arpb_tx_charges.modifier_one = 'GT')
or (eap_charges.proc_code in ('90951','90952','90954','90955','90957','90958','90960','90961') and arpb_tx_charges.modifier_one = 'GT')
)

and arpb_tx_charges.void_date is null
and arpb_tx_payments.void_date is null
and arpb_tx_match.mtch_tx_hx_un_dt is null
)a

group by
 [SERVICE AREA]
,[LOCATION]
,[DEPARTMENT]
,[PROCEDURE]
,[MODIFIER ONE]
,[ACCOUNT]
,[CHARGE ETR ID]
,[SERVICE DATE]
,[MONTH-YEAR]
,[PATIENT]
,[ORIGINAL PAYOR]

order by
 [SERVICE AREA]
,[LOCATION]
,[DEPARTMENT]
,[PROCEDURE]
,[MODIFIER ONE]
,[ACCOUNT]
,[CHARGE ETR ID]
,[SERVICE DATE]
,[MONTH-YEAR]
,[PATIENT]
,[ORIGINAL PAYOR]