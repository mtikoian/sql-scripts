--patient name, mrn, date of service of charge, charge procedure
select 
 sa.name as 'Region'
,tdl.tx_id as 'Charge ETR'
,cast(tdl.orig_service_date as date) as 'Service Date'
,pat.pat_mrn_id as 'Patient MRN'
,pat.pat_name as 'Patient Name'
,eap.proc_code as 'Charge Procedure ID'
,eap.proc_name as 'Charge Procedure Desc'
, cast(EXT_HX_ACT_DATE as date) as 'Date Sent to Collections'
, EXT_HX_PAT_AMT as 'Collection Amount'
,sum(tdl.amount) as 'Recovery Amount'

from clarity_tdl_tran tdl
left join ARPB_TX_COL_EXT_HX atx on atx.tx_id = tdl.tx_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join clarity_eap eap_match on eap_match.proc_id = tdl.match_proc_id
left join patient pat on pat.pat_id = tdl.int_pat_id
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join zc_loc_rpt_grp_10 sa on sa.rpt_grp_ten = loc.rpt_grp_ten


where detail_type = 20
and EXT_HX_ACTIVITY_C = 2 -- sent to collection agency
and tdl.post_date > EXT_HX_ACT_DATE
and EXT_HX_ACT_DATE >= '01/01/17'
and EXT_HX_ACT_DATE <= '09/30/17'
and sa.rpt_grp_ten in (1,11,13,16,17,18,19)
group by 
 sa.name
,tdl.tx_id
,tdl.orig_service_date
,pat.pat_mrn_id
,pat.pat_name
,eap.proc_code
,eap.proc_name
, EXT_HX_ACT_DATE
, EXT_HX_PAT_AMT

order by tdl.tx_id