select 
-- tx.SERVICE_DATE
--,hx.EDIT_DATE
--,hx.TX_ID
--,OLD_VALUE
--,NEW_VALUE
--,REPOST_YN
 count(*) as count
from 
ARPB_TX_EDIT_HX hx
left join ARPB_TRANSACTIONS tx  on tx.TX_ID = hx.TX_ID
where tx.SERVICE_DATE between '7/1/2018' and '9/30/2018'
and tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
and (hx.REPOST_YN = 'N' or hx.REPOST_YN is null)
and hx.line = 1


--select 
--count(*) as count
--from 
--ARPB_TRANSACTIONS tx
--where tx.SERVICE_DATE between '9/1/2018' and '9/30/2018'
--and tx.SERVICE_AREA_ID in (11,13,16,17,18,19)
--and tx_type_C = 1