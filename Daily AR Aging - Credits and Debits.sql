
declare @end_date as date = EPIC_UTIL.EFN_DIN('me-1')


select 


 cur_fc.name + ' [' + cur_fc.fin_class_c + ']' as 'Current FC'
,sum(case when getdate()-1 - tdl.orig_post_date <= 30 then outstanding_amt else 0 end) as '0 - 30'
,sum(case when getdate()-1 - tdl.orig_post_date >= 31 and getdate()-1 - tdl.orig_post_date <= 60 then outstanding_amt else 0 end) as '31 - 60'
,sum(case when getdate()-1 - tdl.orig_post_date >= 61 and getdate()-1 - tdl.orig_post_date <= 90 then outstanding_amt else 0 end) as '61 - 90'
,sum(case when getdate()-1 - tdl.orig_post_date >= 91 and getdate()-1 - tdl.orig_post_date <= 120 then outstanding_amt else 0 end) as '91 - 120'
,sum(case when getdate()-1 - tdl.orig_post_date >= 121 and getdate()-1 - tdl.orig_post_date <= 180 then outstanding_amt else 0 end) as '121 - 180'
,sum(case when getdate()-1 - tdl.orig_post_date >= 181 and getdate()-1 - tdl.orig_post_date <= 270 then outstanding_amt else 0 end) as '181 - 270'
,sum(case when getdate()-1 - tdl.orig_post_date >= 271 and getdate()-1 - tdl.orig_post_date <= 365 then outstanding_amt else 0 end) as '271 - 365'
,sum(case when getdate()-1 - tdl.orig_post_date > 365 then outstanding_amt else 0 end) as '+ 365'
,sum(age.outstanding_amt) as 'Amount'

from clarity.dbo.arpb_transactions age
left join clarity_tdl_tran tdl on tdl.tx_id = age.tx_id and tdl.detail_type = 1
left join clarity.dbo.clarity_sa sa on sa.serv_area_id = age.service_area_id
left join clarity.dbo.zc_fin_class cur_fc on cur_fc.fin_class_c = tdl.cur_fin_class

where sa.serv_area_id in (1312)


group by 
 cur_fc.name + ' [' + cur_fc.fin_class_c + ']'

order by 
 cur_fc.name + ' [' + cur_fc.fin_class_c + ']'