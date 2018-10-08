declare @start_date as date = EPIC_UTIL.EFN_DIN('mb-1') 
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1') 

select 


 date.YEAR_MONTH as 'Year-Month'
,cast(tdl.post_date as date) 'Post Date'
,cast(tdl.orig_service_date as date) 'Service Date'
,tdl.account_id 'Account'
,tdl.amount * -1  'Amount'
,tdl.cpt_code 'CPT Code'
,eap_match.proc_code 'Final Denial Code'
,eap_match.proc_name 'Final Denial Desc'
,epm.payor_name 'Payor'
,epp.benefit_plan_name 'Plan'
--,epm.financial_class 'Fin Class'
,fc.financial_class_name 'Financial Class'
--,sa.RPT_GRP_TEN 'Service Area ID'
,sa.NAME as 'Region'
--,loc.LOC_ID 'Location ID'
,loc.loc_name 'Location Name'
,dep.department_name 'Department'
,ser.prov_name 'Billing Provider'
,tdl.tx_id 'Charge ID'
,tdl.match_trx_id 'Final Denial ID'
--,tdl.user_id 'User ID'
--,arpb_tx.USER_ID 'User ID Adj'
,emp.name 'User'


from clarity_tdl_tran tdl
left join ARPB_TRANSACTIONS arpb_tx on arpb_tx.tx_id = tdl.match_trx_id
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join clarity_epm epm on epm.payor_id = tdl.CUR_PAYOR_ID
left join clarity_epp epp on epp.benefit_plan_id = tdl.CUR_PLAN_ID
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_fc fc on fc.financial_class = epm.financial_class
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
left join clarity_emp emp on emp.user_id = arpb_tx.user_id
left join ZC_LOC_RPT_GRP_10 sa on sa.RPT_GRP_TEN = loc.RPT_GRP_TEN
left join DATE_DIMENSION date on date.CALENDAR_DT = tdl.POST_DATE

where

tdl.post_date >= @start_date
and tdl.post_date <= @end_date
and eap_match.proc_code in ('4017','4018','4019','4020','4021','3011','3012','3013','3014','3015','3018','3019','3052','5036')
and loc.loc_id in (11106,11124,11149 
	 ,11101,11102,11103,11104,11105,11115,11116,11122,11139,11140,1114,11142,11143,11144,11146,11151,11132,1113
	 ,13104,13105,13116 
	 ,16102,16103,16104,19132,19133,19134 
	 ,17105,17106,17107,17108,17109,17110,17112,17113,19135,19136,19137,19138,19139,19140,19141 
	 ,18120,18121,19120,19127 
	 ,18101,18102,18103,18104,18105,18130,18131,18132,18133,19119,19128,19129,19130,19131,19121,19122,19123,19124 
	 ,19101,19102,19106 
	 ,131201,131202)
