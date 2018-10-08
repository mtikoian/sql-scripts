select 

*
from

(select 
 tdl.tx_id as 'Chg ID'
,cast(tdl.orig_service_date as date) as 'Service Date'
,cast(tdl.post_date as date) as 'Post Date'
,tdl.int_pat_id as 'Pat ID'
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
and void.tx_id is null -- remove voids
and tdl.orig_service_date >= '1/1/2017'
) a,

(select 
 tdl.tx_id as 'Chg ID'
,cast(tdl.orig_service_date as date) as 'Service Date'
,cast(tdl.post_date as date) as 'Post Date'
,tdl.int_pat_id as 'Pat ID'
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
and
(tdl.CPT_CODE>='96150' and tdl.CPT_CODE<='96154' or 
                tdl.CPT_CODE>='90800' and tdl.CPT_CODE<='90884' or 
                tdl.CPT_CODE>='90886' and tdl.CPT_CODE<='90899' or 
                tdl.CPT_CODE>='99024' and tdl.CPT_CODE<='99069' or 
                tdl.CPT_CODE>='99071' and tdl.CPT_CODE<='99079' or 
                tdl.CPT_CODE>='99081' and tdl.CPT_CODE<='99144' or 
                tdl.CPT_CODE>='99146' and tdl.CPT_CODE<='99149' or 
                tdl.CPT_CODE>='99151' and tdl.CPT_CODE<='99172' or 
                tdl.CPT_CODE>='99174' and tdl.CPT_CODE<='99291' or 
                tdl.CPT_CODE>='99293' and tdl.CPT_CODE<='99359' or 
                tdl.CPT_CODE>='99375' and tdl.CPT_CODE<='99480' or 
                tdl.CPT_CODE='98969' or
                tdl.CPT_CODE='99361' or 
                tdl.CPT_CODE='99373' or 
				tdl.CPT_CODE='90791' or 
				tdl.CPT_CODE='90792' or 
				tdl.CPT_CODE='99495' or 
				tdl.CPT_CODE='99496' or 
                tdl.CPT_CODE='G0402' or 
                tdl.CPT_CODE='G0406' or 
                tdl.CPT_CODE='G0407' or 
                tdl.CPT_CODE='G0408' or 
                tdl.CPT_CODE='G0409' or 
                tdl.CPT_CODE='G0438' or 
                tdl.CPT_CODE='G0439'
				)
and fc.name in ('Bx Traditional','Bx Managed')
and void.tx_id is null -- remove voids
and tdl.orig_service_date >= '1/1/2017'

)b

where a.[service date] = b.[service date] and a.[pat id] = b.[pat id]

order by a.[service date], a.[pat id] asc