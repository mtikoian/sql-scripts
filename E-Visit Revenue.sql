select 

sum(tdl.AMOUNT) * -1 as 'Payment'

from CLARITY_TDL_TRAN tdl
left join CLARITY_EAP eap on eap.PROC_ID = tdl.PROC_ID

where tdl.DETAIL_TYPE = 20 -- Charge matched to payment
and eap.PROC_CODE in ('99444','98969')
and tdl.POST_DATE >= '3/1/2018'
and tdl.POSt_DATE <= '2/28/2019'
and tdl.SERV_AREA_ID in (11,13,16,17,18,19)
