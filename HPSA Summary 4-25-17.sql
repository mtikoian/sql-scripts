select 
-- tdl.tdl_id as 'TDL ID'
 tdl.tx_id as 'Charge ETR'
,cast(tdl.orig_service_date as date) as 'Service Date'
,cast(tdl.post_date as date) as 'Payment Post Date'
,upper(sa.name) + ' [' + sa.rpt_grp_ten + ']'  as 'Region'
,loc.rpt_grp_three + ' [' + loc.rpt_grp_two + ']' as 'Location'
,dep.rpt_grp_two + ' [' + dep.rpt_grp_one + ']'  as 'Department'
,pos.pos_name + ' [' + cast(pos.pos_id as varchar) + ']'  as 'POS' 
,pos.pos_type as 'POS Type'
,pos.address_line_1 + ' ' + isnull(pos.address_line_2,'') as 'POS Address'
,pos.city as 'POS City'
,pos_state.name as 'POS State'
,pos.zip as 'POS Zip'
,ser_bill.prov_name as 'Billing Provider'
,ser2.npi as 'NPI'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Desc'
,epm.payor_name as 'Current Payor'
,isnull(tdl.modifier_one,'') as 'Modifier One'
,isnull(tdl.modifier_two,'') as 'Modifier Two'
,isnull(edg.CURRENT_ICD9_LIST,'') as 'Diagnosis One ICD9'
,isnull(edg.CURRENT_ICD10_LIST,'') as 'Diagnosis One ICD10'
,isnull(edg2.CURRENT_ICD9_LIST,'') as 'Diagnosis Two ICD9'
,isnull(edg2.CURRENT_ICD10_LIST,'') as 'Diagnosis Two ICD10'
,isnull(eob.icn,'') as 'ICN'
,cov.subscr_num as 'Subscriber Number'
,case when irs_loc.irs_num is not null then irs_loc.irs_num 
	else irs_sa.irs_num end as 'IRS Number'
,case when eaf_loc.clm_alt_addr_name is not null then isnull(eaf_loc.clm_alt_addr_name,'')
	else isnull(eaf_sa.clm_alt_addr_name,'') end as 'Alternate Address'
,case when eaf_loc.clm_alt_addr_city is not null then isnull(eaf_loc.clm_alt_addr_city,'')
	else isnull(eaf_sa.clm_alt_addr_city,'') end as 'Alternate City'
,case when alt_loc_state.name is not null then isnull(alt_loc_state.name,'')
	else isnull(alt_sa_state.name,'') end as 'Alternate State'
,case when eaf_loc.clm_alt_addr_zip is not null then isnull(eaf_loc.clm_alt_addr_zip,'')
	else isnull(eaf_sa.clm_alt_addr_zip,'') end as 'Alternate Zip'
,pat.pat_name as 'Patient'
,cast(pat.birth_date as date) as 'DOB'
,pat.add_line_1 + ' ' + isnull(pat.add_line_2,'') as 'Patient Address'
,pat.city as 'City'
,pat_state.name as 'State'
,pat.zip as 'Zip'
,tdl2.procedure_quantity as 'Units'
,tdl.orig_amt as 'Charge Amount'
,eob.tx_id as 'Payment ETR'
,isnull(cast(eob.paid_amt as varchar),'') as 'Paid Amount'
,isnull(cast(eob.cvd_amt as varchar),'') as 'Allowed Amount'
,isnull(cast(eob.noncvd_amt as varchar),'') as 'Not Allowed Amount'
,isnull(cast(eob.ded_amt as varchar),'') as 'Deductible Amount'
,isnull(cast(eob.copay_amt as varchar),'') as 'Copay Amount'
,isnull(cast(eob.coins_amt as varchar),'') as 'Co-Insurance'
--,arpb.outstanding_amt as 'Outstanding Amount'
--,ROW_NUMBER() OVER(PARTITION BY tdl.tx_id ORDER BY tdl.tdl_id ASC) AS Row

from clarity_tdl_tran tdl
inner join pmt_eob_info_i eob on eob.tdl_id = tdl.tdl_id
left join zc_fin_class fc on fc.fin_class_c = tdl.cur_fin_class
left join coverage cov on cov.coverage_id = tdl.cur_cvg_id
left join clarity_epm epm on epm.payor_id = tdl.cur_payor_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_pos pos on pos.pos_id = tdl.pos_id
left join zc_state pos_state on pos_state.state_c = pos.state_c
left join facility_irs_num irs_loc on irs_loc.facility_id = loc.rpt_grp_two
left join facility_irs_num irs_sa on irs_sa.facility_id = sa.rpt_grp_ten
left join clarity_ser ser_bill on ser_bill.prov_id = tdl.billing_provider_id
left join clarity_ser_2 ser2 on ser2.prov_id = ser_bill.prov_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join patient pat on pat.pat_id = tdl.int_pat_id
left join zc_state pat_state on pat_state.state_c = pat.state_c
left join arpb_transactions arpb on arpb.tx_id = tdl.tx_id
left join clarity_tdl_tran tdl2 on tdl2.tx_id = tdl.tx_id and tdl2.detail_type = 1
left join clarity_edg edg on edg.dx_id = tdl.dx_one_id
left join clarity_edg edg2 on edg2.dx_id = tdl.dx_two_id
left join eaf_clm_altadr_inf eaf_loc on eaf_loc.facility_id = loc.rpt_grp_two
left join eaf_clm_altadr_inf eaf_sa on eaf_sa.facility_id = sa.rpt_grp_ten
left join zc_state alt_loc_state on alt_loc_state.state_c = eaf_loc.clm_alt_addr_st_c
left join zc_state alt_sa_state on alt_sa_state.state_c = eaf_sa.clm_alt_addr_st_c
where
tdl.orig_service_date >= '1/01/2012'
and tdl.orig_service_date <= '4/30/2017'
and epm.payor_name in ('Medicare')
and tdl.orig_amt <> 0 -- Exclude Original Amount = 0
and eob.paid_amt <> 0 -- Exclude Paid Amount = 0
and eob.denial_codes is null -- Exclude Denials
and sa.rpt_grp_ten in (11,13,16,17,18,19)
and pos.rpt_grp_one in 
(
 '591'
,'1138'
,'1100458'
,'1100517'
,'1100671'
,'1600145'
,'1900108'
,'1900109'
,'1900201'
,'19101133'
,'98000085'
,'1300000179'
,'1300000180'
,'1300000181'
,'1300000182'
,'1700000014'
,'1700000015'
,'1700000115'
,'1700000200'
,'1800000067'
,'1800000093'
,'1800000121'
,'1800000156'
,'1800000323'
,'1800000420'
,'1800000421'
,'1800000422'
,'1800000424'
,'1812007201'
,'1800000093'
,'1900000121'
,'1900000122'
,'1900000504'
,'1939011801'
,'1800000384'
,'1812007201'
,'1800000384'
,'1800000067'
,'1800000424'
,'3040880266'
,'3050000002'
,'3050000003'
,'3050000004'
,'3050000006'
,'3060000003'
,'3101000101'
,'3101000201'
,'4030000057'
,'4030000061'
,'4030000062'
,'4030000064'
)
order by
case when irs_loc.irs_num is not null then irs_loc.irs_num 
 else irs_sa.irs_num end