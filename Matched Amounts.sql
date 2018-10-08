--User is Suzy Shuler #419-698-8560

--User needs a specialized report for accounting set up to include:

--DOSs collected for 1/1/2015 and 12/31/2015, amounts that were collected, amounts that were written off, and the amounts that are still not collected.
--And another report set up for 1/1/2016 to date set up as a different report would be helpful also is possible.

--Location:
--Renal Services of Toledo
--2702 Navarre Ave Ste 201
--Oregon, OH 43616


select 
 arpb_tx.tx_id as 'Charge ETR'
,arpb_tx.amount as 'Charge Amount'
,arpb_tx.TOTAL_MATCH_AMT - arpb_tx.TOTAL_MTCH_INS_AMT - (arpb_tx.TOTAL_MTCH_ADJ - arpb_tx.TOTAL_MTCH_INS_ADJ) as 'Patient Payments'
,arpb_tx.TOTAL_MTCH_INS_AMT - arpb_tx.TOTAL_MTCH_INS_ADJ as 'Insurance Payments'
,arpb_tx.TOTAL_MTCH_ADJ - arpb_tx.TOTAL_MTCH_INS_ADJ as 'Other Adjustments'
,arpb_tx.TOTAL_MTCH_INS_ADJ as 'Insurance Adjustments'
,arpb_tx.OUTSTANDING_AMT as 'Outstanding Amount'
from arpb_transactions arpb_tx


where arpb_tx.service_area_id = 601
and arpb_tx.service_date >= '1/1/2015'
and arpb_tx.service_date <= '12/31/2015'
and arpb_tx.tx_type_c = 1
and arpb_tx.void_date is null

