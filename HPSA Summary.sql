with HPSA as

(

select 

 tdl.tx_id as 'Charge ETR'
,date.monthname_year as 'Post Month'
,cast(tdl.orig_service_date as date) as 'Date of Service'
,ser_bill.prov_id as 'Billing Provider ID'
,ser_bill.prov_name as 'Billing Provider'
,ser2.npi as 'NPI'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Desc'
,tdl.modifier_one as 'Modifier One'
,tdl.modifier_two as 'Modifier Two'
,tdl.dx_one_id as 'Diagnosis One'
,tdl.dx_two_id as 'Diagnosis Two'
,tdl.orig_amt as 'Charge Amount'
,eob.tx_id as 'Payment ETR'
,eob.paid_amt as 'Paid Amount'
,eob.cvd_amt as 'Allowed Amount'
,eob.noncvd_amt as 'Not Allowed Amount'
,eob.ded_amt as 'Deductible Amount'
,eob.copay_amt as 'Copay Amount'
,epm.payor_name as 'EOB Payor'
,pat.pat_name as 'Patient'
,cast(pat.birth_date as date) as 'DOB'
,pat.add_line_1 as 'Address 1'
,pat.add_line_2 as 'Address 2'
,pat.city as 'City'
,pat_state.name as 'State'
,pat.zip as 'Zip'
,eob.ICN as 'ICN'
,cov.subscr_num as 'Subscriber Number'
,irs.irs_num as 'Tax ID'
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id ASC) AS Row

from clarity_tdl_tran tdl
inner join pmt_eob_info_i eob on eob.tdl_id = tdl.tdl_id
left join clarity_ser ser_bill on ser_bill.prov_id = tdl.billing_provider_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_ser_2 ser2 on ser2.prov_id = ser_bill.prov_id
left join clarity_epm epm on epm.payor_id = tdl.cur_payor_id
left join zc_fin_class fc on fc.fin_class_c = tdl.cur_fin_class
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join date_dimension date on date.calendar_dt_str = tdl.post_date
left join patient pat on pat.pat_id = tdl.int_pat_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join coverage cov on cov.coverage_id = eob.coverage_id
left join zc_state pat_state on pat_state.state_c = pat.state_c
left join facility_irs_num irs on irs.facility_id = loc.rpt_grp_two

where
loc.rpt_grp_ten in (16)
and post_date between '03/01/2017' and '3/31/2017'
and fc.name in (
'medicare')
and eob.denial_codes is null
and tdl.orig_amt <> 0
)

select 
 [Charge ETR]
,[Post Month]
,[Date of Service]
,[Billing Provider ID]
,[Billing Provider]
,[NPI]
,[EOB Payor]
,[Procedure Code]
,[Procedure Desc]
,[Modifier One]
,[Modifier Two]
,[Diagnosis One]
,[Diagnosis Two]
,[Patient]
,[Address 1]
,[Address 2]
,[City]
,[State]
,[Zip]
,[ICN]
,[Subscriber Number]
,[Tax ID]
,sum([Charge Amount]) as 'Charge Amount'
,sum([Paid Amount]) as 'Paid Amount'
,sum([Allowed Amount]) as 'Allowed Amount'
,sum([Not Allowed Amount]) as 'Not Allowed Amount'
,sum([Deductible Amount]) as 'Deductible Amount'
,sum([Copay Amount]) as 'Copay Amount'


from
(
select 
 [Charge ETR]
,[Post Month]
,[Date of Service]
,[Billing Provider ID]
,[Billing Provider]
,[NPI]
,[EOB Payor]
,[Procedure Code]
,[Procedure Desc]
,[Modifier One]
,[Modifier Two]
,[Diagnosis One]
,[Diagnosis Two]
,[Patient]
,[Address 1]
,[Address 2]
,[City]
,[State]
,[Zip]
,[ICN]
,[Subscriber Number]
,[Tax ID]
,[Charge Amount]
,[Paid Amount]
,[Allowed Amount]
,[Not Allowed Amount]
,[Deductible Amount]
,[Copay Amount]

from hpsa 
where row = 1

)a

group by 
 [Charge ETR]
,[Post Month]
,[Date of Service]
,[EOB Payor]
,[Billing Provider ID]
,[Billing Provider]
,[NPI]
,[Procedure Code]
,[Procedure Desc]
,[Modifier One]
,[Modifier Two]
,[Diagnosis One]
,[Diagnosis Two]
,[Patient]
,[Address 1]
,[Address 2]
,[City]
,[State]
,[Zip]
,[ICN]
,[Subscriber Number]
,[Tax ID]

order by [Charge ETR]