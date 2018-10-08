/*
Total charges in which we billed on the same DOS a 25 modifier (this would be on an E/M charge – 
i.e one of the Mercy visit CPT codes if you would need those for a filter; otherwise ignore the italic details) 
and a CPT in the following range: 10000 – 69999 for those with the original financial class of Bx Traditional or Bx Managed
*/

select 
 tdl.tx_id as 'Chg ID'
,cast(tdl.orig_service_date as date) as 'Service Date'
,cast(tdl.post_date as date) as 'Post Date'
,eap.proc_code as 'Procedure Code'
,eap.proc_name as 'Procedure Desc'
,tdl.modifier_one as 'Modifer One'
,tdl.amount as 'Chg Amount'
from clarity_tdl_tran tdl
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join zc_fin_class fc on fc.fin_class_c = tdl.original_fin_class
left join arpb_tx_void void on void.tx_id = tdl.tx_id
where detail_type in (1,10) -- new charges, voided charges
and tdl.serv_area_id in (11,13,16,17,18,19) -- Mercy Health
and eap.proc_code between '10000' and '69999'
and fc.name in ('Bx Traditional','Bx Managed')
and tdl.modifier_one = '25'
and void.tx_id is null -- remove voids
order by tdl.tx_id asc