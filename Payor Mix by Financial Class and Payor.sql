select 
coalesce(fc.financial_class_name,'*Unspecified Financial Class') fc
,coalesce(epm.payor_name,'*Unspecified Payor') payor
,sum ( case when (tdl.detail_type in (2,5,11)) then -1*amount else 0 end) payments

from 
clarity_tdl_tran tdl 
left outer join clarity_fc fc on tdl.original_fin_class=fc.financial_class
left outer join clarity_epm epm on epm.payor_id=tdl.original_payor_id

/*selecting only payments, voided payments, and payment reversals. Does not look at matched payments and hence payments can not be grouped by charge characterstics*/
where
tdl.DETAIL_TYPE in (2,5,11) 
and tdl.serv_area_id in (11,13,16,17,18,19)
and tdl.post_date >= '1/1/2017'

group by 
coalesce(fc.financial_class_name,'*Unspecified Financial Class')
,coalesce(epm.payor_name,'*Unspecified Payor') 

order by 
coalesce(fc.financial_class_name,'*Unspecified Financial Class')
,coalesce(epm.payor_name,'*Unspecified Payor') 