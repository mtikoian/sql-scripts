select 
 cast(tdl.orig_service_date as date) as 'Service Date'
,cast(tdl.orig_post_date as date) as 'Post Date'
,loc.gl_prefix as 'Location GL'
,dep.gl_prefix as 'Department GL'
,tdl.tx_id as 'Charge ID'
,eap.proc_id as 'Procedure ID'
,eap.proc_name as 'Procedure Name'
,ser.prov_id as 'Billing Provider ID'
,ser.prov_name as 'Billing Provider Name'
,acct.account_id as 'Account ID'
,acct.account_name as 'Account Name'
,pat.pat_id as 'Patient ID'
,pat.pat_mrn_id as 'Patient MRN'
,pat.pat_name as 'Patient Name'
,rsh.research_id as 'Research ID'
,rsh.research_name as 'Research Name'
,rsh.rpt_grp_txt_2 'Report GRP 2'
,sum(case when tdl.detail_type in (1,10) then tdl.amount else 0 end) as 'Charge'
,sum(case when tdl.detail_type in (2,5,11,20,22,32,33) then tdl.patient_amount else 0 end) as 'Patient Payment'
,sum(case when tdl.detail_type in (2,5,11,20,22,32,33) then tdl.insurance_amount else 0 end) as 'Insurance Payment'
,sum(case when tdl.detail_type in (4,6,13,21,23,30,31) then tdl.amount else 0 end) as 'Credit Adjustment'
,sum(case when tdl.detail_type in (3,12) then tdl.amount else 0 end) as 'Debit Adjustment'
,max(arpb_tx.outstanding_amt) as 'Outstanding Amount'

from clarity_tdl_tran tdl
left join arpb_transactions2 arpb_tx_2 on arpb_tx_2.tx_id = tdl.tx_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join account acct on acct.account_id = tdl.account_id
left join patient pat on pat.pat_id = tdl.int_pat_id
left join clarity_ser ser on ser.prov_id = tdl.billing_provider_id
left join clarity_dep dep on dep.department_id = tdl.dept_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_rsh rsh on rsh.research_id = arpb_tx_2.research_study_id
left join arpb_transactions arpb_tx on arpb_tx.tx_id = tdl.tx_id

where tdl.detail_type <= 33
and arpb_tx_2.rsh_chg_route_c in (0,1)
and tdl.serv_area_id in (11,13,16,17,18,19)
and acct.account_type_c <> 100
and (rsh.rpt_grp_txt_2 not in ('client')
or rsh.rpt_grp_txt_2 is null)
--and tdl.tx_id = 131875699

group by 
 tdl.orig_service_date
,tdl.orig_post_date
,loc.gl_prefix
,dep.gl_prefix
,tdl.tx_id
,eap.proc_id
,eap.proc_name
,ser.prov_id
,ser.prov_name
,acct.account_id
,acct.account_name
,pat.pat_id
,pat.pat_mrn_id
,pat.pat_name
,rsh.research_id
,rsh.research_name
,rsh.rpt_grp_txt_2

order by 
tdl.tx_id