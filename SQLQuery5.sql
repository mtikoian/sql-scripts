with HPSA as

(

select 

max(case when sa.serv_area_id = 19 then 'KENTUCKY' else sa.serv_area_name end) as 'Service Area'
,max(dep.department_name) as 'Department'
,max(pos.pos_name) as 'Place of Service'
,max(pos.pos_type) as 'POS Type'
,max(pos.address_line_1) as 'Address Line 1'
,max(coalesce(pos.address_line_2,'')) as 'Address Line 2'
,max(pos.zip) as 'Zip'
,max(state.name) as 'State'
,max(epm.payor_name) as 'EOB Payor'
,max(fc.name) as 'EOB FC'
,max(date.month_year) as 'Post Month'
,max(ser.prov_name) as 'Billing Provider'
,max(ser_2.npi) as 'NPI'
,max(spec.name) as 'Provider Specialty'
,sum(tdl.orig_amt) as 'Charge Amount'
,sum(eob.paid_amt) as 'Paid Amount'
,sum(eob.cvd_amt) as 'Allowed Amount'
,sum(eob.noncvd_amt) as 'Not Allowed Amount'
,sum(eob.ded_amt) as 'Deductible Amount'
,sum(eob.copay_amt) as 'Copay Amount'
,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id ASC) AS Row

from clarity_tdl_tran tdl
inner join pmt_eob_info_i eob on eob.tdl_id = tdl.tdl_id
inner join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
inner join clarity_eap eap on eap.proc_id = tdl.proc_id
inner join clarity_ser_2 ser_2 on ser_2.prov_id = ser.prov_id
left join zc_specialty spec on spec.specialty_c = tdl.prov_specialty_c
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join zc_state state on state.state_c = pos.state_c
left join clarity_epm epm on epm.payor_id = tdl.cur_payor_id
left join zc_fin_class fc on fc.fin_class_c = tdl.cur_fin_class
left join clarity_sa sa on sa.serv_area_id = tdl.serv_area_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join date_dimension date on date.calendar_dt_str = tdl.post_date

where
tdl.serv_area_id in (11,13,16,17,18,19)
and post_date between '10/1/2015' and '9/30/2016'
and fc.name in (
'commercial'
,'blue shield'
,'bx traditional'
,'medicare managed'
,'medicaid managed'
,'bx managed'
,'managed care'
,'medicare'
,'medicaid'
,'tricare'
,'champva'
,'group health plan'
,'feca black lung')
and eob.denial_codes is null
)

select 
 [Charge ETR]
,[Service Date]
,[Orig Post Date]
,[Post Date]
,[Billing Provider]
,[NPI]
,[Provider Specialty]
,[Procedure Code]
,[Procedure Desc]
,[Charge Amount]
,[Payment ETR]
,[Paid Amount]
,[Allowed Amount]
,[Not Allowed Amount]
,[Deductible Amount]
,[Copay Amount]
,[Service Area]
,[Department]
,[Place of Service]
,[POS Type]
,[Address Line 1]
,[Address Line 2]
,[Zip]
,[State]
,[EOB Payor]
,[EOB FC]
from hpsa 
where row = 1

order by [Charge ETR]