declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-6')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-6')
 
 ---BALANCE COLLECTED
select 

collected.REGION
,collected.YEAR_MONTH
,collected.MONTH_YEAR
,collected.BALANCE_COLLECTED
,expected.BALANCE_EXPECTED
,case when expected.balance_expected is null then 0 else collected.balance_collected/expected.balance_expected end as 'BALANCE PERCENTAGE COLLECTED'

from

(
select 
	--REGION
 case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104, -- OLD LIMA
					     19132,19133) then 'LIMA' -- NEW LIMA
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113 -- OLD LORAIN
						,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN' -- NEW LORAIN
	 when loc.loc_id in (18120,18121, -- OLD DEFIANCE
						 19120,19127) then 'TOLEDO' -- NEW DEFIANCE
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133, -- OLD TOLEDO
						 19119,19121,19122,19123,19124,19128,19129,19130,19131)  then 'TOLEDO' -- NEW TOLEDO
	 when loc.loc_id in (18110, -- OLD MRG
						 19126) then 'TOLEDO' -- NEW MRG
	 when loc.loc_id in (19101,19102,19106) then 'KENTUCKY' 
	 when loc.loc_id in (19107,19108,19116,19118) then 'KENTUCKY' -- KY OTHER ENTITIES
	 end as REGION
,dd.year_month as 'YEAR_MONTH'
,dd.monthname_year as 'MONTH_YEAR'
,sum(tdl.amount)*-1 as 'BALANCE_COLLECTED'

from

clarity_tdl_tran tdl
left join clarity_dep dep on dep.department_id = tdl.dept_id  
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join account acct on acct.account_id = tdl.account_id
left join arpb_transactions arpb_tx on arpb_tx.tx_id = tdl.tx_id
left join zc_payment_source zps on zps.payment_source_c = tdl.orig_pay_source_c
left join clarity_emp emp on emp.user_id = tdl.user_id
left join zc_mtch_dist_src zmds on zmds.mtch_tx_hx_dist_c = arpb_tx.credit_src_module_c
left join date_dimension dd on dd.calendar_dt_str = tdl.post_date
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id

where 

eap.proc_code in ('1000','1002','1005','1006','1009','6008','8006') 

/*PROC_CODE	PROC_NAME
1000	PATIENT PAYMENT (ACCOUNT)
1002	PRE-PAYMENT (ACCOUNT)
1005	OB PRE-PAYMENT (ACCOUNT)
1006	COLLECTION AGENCY PAYMENT (ACCOUNT)
1009	BARIATRICS PRE-PAYMENT (ACCOUNT)
6008	PAYMENT REVERSAL (ACCOUNT)
8006	CLIENT PAYMENT (ACCOUNT)
*/

and tdl.detail_type in (2,3,4,5,6,11,12,13)

/*DETAIL_TYPE	NAME
2	New Payment
3	New Debit Adjustment
4	New Credit Adjustment
5	Payment Reversal
6	Credit Adjustment Reversal
11	Void Payment
12	Void Debit Adjustment
13	Void Credit Adjustment
*/

and tdl.post_date >= @start_date
and tdl.post_date <= @end_date

	and loc.loc_id in (11106,11124,11149 -- SPRINGFILED
	,11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138 -- CINCINNATI
	,13104,13105,13116,19142,19143,19144,19145 -- YOUNGSTOWN
	,16102,16103,16104 -- OLD LIMA
	,19132,19133-- NEW LIMA
	,17105,17106,17107,17108,17109,17110,17112,17113-- OLD LORAIN
	,19135,19136,19137,19138,19139,19140,19141 -- NEW LORAIN
	,18120,18121-- OLD DEFIANCE
	,19120,19127 -- NEW DEFIANCE
	,18101,18102,18103,18104,18105,18130,18131,18132,18133 -- OLD TOLEDO
	,19119,19121,19122,19123,19124,19128,19129,19130,19131 -- NEW TOLEDO
	,18110 -- OLD TOLEDO MRG
	,19126 -- NEW TOLEDO MRG
	,19101,19102,19106 -- KENTUCKY
	,19107,19108,19116,19118 -- KENTUCKY - OTHER ENTITIES
	)
and dep.department_id not in ('11102101','13104134','16104001','17109101','18104110','19101110','19000001'
,'11101450',
'11104101',
'11105102',
'11107101',
'11107119',
'11107147',
'11108120',
'11108135',
'11108140',
'11108145',
'11108162',
'11108164',
'11110110',
'11110122',
'11110143',
'11111122',
'11114118',
'11114129',
'11114133',
'11114152',
'11115000',
'11115001',
'11117102',
'11121001',
'11121003',
'11139001',
'11140001',
'11101408',
'11104103',
'11146001',
'11101185')

and (ser.prov_id not in
('1100199',
'1007831',
'1000645',
'1000242',
'1005602',
'1008668',
'1008696',
'1000732',
'1611492',
'1000045',
'1009542'
) or ser.prov_id is null)
group by 
 case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104, -- OLD LIMA
					     19132,19133) then 'LIMA' -- NEW LIMA
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113 -- OLD LORAIN
						,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN' -- NEW LORAIN
	 when loc.loc_id in (18120,18121, -- OLD DEFIANCE
						 19120,19127) then 'TOLEDO' -- NEW DEFIANCE
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133, -- OLD TOLEDO
						 19119,19121,19122,19123,19124,19128,19129,19130,19131)  then 'TOLEDO' -- NEW TOLEDO
	 when loc.loc_id in (18110, -- OLD MRG
						 19126) then 'TOLEDO' -- NEW MRG
	 when loc.loc_id in (19101,19102,19106) then 'KENTUCKY' 
	 when loc.loc_id in (19107,19108,19116,19118) then 'KENTUCKY' -- KY OTHER ENTITIES
	 end
,dd.year_month
,dd.monthname_year

)as collected,

(
select 
	--REGION
 case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104, -- OLD LIMA
					     19132,19133) then 'LIMA' -- NEW LIMA
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113 -- OLD LORAIN
						,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN' -- NEW LORAIN
	 when loc.loc_id in (18120,18121, -- OLD DEFIANCE
						 19120,19127) then 'TOLEDO' -- NEW DEFIANCE
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133, -- OLD TOLEDO
						 19119,19121,19122,19123,19124,19128,19129,19130,19131)  then 'TOLEDO' -- NEW TOLEDO
	 when loc.loc_id in (18110, -- OLD MRG
						 19126) then 'TOLEDO' -- NEW MRG
	 when loc.loc_id in (19101,19102,19106) then 'KENTUCKY' 
	 when loc.loc_id in (19107,19108,19116,19118) then 'KENTUCKY' -- KY OTHER ENTITIES
	 end as REGION
,dd.year_month as 'YEAR_MONTH'
,dd.monthname_year as 'MONTH_YEAR'
,sum(patient_amount) as 'BALANCE_EXPECTED'

from 
clarity_tdl_age age
left join clarity_dep dep on dep.department_id = age.dept_id
left join clarity_loc loc on loc.loc_id = age.loc_id
left join date_dimension dd on dd.calendar_dt_str = age.tdl_extract_date
left join patient pat on pat.pat_id = age.int_pat_id
left join clarity_ser ser on ser.prov_id = age.billing_provider_id
inner join 
(select 
distinct pat.pat_id
from pat_enc enc
left join pat_enc_2 enc2 on enc2.pat_enc_csn_id = enc.pat_enc_csn_id 
left join clarity_dep dep on dep.department_id = enc.department_id
left join clarity_loc loc on loc.loc_id = dep.rev_loc_id
left join clarity_pos pos on pos.pos_id = enc2.visit_pos_id
left join patient pat on pat.pat_id = enc.pat_id
where appt_status_c in (2,6) -- Arrived or Completed
and  enc.contact_date >= @start_date
and enc.contact_date <= @end_date
	and loc.loc_id in (11106,11124,11149 -- SPRINGFILED
	,11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138 -- CINCINNATI
	,13104,13105,13116,19142,19143,19144,19145 -- YOUNGSTOWN
	,16102,16103,16104 -- OLD LIMA
	,19132,19133-- NEW LIMA
	,17105,17106,17107,17108,17109,17110,17112,17113-- OLD LORAIN
	,19135,19136,19137,19138,19139,19140,19141 -- NEW LORAIN
	,18120,18121-- OLD DEFIANCE
	,19120,19127 -- NEW DEFIANCE
	,18101,18102,18103,18104,18105,18130,18131,18132,18133 -- OLD TOLEDO
	,19119,19121,19122,19123,19124,19128,19129,19130,19131 -- NEW TOLEDO
	,18110 -- OLD TOLEDO MRG
	,19126 -- NEW TOLEDO MRG
	,19101,19102,19106 -- KENTUCKY
	,19107,19108,19116,19118 -- KENTUCKY - OTHER ENTITIES
	)
) enc on enc.pat_id = pat.pat_id

where age.tdl_extract_date = @start_date
and age.patient_amount > 0
		and loc.loc_id in (11106,11124,11149 -- SPRINGFILED
	,11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138 -- CINCINNATI
	,13104,13105,13116,19142,19143,19144,19145 -- YOUNGSTOWN
	,16102,16103,16104 -- OLD LIMA
	,19132,19133-- NEW LIMA
	,17105,17106,17107,17108,17109,17110,17112,17113-- OLD LORAIN
	,19135,19136,19137,19138,19139,19140,19141 -- NEW LORAIN
	,18120,18121-- OLD DEFIANCE
	,19120,19127 -- NEW DEFIANCE
	,18101,18102,18103,18104,18105,18130,18131,18132,18133 -- OLD TOLEDO
	,19119,19121,19122,19123,19124,19128,19129,19130,19131 -- NEW TOLEDO
	,18110 -- OLD TOLEDO MRG
	,19126 -- NEW TOLEDO MRG
	,19101,19102,19106 -- KENTUCKY
	,19107,19108,19116,19118 -- KENTUCKY - OTHER ENTITIES
	)
and dep.department_id not in ('11102101','13104134','16104001','17109101','18104110','19101110','19000001'
,'11101450',
'11104101',
'11105102',
'11107101',
'11107119',
'11107147',
'11108120',
'11108135',
'11108140',
'11108145',
'11108162',
'11108164',
'11110110',
'11110122',
'11110143',
'11111122',
'11114118',
'11114129',
'11114133',
'11114152',
'11115000',
'11115001',
'11117102',
'11121001',
'11121003',
'11139001',
'11140001',
'11101408',
'11104103',
'11146001',
'11101185')
and (ser.prov_id not in
('1100199',
'1007831',
'1000645',
'1000242',
'1005602',
'1008668',
'1008696',
'1000732',
'1611492',
'1000045',
'1009542'
) or ser.prov_id is null)
group by 
 case when loc.loc_id in (11106,11124,11149)  then 'SPRINGFIELD'
	 when loc.loc_id in (11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,11141,11142,11143,11144,11146,11151,11132,11138) then 'CINCINNATI'
	 when loc.loc_id in (13104,13105,13116,19142,19143,19144,19145) then 'YOUNGSTOWN'
	 when loc.loc_id in (16102,16103,16104, -- OLD LIMA
					     19132,19133) then 'LIMA' -- NEW LIMA
	 when loc.loc_id in (17105,17106,17107,17108,17109,17110,17112,17113 -- OLD LORAIN
						,19135,19136,19137,19138,19139,19140,19141) then 'LORAIN' -- NEW LORAIN
	 when loc.loc_id in (18120,18121, -- OLD DEFIANCE
						 19120,19127) then 'TOLEDO' -- NEW DEFIANCE
	 when loc.loc_id in (18101,18102,18103,18104,18105,18130,18131,18132,18133, -- OLD TOLEDO
						 19119,19121,19122,19123,19124,19128,19129,19130,19131)  then 'TOLEDO' -- NEW TOLEDO
	 when loc.loc_id in (18110, -- OLD MRG
						 19126) then 'TOLEDO' -- NEW MRG
	 when loc.loc_id in (19101,19102,19106) then 'KENTUCKY' 
	 when loc.loc_id in (19107,19108,19116,19118) then 'KENTUCKY' -- KY OTHER ENTITIES
	 end
,dd.year_month
,dd.monthname_year
) as expected 

where expected.region = collected.region and expected.year_month = collected.year_month
