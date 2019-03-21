select 
 date.YEAR
,ser.PROV_NAME as 'Billing Provider'
,fc.financial_class_name as 'Original Financial Class'
,epm.payor_name as 'Original Payor'
,sum (tdl.amount) as 'Charges'

from 
clarity_tdl_tran tdl 
left outer join clarity_fc fc on tdl.original_fin_class=fc.financial_class
left outer join clarity_epm epm on epm.payor_id=tdl.original_payor_id
left join CLARITY_SER ser on ser.PROV_ID = tdl.BILLING_PROVIDER_ID
left join DATE_DIMENSION date on date.CALENDAR_DT = tdl.POST_DATE

/*selecting only payments, voided payments, and payment reversals. Does not look at matched payments and hence payments can not be grouped by charge characterstics*/
where
tdl.DETAIL_TYPE in (1,10) 
and tdl.serv_area_id in (11,13,16,17,18,19)
and tdl.post_date >= '1/1/2016'
and tdl.post_date <= '5/18/2018'
and tdl.BILLING_PROVIDER_ID = '1000669'

group by
 date.YEAR
,ser.PROV_NAME
,fc.financial_class_name
,epm.payor_name

order by
 date.YEAR
,ser.PROV_NAME
,fc.financial_class_name
,epm.payor_name