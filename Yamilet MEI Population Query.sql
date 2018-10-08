
SELECT 
 pe.PAT_ENC_CSN_ID
,CONTACT_DATE
,ENC_CLOSED_YN
,LOS_PROC_CODE
,getdate() as RUN_DATE


FROM ( PAT_ENC pe LEFT OUTER JOIN 

                                (-- Charges never voided
                                select  t.pat_enc_csn_id
                                from CLARITY_TDL t LEFT OUTER JOIN ARPB_TRANSACTIONS a
                                on t.TX_ID = a.TX_ID
                                where void_date is null
                                and detail_type = '1' 
                                group by t.pat_enc_csn_id)   as qry_Charges
                
                ON          pe.PAT_ENC_CSN_ID = COALESCE (qry_Charges.PAT_ENC_CSN_ID, 0)  ) LEFT OUTER JOIN 
                
                                (--charge review wq
                                select p.PAT_ENC_CSN 
                                from pre_ar_chg p
                                where p.CHARGE_STATUS_C = '3'
                                group by p.PAT_ENC_CSN ) as qry_Wq
                                
                ON pe.PAT_ENC_CSN_ID = COALESCE ( qry_Wq.PAT_ENC_CSN, 0)

WHERE pe.APPT_STATUS_C in ('2', '6')
                and CONTACT_DATE >= {d '2012-01-01'}
                and qry_Charges.PAT_ENC_CSN_ID is null
                and  qry_Wq.PAT_ENC_CSN is null
                
