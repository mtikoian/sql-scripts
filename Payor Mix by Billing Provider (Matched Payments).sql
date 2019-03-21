select 
 ser.PROV_NAME as 'Billing Provider'
,fc.financial_class_name as 'Original Financial Class'
,epm.payor_name as 'Original Payor'
,sum (tdl.amount)*-1 as Payments

from 
clarity_tdl_tran tdl 
left outer join clarity_fc fc on tdl.original_fin_class=fc.financial_class
left outer join clarity_epm epm on epm.payor_id=tdl.original_payor_id
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID

/*selecting only payments, voided payments, and payment reversals. Does not look at matched payments and hence payments can not be grouped by charge characterstics*/
where
tdl.DETAIL_TYPE in (20) 
and tdl.serv_area_id in (11,13,16,17,18,19)
and tdl.post_date >= '1/1/2016'
and tdl.post_date <= '12/31/2018'
and tdl.BILLING_PROVIDER_ID = '1728374'
and tdl.amount <> 0

group by
ser.PROV_NAME
,fc.financial_class_name
,epm.payor_name

order by
ser.PROV_NAME
,fc.financial_class_name
,epm.payor_name