select * from ARPB_FILING_ORDER where TX_ID in (17832611,17833868,17833956,17834343,17834897,152700917)

select TX_ID, ORIGINAL_EPM_ID, PAYOR_ID, PATIENT_ID, TX_TYPE_C from ARPB_TRANSACTIONS where TX_ID in (17832611,17833868,17833956,17834343,17834897,152700917)

select TX_ID, ORIGINAL_PAYOR_ID, CUR_PAYOR_ID from CLARITY_TDL_TRAN where TX_ID in (17832611,17833868,17833956,17834343,17834897,152700917) and DETAIL_TYPE = 1

select invoice_number from CLARITY_TDL_TRAN where tx_id = 152700917 and detail_type = 50

select * from inv_basic_info where inv_num = '178326110'

select * from invoice where inv_num = 178326110