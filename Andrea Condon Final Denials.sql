/*
Denial
ytd as of 9/30
month of post date
denials by performing provider
by final denial pay code (all adjustment pay codes)
adjustment amount, 
total charge 
service area
% denied

not the one for the scorecard (8-11%)

PROC_NAME	PROC_CODE
DENIAL ADJ (INSURANCE)	3003
CREDENTIALING ADJUSTMENT (INSURANCE)	3011
NON PAR CREDENTIALING ADJUSTMENT (INSURANCE)	3012
PRIOR AUTH REQUIRED ADJUSTMENT (INSURANCE)	3015
DENIAL TIMELY FILING ADJUSTMENT (INSURANCE)	3018
UNTIMELY FOLLOW UP (INSURANCE)	3019
CREDENTIALING ADJUSTMENT (ADMINISTRATION)	3055
TIMELY FILING (INSURANCE) - FRONT OFFICE DELAY/ERROR	4017
TIMELY FILING (INSURANCE) - CPBC DELAY/ERROR	4018
UNTIMELY FOLLOW UP (INS) - CPBC DELAY/ERROR	4019
CLAIM DENIED AFTER APPEAL	4021
UNTIMELY FOLLOWUP (INS) FRONT OFFICE DELAY/ERROR	4020

*/

select 

year_month as 'Year-Month'
,arpb_tx.tx_id as 'Charge Transaction ID'
,ser_perf.prov_name as 'Performing Provider'
,eap.proc_name as 'Charge Procedure'
--,eap_match.proc_name as 'Matched Procedure'
,arpb_tx.amount as 'Charge Amount'
,sum(coalesce(match.MTCH_TX_HX_PAT_AMT,0))*-1 as 'Patient Amount'
,sum(case when arpb_tx_match.tx_type_c = 2 then coalesce(match.MTCH_TX_HX_INS_AMT,0)*-1 else 0 end) as 'Insurance Amount'
,sum(case when arpb_tx_match.tx_type_c = 3 then coalesce(match.MTCH_TX_HX_INS_AMT,0)*-1 else 0 end) as 'Adjustment Amount'
,coalesce(arpb_tx.outstanding_amt,0)*-1 as 'Outstanding Amount'
,sum(case when eap_match.proc_code in ('3011','3012','3015','4020','4018','4019','4017','4021','3003','3019','3055','3018') then arpb_tx_match.amount else 0 end) as 'Final Denial Amount'


from arpb_transactions arpb_tx
left join date_dimension date on date.calendar_dt_str = arpb_tx.post_date
left join clarity_ser ser_perf on ser_perf.prov_id = arpb_tx.serv_provider_id
left join clarity_eap eap on eap.proc_id = arpb_tx.proc_id
left join arpb_tx_match_hx match on match.tx_id = arpb_tx.tx_id
left join arpb_transactions arpb_tx_match on arpb_tx_match.tx_id = match.mtch_tx_hx_id
left join clarity_eap eap_match on eap_match.proc_id = arpb_tx_match.proc_id

where 
arpb_tx.post_date >= '01/01/2016'
and arpb_tx.post_date <= '01/31/2016'
and arpb_tx.service_area_id in (16)
and arpb_tx.tx_type_c = 1 
and arpb_tx.amount <> 0
and arpb_tx.void_date is null
and MTCH_TX_HX_UN_DT is null

group by 
year_month
,arpb_tx.tx_id
,arpb_tx.amount
,ser_perf.prov_name
,eap.proc_name
,arpb_tx.outstanding_amt

order by
arpb_tx.tx_id