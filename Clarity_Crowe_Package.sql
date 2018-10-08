create or replace package body extp_rca_pb as

--*****************************************************************************
--          Owner: WFUBMC
--    Application: Revenue Cycle Analytics - Professional Billing (Crowe RCA)
--      File Name: extp_rca_pb
--           Date: 11-OCT-2013
--         Author: Kevin Knepp
--    Description: Create extract files for Crowe RCA (Professional Billing). 
--
--
--
--
--         Params:
--      Called By:
--        Output :
--
--     Modification History :
--    Who         Date           Reason
--
--
--*****************************************************************************


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
-- EXECUTE DAILY RCA   ( This is the main call to run all DAILY procedures )
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
procedure sp_exec_daily_rca_pb( d_run_dt in date ) is

begin

    sp_daily_art_pb  ( d_run_dt ) ;
    sp_daily_atb_pb  ( d_run_dt ) ;

exception
when others then
    rollback ;  
    raise ;
end ;



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
-- DAILY A/R TRANSACTIONS   ( daily feed of A/R transaction detail, active and inactive accounts, payments and adjustments )
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
procedure sp_daily_art_pb( d_run_dt in date ) is    
begin

declare

begin       

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Insert DTL Temp Table...
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    execute immediate 'truncate table t_rca_art_detail_pb' ;
    commit;
    
    -- Transactions...
    insert into t_rca_art_detail_pb
    (
        tdl_tdl_id, tdl_tdl_line, tdl_detail_type_c, tdl_detail_type, tdl_post_date, 
        tdl_active_amount, tdl_external_amount, tdl_bad_debt_amount, tdl_amount, 
        arpb_tx_id, arpb_match_tx_id,
        har_hsp_account_id, har_bill_area_id, har_acct_type_c
    )
    select
        tdl_tdl_id, tdl_tdl_line, tdl_detail_type_c, tdl_detail_type, tdl_post_date,
        tdl_active_amount, tdl_external_amount, tdl_bad_debt_amount, tdl_amount, 
        arpb_tx_id, arpb_match_tx_id,
        har_hsp_account_id, har_bill_area_id, har_acct_type_c
    from (    
            select
                tdl.tdl_id                                            as tdl_tdl_id,
                1                                                     as tdl_tdl_line,
                tdl.detail_type                                       as tdl_detail_type_c,
                typ."NAME"                                            as tdl_detail_type,
                tdl.post_date                                         as tdl_post_date,                                 -- posting date
                tdl.active_ar_amount                                  as tdl_active_amount,
                tdl.external_ar_amount                                as tdl_external_amount,
                tdl.bad_debt_ar_amount                                as tdl_bad_debt_amount,
                tdl.amount                                            as tdl_amount,                                    -- transaction amount
                decode( tdl."TYPE", 20, tdl.match_trx_id, tdl.tx_id ) as arpb_tx_id,
                decode( tdl."TYPE", 20, tdl.tx_id, tdl.match_trx_id ) as arpb_match_tx_id,
                tdl.hsp_account_id                                    as har_hsp_account_id,                            -- account number
                nvl( tdl.bill_area_id, -1 )                           as har_bill_area_id,                              -- level_1_code
                sbo.sbo_har_type_c                                    as har_acct_type_c,
                sum( tdl.amount ) over ( partition by tdl.hsp_account_id, tdl.bill_area_id, decode( tdl."TYPE", 20, tdl.match_trx_id, tdl.tx_id ) ) as sum_amount
            from clarity.clarity_tdl_tran@edws2clarity  tdl
            join clarity.zc_detail_type@edws2clarity    typ  on  typ.detail_type    = tdl.detail_type
            join clarity.hsp_acct_sbo@edws2clarity      sbo  on  sbo.hsp_account_id = tdl.hsp_account_id 
            where ( tdl.detail_type in ( 2, 5, 11, 20, 22, 32, 33 ) or                -- Payments
                    tdl.detail_type in ( 3, 12 ) or                                   -- Debits
                    tdl.detail_type in ( 4, 6, 13, 21, 23, 30, 31 ) )                 -- Credits
              and ( tdl.post_date = trunc( d_run_dt ) ) 
                -- -FOR 3-MONTH, USE THIS FILTER:-
                -- and tdl.post_date >= trunc( to_date('01-OCT-2012') ) and tdl.post_date < trunc( to_date('31-DEC-2012') ) + 1 
              and nvl( tdl.amount, 0 ) <> 0
         ) 
    where not ( 0 = case when har_acct_type_c = 1 then sum_amount else 1 end )                  -- 1 = "Default"
    ;    
    commit;
    
    -- Bad Debt Transfers...
    insert into t_rca_art_detail_pb
    (
        tdl_tdl_id, tdl_tdl_line, tdl_detail_type_c, tdl_detail_type, tdl_post_date, 
        tdl_active_amount, tdl_external_amount, tdl_bad_debt_amount, tdl_amount, 
        arpb_tx_id, arpb_match_tx_id,
        har_hsp_account_id, har_bill_area_id, har_acct_type_c
    )
    select
        tdl_tdl_id, tdl_tdl_line, tdl_detail_type_c, tdl_detail_type, tdl_post_date,
        tdl_active_amount, tdl_external_amount, tdl_bad_debt_amount, tdl_amount, 
        arpb_tx_id, arpb_match_tx_id,
        har_hsp_account_id, har_bill_area_id, har_acct_type_c
    from (    
            with bad_debt as 
            (
                select
                    tdl.tdl_id                                            as tdl_tdl_id,
                    tdl.detail_type                                       as tdl_detail_type_c,
                    typ."NAME"                                            as tdl_detail_type,
                    tdl.post_date                                         as tdl_post_date,                                 -- posting date
                    tdl.active_ar_amount                                  as tdl_active_amount,
                    tdl.external_ar_amount                                as tdl_external_amount,
                    tdl.bad_debt_ar_amount                                as tdl_bad_debt_amount,
                    tdl.amount                                            as tdl_amount,                                    -- transaction amount
                    decode( tdl."TYPE", 20, tdl.match_trx_id, tdl.tx_id ) as arpb_tx_id,
                    decode( tdl."TYPE", 20, tdl.tx_id, tdl.match_trx_id ) as arpb_match_tx_id,
                    tdl.hsp_account_id                                    as har_hsp_account_id,                            -- account number
                    nvl( tdl.bill_area_id, -1 )                           as har_bill_area_id,                              -- level_1_code
                    sbo.sbo_har_type_c                                    as har_acct_type_c
                from clarity.clarity_tdl_tran@edws2clarity  tdl
                join clarity.zc_detail_type@edws2clarity    typ  on  typ.detail_type    = tdl.detail_type
                join clarity.hsp_acct_sbo@edws2clarity      sbo  on  sbo.hsp_account_id = tdl.hsp_account_id 
                where ( tdl.detail_type in ( 2, 5, 11, 20, 22, 32, 33 ) or                -- Payments
                        tdl.detail_type in ( 3, 12 ) or                                   -- Debits
                        tdl.detail_type in ( 4, 6, 13, 21, 23, 30, 31 ) )                 -- Credits
                  and ( tdl.post_date = trunc( d_run_dt ) ) 
                    -- -FOR 3-MONTH, USE THIS FILTER:-
                    -- and tdl.post_date >= trunc( to_date('01-OCT-2012') ) and tdl.post_date < trunc( to_date('31-DEC-2012') ) + 1 
                  and nvl( tdl.bad_debt_ar_amount, 0 ) <> 0
                  and nvl( tdl.amount, 0 ) = 0
            )   
            select
                tdl_tdl_id, 1 as tdl_tdl_line, tdl_detail_type_c, tdl_detail_type, tdl_post_date,
                tdl_active_amount, null as tdl_external_amount, null as tdl_bad_debt_amount, tdl_active_amount as tdl_amount,
                arpb_tx_id, arpb_match_tx_id,
                har_hsp_account_id, har_bill_area_id, har_acct_type_c
            from bad_debt 
            ---------
            union all     -- force two rows for bad debt transfers... 
            ---------
            select
                tdl_tdl_id, 2 as tdl_tdl_line, tdl_detail_type_c, tdl_detail_type, tdl_post_date,
                null as tdl_active_amount, null as tdl_external_amount, tdl_bad_debt_amount, tdl_bad_debt_amount as tdl_amount,
                arpb_tx_id, arpb_match_tx_id,
                har_hsp_account_id, har_bill_area_id, har_acct_type_c
            from bad_debt 
         ) 
    ;    
    commit;
    
    -- Payment information...
    merge into t_rca_art_detail_pb tgt
    using (
              select
                  trn.tdl_tdl_id    as tdl_tdl_id,
                  trn.tdl_tdl_line  as tdl_tdl_line,
                  arpb.post_date    as arpb_post_date,                         -- posting date  
                  arpb.service_date as arpb_service_date,                      -- service date
                  arpb.proc_id      as eap_proc_id,                            -- procedure (for transaction code below)
                  arpb.payor_id     as epm_payor_id                            -- transaction insurance code
              from t_rca_art_detail_pb                     trn
              join clarity.arpb_transactions@edws2clarity  arpb  on  arpb.tx_id = trn.arpb_tx_id
          ) src
    on ( tgt.tdl_tdl_id   = src.tdl_tdl_id  and
         tgt.tdl_tdl_line = src.tdl_tdl_line )
    when matched then
    update /*+ parallel */ set
        tgt.arpb_post_date       = src.arpb_post_date,
        tgt.eap_proc_id          = src.eap_proc_id,
        tgt.epm_payor_id         = src.epm_payor_id
    ;
    commit ;

    -- Payment transaction type...
    merge into t_rca_art_detail_pb tgt
    using (
              select
                  trn.tdl_tdl_id   as tdl_tdl_id,
                  trn.tdl_tdl_line as tdl_tdl_line, 
                  eap.proc_code         as eap_proc_code,                             -- transaction code
                  eap.proc_name         as eap_proc_name,                             -- technical description ???
                  eap2.adjustment_cat_c as eap_adjustment_cat_c, 
                  adj."NAME"            as eap_adjustment_cat
              from t_rca_art_detail_pb                         trn
              join clarity.clarity_eap@edws2clarity            eap  on  eap.proc_id  = trn.eap_proc_id
              join clarity.clarity_eap_2@edws2clarity          eap2 on  eap2.proc_id = trn.eap_proc_id
              left join clarity.zc_adjustment_cat@edws2clarity adj  on  adj.adjustment_cat_c = eap2.adjustment_cat_c
          ) src
    on ( tgt.tdl_tdl_id   = src.tdl_tdl_id  and
         tgt.tdl_tdl_line = src.tdl_tdl_line )
    when matched then
    update /*+ parallel */ set
        tgt.eap_proc_code           = src.eap_proc_code,
        tgt.eap_proc_name           = src.eap_proc_name,
        tgt.eap_adjustment_cat_c    = src.eap_adjustment_cat_c, 
        tgt.eap_adjustment_cat      = src.eap_adjustment_cat
    ;
    commit ;
    
    -- Payers...
    merge into t_rca_art_detail_pb  tgt
    using (
              select
                  trn.tdl_tdl_id       as tdl_tdl_id,
                  trn.tdl_tdl_line     as tdl_tdl_line,
                  epm.financial_class  as epm_financial_class                       -- financial class
              from t_rca_art_detail_pb                            trn
              join clarity.clarity_epm@edws2clarity               epm   on  epm.payor_id = trn.epm_payor_id
          ) src
    on ( tgt.tdl_tdl_id   = src.tdl_tdl_id  and
         tgt.tdl_tdl_line = src.tdl_tdl_line )
    when matched then
    update /*+ parallel */ set
        tgt.epm_financial_class      = src.epm_financial_class
    ;
    commit ;    
    
    -- Matched charge information...
    merge into t_rca_art_detail_pb tgt
    using (
              select
                  trn.tdl_tdl_id       as tdl_tdl_id,
                  trn.tdl_tdl_line     as tdl_tdl_line,
                  trn.arpb_match_tx_id as arpb_charge_tx_id,                      -- populate "charge" tx_id on NON-default hars only
                  arpb.post_date       as arpb_charge_post_date,                  -- charge posting date  
                  arpb.service_date    as arpb_charge_service_date                -- service date  
              from t_rca_art_detail_pb                     trn
              join clarity.arpb_transactions@edws2clarity  arpb  on  arpb.tx_id = trn.arpb_match_tx_id
              where nvl( trn.har_acct_type_c, -1 ) <> 1                           -- 1 = Default
          ) src
    on ( tgt.tdl_tdl_id   = src.tdl_tdl_id  and
         tgt.tdl_tdl_line = src.tdl_tdl_line )
    when matched then
    update /*+ parallel */ set
        tgt.arpb_charge_tx_id        = src.arpb_charge_tx_id,
        tgt.arpb_charge_post_date    = src.arpb_charge_post_date,
        tgt.arpb_charge_service_date = src.arpb_charge_service_date
    ;
    commit ;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Insert HDR Temp Table...
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    execute immediate 'truncate table t_rca_art_header_pb' ;
    commit;
    
    insert into t_rca_art_header_pb
    (
        har_hsp_account_id, har_bill_area_id, har_acct_type_c
    )
    select distinct
        har_hsp_account_id, har_bill_area_id, har_acct_type_c
    from t_rca_art_detail_pb
    ;
    commit;

    -- Accounts...
    merge into t_rca_art_header_pb tgt
    using (
              select
                  hdr.har_hsp_account_id,
                  hdr.har_bill_area_id,
                  har.prim_enc_csn_id  as har_prim_enc_csn_id,
                  cls.acct_class_ha_c  as har_class_code,                       -- as patient_type_code
                  case nvl( base.base_class_map_c, 2 )                          -- Base patient class (many patient classes missing from hsd_base_class_map... Robert says okay to default to 2)
                      when 1 then 'IP'                                          -- 1 = "Inpatient"
                      when 2 then 'OP'                                          -- 2 = "Outpatient"
                      when 3 then 'OP'                                          -- 3 = "Emergency"
                      else null
                  end                  as har_base_class_code,                  -- patient_account_type
                  har.adm_date_time    as har_admit_date,                       -- as admit_date
                  har.disch_date_time  as har_dischrg_date,                     -- as discharge_date
                  hsp.hosp_serv_c      as har_hosptl_servc_code,                -- as hospital_service_code  ( NOTE 17-JUN-2013 - Hospital Service MAY need to be "point-in-time", but doesn't exist in the snapshot - Kevin )
                  csn.visit_prov_id    as har_prvdr_id                          -- as physician_code
              from t_rca_art_header_pb                          hdr
              join clarity.hsp_account@edws2clarity              har   on  har.hsp_account_id   = hdr.har_hsp_account_id
              left join clarity.pat_enc@edws2clarity             csn   on  csn.pat_enc_csn_id   = har.prim_enc_csn_id
              left join clarity.pat_enc_2@edws2clarity           csn2  on  csn2.pat_enc_csn_id  = har.prim_enc_csn_id
              left join clarity.pat_enc_hsp@edws2clarity         hsp   on  hsp.pat_enc_csn_id   = har.prim_enc_csn_id
              left join clarity.zc_acct_class_ha@edws2clarity    cls   on  cls.acct_class_ha_c  = nvl( har.acct_class_ha_c, csn2.adt_pat_class_c )
              left join clarity.hsd_base_class_map@edws2clarity  base  on  base.acct_class_map_c = cls.acct_class_ha_c  and  base.profile_id = 1  -- 1 = "WFBMC" 
          ) src
    on ( tgt.har_hsp_account_id = src.har_hsp_account_id and
         tgt.har_bill_area_id   = src.har_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.har_prim_enc_csn_id   = src.har_prim_enc_csn_id,
        tgt.har_class_code        = src.har_class_code,
        tgt.har_base_class_code   = src.har_base_class_code,
        tgt.har_admit_date        = src.har_admit_date,
        tgt.har_dischrg_date      = src.har_dischrg_date,
        tgt.har_hosptl_servc_code = src.har_hosptl_servc_code,
        tgt.har_prvdr_id          = src.har_prvdr_id
    ;
    commit ;

    -- Total charges by account...
    merge into t_rca_art_header_pb tgt
    using (
             select
                  hdr.har_hsp_account_id, 
                  hdr.har_bill_area_id,
                  sum( tdl.amount ) as har_total_charges
              from t_rca_art_header_pb                     hdr   
              join clarity.clarity_tdl_tran @edws2clarity  tdl  on  tdl.hsp_account_id = hdr.har_hsp_account_id
                                                                and nvl( tdl.bill_area_id, -1 ) = hdr.har_bill_area_id
              where tdl.detail_type in ( 1, 10 )                                      -- Charges
                and tdl.post_date <= trunc( d_run_dt )                                -- for a 3-month run, use your END date here
              group by
                  hdr.har_hsp_account_id, 
                  hdr.har_bill_area_id
          ) src
    on ( tgt.har_hsp_account_id = src.har_hsp_account_id and
         tgt.har_bill_area_id   = src.har_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.har_total_charges        = src.har_total_charges
    ;
    commit ;
    
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Insert Table...
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    execute immediate 'truncate table rca_art_detail_pb' ;
    commit;
   
    insert into rca_art_detail_pb
    (
        level_1_code, account_number, account_type, 
        transaction_active_amount, transaction_external_amount, transaction_bad_debt_amount, transaction_amount, 
        posting_date, service_date, admit_date, discharge_date, 
        transaction_code, technical_description, 
        financial_class, transaction_insurance_code, 
        total_charges, unit_number, unit_date, 
        patient_type_code, hospital_service_code, physician_code
    )    
    -- WFB-B1, WFB-B2, WFB-B3...
    select 
        trn.har_bill_area_id                            as level_1_code,
        trn.har_hsp_account_id                          as account_number,
        null                                            as account_type,                -- not needed at this time...
        decode( trn.tdl_active_amount,   0, null, trn.tdl_active_amount   ) as transaction_active_amount,   
        decode( trn.tdl_external_amount, 0, null, trn.tdl_external_amount ) as transaction_external_amount, 
        decode( trn.tdl_bad_debt_amount, 0, null, trn.tdl_bad_debt_amount ) as transaction_bad_debt_amount, 
        decode( trn.tdl_amount,          0, null, trn.tdl_amount          ) as transaction_amount,    -- set to null when zero to keep the output smaller
        trn.tdl_post_date                               as posting_date,
        trn.arpb_charge_service_date                    as service_date,
        case hdr.har_base_class_code
            when 'OP'
            then nvl( hdr.har_admit_date, hdr.har_dischrg_date )                          -- Per Spec: "Outpatient admission and discharge dates should be the same if one of the dates cannot be provided"
            else hdr.har_admit_date
        end                                             as admit_date,
        case hdr.har_base_class_code
            when 'OP'
            then nvl( hdr.har_dischrg_date, hdr.har_admit_date )                          -- Per Spec: "Outpatient admission and discharge dates should be the same if one of the dates cannot be provided"
            else hdr.har_dischrg_date
        end                                             as discharge_date,
        nvl( case when trn.eap_adjustment_cat_c = 13 and nvl( trn.tdl_detail_type_c, -1 ) <> 5 and trn.tdl_bad_debt_amount is not null
                  then trn.eap_proc_code || '_ADJ_BD'
                  when trn.eap_adjustment_cat_c = 13 and nvl( trn.tdl_detail_type_c, -1 ) <> 5    -- 13 = "Payment Reversal"  -- 5 = "Payment Reversal"
                  then trn.eap_proc_code || '_ADJ'                                        -- [ If they've posted a "Payment Reversal" transaction code, but the detail type is not "Payment Reversal", then apppend '_ADJ' to the transaction code, per Rick ]
                  when trn.tdl_bad_debt_amount is not null
                  then trn.eap_proc_code || '_BD' 
                  else trn.eap_proc_code
             end, '-1' )                                as transaction_code,              -- default to '-1'
        trn.eap_proc_name                               as technical_description,         -- ???
        nvl( trn.epm_financial_class, '4')              as financial_class,               -- default to '4' = "self-pay"
        nvl( trn.epm_payor_id, -1 )                     as transaction_insurance_code,    -- default to -1 = "self-pay"
        decode( hdr.har_total_charges, 0, null, hdr.har_total_charges ) as total_charges, -- set to null when zero to keep the output smaller
        null                                            as unit_number,                   -- not needed at this time...
        null                                            as unit_date,                     -- not needed at this time...
        nvl( hdr.har_class_code, -1 )                   as patient_type_code,             -- default to -1
        nvl( hdr.har_hosptl_servc_code, '-1')           as hospital_service_code,         -- default to '-1'
        nvl( hdr.har_prvdr_id, '-1' )                   as physician_code                 -- default to '-1'
    from t_rca_art_detail_pb   trn    
    join t_rca_art_header_pb   hdr  on  hdr.har_hsp_account_id = trn.har_hsp_account_id
                                    and hdr.har_bill_area_id   = trn.har_bill_area_id 
    ;
    commit;


    -------------------------------------------------------------------------------------------------------------------------------------------------
    -- Use this to export to "RCA - Epic - Daily ART Detail PB.csv"...
    -------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    select
        to_char( level_1_code,               'fm999999999999999999'  ) as level_1_code,
        to_char( account_number,             'fm999999999999999999'  ) || '_' || 
            to_char( level_1_code,           'fm999999999999999999'  ) as account_number, 
        account_type, 
        to_char( transaction_amount,         'fm9999999999999990.00' )  as transaction_amount,
        to_char( posting_date,               'MM/DD/YYYY'            )  as posting_date,         -- dates are 'MM/DD/YYYY HH24:MI' in the spec, but Jenna Bourdow said take out the timestamp (29-MAY-2013)...
        to_char( service_date,               'MM/DD/YYYY'            )  as service_date,
        to_char( admit_date,                 'MM/DD/YYYY'            )  as admit_date,
        to_char( discharge_date,             'MM/DD/YYYY'            )  as discharge_date, 
        transaction_code,
        replace( substr( technical_description, 1, 75 ), '"', '''' )    as technical_description,
        financial_class,
        to_char( transaction_insurance_code, 'fm999999999999999999'  )  as transaction_insurance_code, 
        to_char( total_charges,              'fm9999999999999990.00' )  as total_charges,
        unit_number,
        to_char( unit_date,                  'MM/DD/YYYY'            ) as unit_date, 
        patient_type_code,
        hospital_service_code,
        physician_code
    from rca_art_detail_pb 
    order by account_number, level_1_code
    ;    
    */
    -------------------------------------------------------------------------------------------------------------------------------------------------

end ;

  exception
    when others then
        rollback ;
        raise ;
end ;


----=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
---- DAILY ATB AND CORE PLUS   ( A daily snapshot of all A/R, active and non-zero-balance accounts only (excludes bad debt) )
----=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
procedure sp_daily_atb_pb( d_run_dt in date ) is    
begin

declare

begin       

     --   ATB...   -- no core plus file for PB data
     --
     --   level_1_code, account_number,  
     --   parent_account_number, account_type,
     --   medical_record_number, last_name, first_name, middle_initial, birth_date, social_security_number,
     --   patient_type_code, hospital_service_code,     
     --   admit_date, discharge_date, last_bill_date,
     --   current_financial_class, financial_class_code1, financial_class_code2, financial_class_code3, financial_class_code4, financial_class_code5, 
     --   current_insurance_code, insurance_code1, insurance_code2, insurance_code3, insurance_code4, insurance_code5,
     --   insurance_payments1, insurance_payments2, insurance_payments3, insurance_payments4, insurance_payments5,
     --   insurance_balance1, insurance_balance2, insurance_balance3, insurance_balance4, insurance_balance5,
     --   patient_payments, patient_balance, 
     --   total_charges, total_payments, total_adjustments, account_balance,  -- total_payments and total_adjustments are for testing, do not write to output file
     --   expected_revenue, primary_drg,
     --   patient_representative, responsibility_code, physician_code
        
    execute immediate 'truncate table t_rca_atb_snapshot_pb' ;
    commit; 
    
    -- Accounts...
    insert into t_rca_atb_snapshot_pb
    (
        acct_id, acct_bill_area_id, acct_prim_enc_csn_id, acct_recur_id, acct_bill_stat_code, 
        acct_user_code, acct_admit_date, acct_dischrg_date, acct_last_bill_date,
        loctn_id, patnt_id, patnt_guar_id, 
        total_chrg_amt, total_pymt_amt, total_adj_amt, total_bal_amt
    )
    with txs_with_bal as
    ( 
        select
            hsp_account_id,
            bill_area_id,
            tx_id,
            sum( chrg_amount )   as total_chrg_amt,
            sum( pymt_amount )   as total_pymt_amt,
            sum( adj_amount )    as total_adj_amt,
            sum( amount )        as total_bal_amt 
        from (
                select 
                    tdl.hsp_account_id,
                    tdl.bill_area_id,
                    tdl.tx_id,
                    case when tdl.detail_type in ( 1, 10 )                            -- Charges
                         then tdl.active_ar_amount --amount
                         else null
                    end as chrg_amount,
                    case when tdl.detail_type in ( 2, 5, 11, 20, 22, 32, 33 )         -- Payments
                         then tdl.active_ar_amount --amount
                         else null
                    end as pymt_amount,
                    case when tdl.detail_type in ( 3, 12 )                            -- Debits
                           or tdl.detail_type in ( 4, 6, 13, 21, 23, 30, 31 )         -- Credits
                         then tdl.active_ar_amount --amount
                         else null
                    end as adj_amount,
                    tdl.active_ar_amount as amount, --amount
                    sum( tdl.active_ar_amount ) over ( partition by tdl.hsp_account_id, tdl.bill_area_id ) as acct_bal
                from clarity.clarity_tdl_tran@edws2clarity         tdl
                where tdl.post_date <= trunc( d_run_dt ) 
                  and tdl.detail_type < 40 
                  and tdl.hsp_account_id is not null      --( I found 38 records where har is null, ... assuming bad data... ) 
             )  
        where acct_bal <> 0
        group by 
            hsp_account_id,
            bill_area_id,
            tx_id
    ),
    tx_billdates as
    ( 
        select
            tx_id, last_bill_date
        from (            
                select
                    txs.tx_id,
                    dates.bc_hx_date as last_bill_date,
                    rank() over ( partition by txs.tx_id order by dates.bc_hx_date desc, dates.line desc) as dates_rank
                from ( select distinct tx_id from txs_with_bal )  txs
                join clarity.arpb_tx_stmclaimhx@edws2clarity      dates  on  dates.tx_id = txs.tx_id
                where dates.bc_hx_date <= trunc( d_run_dt )
             )   
         where dates_rank = 1    
    ),
    accts_with_bal as
    (
         select
              txs.hsp_account_id,
              txs.bill_area_id,
              max( dates.last_bill_date ) as last_bill_date,
              sum( txs.total_chrg_amt )   as total_chrg_amt,
              sum( txs.total_pymt_amt )   as total_pymt_amt,
              sum( txs.total_adj_amt )    as total_adj_amt,
              sum( txs.total_bal_amt )    as total_bal_amt 
         from txs_with_bal       txs
         left join tx_billdates  dates  on  dates.tx_id = txs.tx_id
         group by 
             txs.hsp_account_id,
             txs.bill_area_id
    )
    select
        acct.hsp_account_id           as acct_id,
        nvl( acct.bill_area_id, -1 )  as acct_bill_area_id,
        har.prim_enc_csn_id           as acct_prim_enc_csn_id,
        har.recur_parent_id           as acct_recur_id,                                -- as parent_account_number
        null                          as acct_bill_stat_code,
        har2.coding_user              as acct_user_code,                               -- as responsibility_code
        har.adm_date_time             as acct_admit_date,                              -- as admit_date
        har.disch_date_time           as acct_dischrg_date,                            -- as discharge_date
        acct.last_bill_date           as acct_last_bill_date,
        har.loc_id                    as loctn_id,                                     -- as hospital
        har.pat_id                    as patnt_id,                                     -- as patient_id
        har.guarantor_id              as patnt_guar_id,
        decode( acct.total_chrg_amt, 0, null, acct.total_chrg_amt ) as total_chrg_amt,
        decode( acct.total_pymt_amt, 0, null, acct.total_pymt_amt ) as total_pymt_amt,
        decode( acct.total_adj_amt,  0, null, acct.total_adj_amt  ) as total_adj_amt,
        acct.total_bal_amt            as total_bal_amt
    from accts_with_bal                         acct
    join clarity.hsp_account@edws2clarity       har   on  har.hsp_account_id   = acct.hsp_account_id
    join clarity.hsp_account_2@edws2clarity     har2  on  har2.hsp_account_id  = acct.hsp_account_id
    ;
    commit ;
    -- Can't use the snapshot tables for PB...

    -- Primary payer...
    merge into t_rca_atb_snapshot_pb tgt
    using (
            select
                snp.acct_id,
                snp.acct_bill_area_id,
                ac.coverage_id,                  -- needs to default to -1 below !!
                cvg.payor_id,                    -- needs to default to -1 below !!
                epm.financial_class,             -- needs to default to '4' below!!
                cvg.subscr_num
            from t_rca_atb_snapshot_pb                  snp    
            join clarity.acct_coverage@edws2clarity     ac   on  ac.account_id   = snp.patnt_guar_id
                                                             and ac.line         = 1                   -- 1 = Primary Coverage (Primary Payer)
            join clarity.coverage@edws2clarity          cvg  on  cvg.coverage_id = ac.coverage_id  
            left join clarity.clarity_epm@edws2clarity  epm  on  epm.payor_id    = cvg.payor_id
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.payer_prmry_cvg_id         = src.coverage_id,
        tgt.payer_prmry_id             = src.payor_id,
        tgt.payer_prmry_fin_class_code = src.financial_class,
        tgt.payer_prmry_subscr_num     = src.subscr_num
    ;
    commit ;
    
    -- Encounters...
    merge into t_rca_atb_snapshot_pb tgt
    using (
              select
                  snp.acct_id,
                  snp.acct_bill_area_id,
                  cls.acct_class_ha_c  as acct_class_code,                      -- as patient_type_code
                  case nvl( base.base_class_map_c, 2 )                          -- Base patient class (many patient classes missing from hsd_base_class_map... Robert says okay to default to 2)
                      when 1 then 'IP'                                          -- 1 = "Inpatient"
                      when 2 then 'OP'                                          -- 2 = "Outpatient"
                      when 3 then 'OP'                                          -- 3 = "Emergency"
                      else null
                  end                  as acct_base_class_code,
                  hsp.hosp_serv_c      as hosptl_servc_code                    -- as hospital_service_code  ( NOTE 17-JUN-2013 - Hospital Service MAY need to be "point-in-time", but doesn't exist in the snapshot - Kevin )
              from t_rca_atb_snapshot_pb                         snp    
              join clarity.hsp_account@edws2clarity              har   on  har.hsp_account_id   = snp.acct_id
              left join clarity.pat_enc_2@edws2clarity           csn2  on  csn2.pat_enc_csn_id  = har.prim_enc_csn_id
              left join clarity.pat_enc_hsp@edws2clarity         hsp   on  hsp.pat_enc_csn_id   = har.prim_enc_csn_id
              left join clarity.zc_acct_class_ha@edws2clarity    cls   on  cls.acct_class_ha_c  = nvl( har.acct_class_ha_c, csn2.adt_pat_class_c )
              left join clarity.hsd_base_class_map@edws2clarity  base  on  base.acct_class_map_c = cls.acct_class_ha_c  and  base.profile_id = 1  -- 1 = "WFBMC" 
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.acct_class_code      = src.acct_class_code,
        tgt.acct_base_class_code = src.acct_base_class_code,
        tgt.hosptl_servc_code    = src.hosptl_servc_code
    ;
    commit ;
    
    -- Guarantors...
    merge into t_rca_atb_snapshot_pb tgt
    using (
              select
                  snp.acct_id,
                  snp.acct_bill_area_id,
                  guar.account_name as patnt_acct_name                          -- as patient_representative
              from t_rca_atb_snapshot_pb                 snp    
              join clarity."ACCOUNT"@edws2clarity        guar  on  guar.account_id  = snp.patnt_guar_id
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.patnt_acct_name    = src.patnt_acct_name
    ;
    commit ;

    -- DRGs...  do not apply for PB data at this institution...

    -- Patients...
    merge into t_rca_atb_snapshot_pb tgt
    using (
              select
                  snp.acct_id,
                  snp.acct_bill_area_id,
                  pat.pat_mrn_id         as patnt_mrn_id,                       -- as medical_record_number
                  pat.pat_last_name      as patnt_last_name,                    -- as last_name
                  pat.pat_first_name     as patnt_frst_name,                    -- as first_name
                  pat.pat_middle_name    as patnt_mid_name,                     -- as middle_initial
                  pat.birth_date         as patnt_birth_date,                   -- as birth_date
                  pat.ssn                as patnt_ssn_num                       -- as social_security_number (makes me uncomfortable to provide SSNs)
              from t_rca_atb_snapshot_pb         snp    
              join clarity.patient@edws2clarity  pat  on  pat.pat_id = snp.patnt_id
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.patnt_mrn_id            = src.patnt_mrn_id,
        tgt.patnt_last_name         = src.patnt_last_name,
        tgt.patnt_frst_name         = src.patnt_frst_name,
        tgt.patnt_mid_name          = src.patnt_mid_name,
        tgt.patnt_birth_date        = src.patnt_birth_date,
        tgt.patnt_ssn_num           = src.patnt_ssn_num
    ;
    commit ;
  
    -- Payer Buckets...
    merge into t_rca_atb_snapshot_pb tgt
    using (
              with bucket_payments as 
              (
                  select
                      acct_id,
                      acct_bill_area_id,
                      nvl( action_payor_id, -1 ) as payor_id,
                      sum( amount ) as payments
                  from (
                          select
                              snp.acct_id,
                              snp.acct_bill_area_id,
                              decode( tdl."TYPE", 20, tdl.match_trx_id, tdl.tx_id ) as tx_id,
                              tdl.action_payor_id,
                              tdl.post_date,
                              sum( tdl.active_ar_amount ) as amount --amount ) as amount
                          from t_rca_atb_snapshot_pb                    snp    
                          join clarity.clarity_tdl_tran @edws2clarity   tdl  on  tdl.hsp_account_id = snp.acct_id
                                                                             and nvl(tdl.bill_area_id,-1) = snp.acct_bill_area_id
                          where ( tdl.detail_type in ( 2, 5, 11, 20, 22, 32, 33 ) )               -- Payments
                            and ( tdl.post_date <= trunc( d_run_dt ) )
                          group by
                              snp.acct_id,
                              snp.acct_bill_area_id,
                              decode( tdl."TYPE", 20, tdl.match_trx_id, tdl.tx_id ),
                              tdl.action_payor_id,
                              tdl.post_date
                          having sum( tdl.active_ar_amount ) <> 0 --amount ) <> 0    
                       ) 
                  group by 
                      acct_id,
                      acct_bill_area_id,
                      nvl( action_payor_id, -1 )
                  having sum( amount) <> 0
              ),
              current_payers as
              (
                  select
                      tx_id,
                      nvl( cur_payor_id, -1 ) as payor_id
                  from (    
                          select 
                              act.tx_id,
                              act.cur_payor_id, 
                              rank() over ( partition by act.tx_id order by act.post_date desc, act.tdl_id desc, rownum desc) as act_rank
                          from t_rca_atb_snapshot_pb                  snp
                          join clarity.clarity_tdl_tran@edws2clarity  act  on act.hsp_account_id = snp.acct_id
                          where act.detail_type = 40        -- 40 = Action - Change Payor
                            and act.post_date <= trunc( d_run_dt )
                       )     
                  where act_rank = 1   -- get the most recent "Change Payor" action record for each tx_id  
              ),
              bucket_balance as 
              (
                  select
                      nvl( bal.acct_id, prm.acct_id ) as acct_id,
                      nvl( bal.acct_bill_area_id, prm.acct_bill_area_id ) as acct_bill_area_id,
                      coalesce( bal.payor_id, prm.payor_id, -1 ) as payor_id,
                      bal.balance
                  from (
                          select
                              bal.acct_id,
                              bal.acct_bill_area_id,
                              coalesce( cur.payor_id, bal.payor_id, -1 ) as payor_id,
                              sum( bal.amount ) as balance
                          from (
                                  select
                                      snp.acct_id,
                                      snp.acct_bill_area_id,
                                      tdl.tx_id,
                                      tdl.action_payor_id as payor_id,
                                      sum( tdl.active_ar_amount ) as amount --amount )   as amount
                                  from t_rca_atb_snapshot_pb                    snp    
                                  join clarity.clarity_tdl_tran @edws2clarity   tdl  on  tdl.hsp_account_id = snp.acct_id
                                                                                     and nvl( tdl.bill_area_id, -1 ) = snp.acct_bill_area_id
                                  where tdl.detail_type < 40
                                    and ( tdl.post_date <=  trunc( d_run_dt ) )
                                    --and snp2.coll_status_c is null
                                  group by
                                      snp.acct_id,
                                      snp.acct_bill_area_id,
                                      tdl.tx_id,
                                      tdl.action_payor_id
                                  having sum( tdl.active_ar_amount ) <> 0 --amount ) <> 0    
                               )                    bal
                          left join current_payers  cur  on  cur.tx_id = bal.tx_id
                          group by 
                              bal.acct_id,
                              bal.acct_bill_area_id,
                              coalesce( cur.payor_id, bal.payor_id, -1 )
                          having sum( bal.amount) <> 0
                       ) bal
                  full join 
                       (                     -- force at least one row for the primary payer, even if the primary payer doesn't exist in the bucket snapshot...
                              select         -- because payer #1 needs to be the primary)...
                                  acct_id,
                                  acct_bill_area_id,
                                  nvl( payer_prmry_id, -1 ) as payor_id
                              from t_rca_atb_snapshot_pb 
                       ) prm on  prm.acct_id           = bal.acct_id
                             and prm.acct_bill_area_id = bal.acct_bill_area_id
                             and prm.payor_id          = bal.payor_id
                             --and prm.coverage_id       = bal.coverage_id
              ),
              buckets as
              (
                  select
                      acct_id, acct_bill_area_id, line, payor_id, financial_class, balance, payments 
                  from (    
                          select
                              bkt.acct_id,
                              bkt.acct_bill_area_id,
                              bkt.payor_id,                                        --     as insurance_code
                              nvl( epm.financial_class, '4') as financial_class,   --     as financial_class_code
                              bkt.balance,
                              bkt.payments,                                                                                             -- '4' = self-pay                            -- '3'= medicaid                            -- '104' = medicaid app confirmed
                              rank() over ( partition by bkt.acct_id, bkt.acct_bill_area_id order by decode( bkt.payor_id, snp.payer_prmry_id, to_date( '31-DEC-2500'), to_date('01-JAN-1900') ) desc, case when epm.financial_class = '4' then -99999999999 when epm.financial_class = '3' then -9999999999 when epm.financial_class = '104' then -999999999 else bkt.balance end desc, bkt.balance desc, rownum desc) as line
                          from (                                                                                                        -- if primary payer, use artificial date far into the future
                                  select
                                      nvl( bal.acct_id, pmt.acct_id )                     as acct_id,
                                      nvl( bal.acct_bill_area_id, pmt.acct_bill_area_id ) as acct_bill_area_id,
                                      nvl( bal.payor_id, pmt.payor_id )                   as payor_id,
                                      bal.balance,
                                      pmt.payments
                                  from      ( select acct_id, acct_bill_area_id, payor_id, balance  from bucket_balance  )  bal
                                  full join ( select acct_id, acct_bill_area_id, payor_id, payments from bucket_payments )  pmt  on pmt.acct_id = bal.acct_id and pmt.acct_bill_area_id = bal.acct_bill_area_id and pmt.payor_id = bal.payor_id
                               ) bkt
                          join t_rca_atb_snapshot_pb                   snp  on  snp.acct_id           = bkt.acct_id    
                                                                            and snp.acct_bill_area_id = bkt.acct_bill_area_id
                          left join clarity.clarity_epm@edws2clarity   epm  on  epm.payor_id          = bkt.payor_id
                       )  
                  where line <= 5                                               -- limited to 5 payers for this extract
              ),
              buckets_subscr as
              (
                  select
                      acct_id, acct_bill_area_id, line, subscr_num
                  from (    
                          select
                              bkt.acct_id,
                              bkt.acct_bill_area_id,
                              bkt.line, 
                              cvg.subscr_num,
                              rank() over ( partition by bkt.acct_id, bkt.acct_bill_area_id, bkt.line order by ac.line, rownum desc ) as ac_line
                          from buckets                             bkt
                          join t_rca_atb_snapshot_pb               snp  on  snp.acct_id           = bkt.acct_id    
                                                                        and snp.acct_bill_area_id = bkt.acct_bill_area_id
                          join clarity.acct_coverage@edws2clarity  ac   on  ac.account_id   = snp.patnt_guar_id
                          join clarity.coverage@edws2clarity       cvg  on  cvg.coverage_id = ac.coverage_id
                                                                        and cvg.payor_id    = bkt.payor_id
                       )                                                      
                  where ac_line = 1     -- Get the subscr_num from the minimum acct_coverage.line, when there are multiple coverages with same payor_id
              ),
              fin_class as 
              (
                  select
                      acct_id, acct_bill_area_id, "1" as payer_fin_class_1_code, "2" as payer_fin_class_2_code, "3" as payer_fin_class_3_code, "4" as payer_fin_class_4_code, "5" as payer_fin_class_5_code
                  from (
                          select bkt.acct_id, bkt.acct_bill_area_id, bkt.line, bkt.financial_class
                          from buckets               bkt
                       ) 
                  pivot( max( financial_class ) for line in ( 1, 2, 3, 4, 5 ))
              ),
              payer as 
              (
                  select
                      acct_id, acct_bill_area_id, "1" as payer_1_id, "2" as payer_2_id, "3" as payer_3_id, "4" as payer_4_id, "5" as payer_5_id
                  from (
                          select bkt.acct_id, bkt.acct_bill_area_id, bkt.line, bkt.payor_id
                          from buckets               bkt
                      ) 
                  pivot( max( payor_id ) for line in ( 1, 2, 3, 4, 5 ))
              ),
              subscr_num as 
              (
                  select
                      acct_id, acct_bill_area_id, "1" as payer_subscr_1_num, "2" as payer_subscr_2_num, "3" as payer_subscr_3_num, "4" as payer_subscr_4_num, "5" as payer_subscr_5_num
                  from (
                          select bkt.acct_id, bkt.acct_bill_area_id, bkt.line, bkt.subscr_num
                          from buckets_subscr        bkt
                      ) 
                  pivot( max( subscr_num ) for line in ( 1, 2, 3, 4, 5 ))
              ),
              payments as 
              (
                  select
                      acct_id, acct_bill_area_id, "1" as payer_pmt_1_amt, "2" as payer_pmt_2_amt, "3" as payer_pmt_3_amt, "4" as payer_pmt_4_amt, "5" as payer_pmt_5_amt
                  from (
                          select bkt.acct_id, bkt.acct_bill_area_id, bkt.line, bkt.payments
                          from buckets          bkt
                      ) 
                  pivot( max( payments ) for line in ( 1, 2, 3, 4, 5 ))
              ),
              balance as 
              (
                  select
                      acct_id, acct_bill_area_id, "1" as payer_bal_1_amt, "2" as payer_bal_2_amt, "3" as payer_bal_3_amt, "4" as payer_bal_4_amt, "5" as payer_bal_5_amt
                  from (
                          select bkt.acct_id, bkt.acct_bill_area_id, bkt.line, bkt.balance
                          from buckets          bkt
                      ) 
                  pivot( max( balance ) for line in ( 1, 2, 3, 4, 5 ))
              )
              select
                  bkt.acct_id,
                  bkt.acct_bill_area_id, 
                  fin.payer_fin_class_1_code, fin.payer_fin_class_2_code, fin.payer_fin_class_3_code, fin.payer_fin_class_4_code, fin.payer_fin_class_5_code, 
                  pay.payer_1_id,             pay.payer_2_id,             pay.payer_3_id,             pay.payer_4_id,             pay.payer_5_id, 
                  sub.payer_subscr_1_num,     sub.payer_subscr_2_num,     sub.payer_subscr_3_num,     sub.payer_subscr_4_num,     sub.payer_subscr_5_num, 
                  pmt.payer_pmt_1_amt,        pmt.payer_pmt_2_amt,        pmt.payer_pmt_3_amt,        pmt.payer_pmt_4_amt,        pmt.payer_pmt_5_amt, 
                  bal.payer_bal_1_amt,        bal.payer_bal_2_amt,        bal.payer_bal_3_amt,        bal.payer_bal_4_amt,        bal.payer_bal_5_amt 
              from ( select distinct acct_id, acct_bill_area_id from buckets ) bkt
              left join fin_class  fin  on  fin.acct_id = bkt.acct_id and fin.acct_bill_area_id = bkt.acct_bill_area_id
              left join payer      pay  on  pay.acct_id = bkt.acct_id and pay.acct_bill_area_id = bkt.acct_bill_area_id
              left join subscr_num sub  on  sub.acct_id = bkt.acct_id and sub.acct_bill_area_id = bkt.acct_bill_area_id
              left join payments   pmt  on  pmt.acct_id = bkt.acct_id and pmt.acct_bill_area_id = bkt.acct_bill_area_id
              left join balance    bal  on  bal.acct_id = bkt.acct_id and bal.acct_bill_area_id = bkt.acct_bill_area_id
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update set
        tgt.payer_fin_class_1_code = src.payer_fin_class_1_code,
        tgt.payer_1_id             = src.payer_1_id,
        tgt.payer_subscr_1_num     = src.payer_subscr_1_num,
        tgt.payer_pmt_1_amt        = src.payer_pmt_1_amt,
        tgt.payer_bal_1_amt        = src.payer_bal_1_amt,
        --
        tgt.payer_fin_class_2_code = src.payer_fin_class_2_code,
        tgt.payer_2_id             = src.payer_2_id,
        tgt.payer_subscr_2_num     = src.payer_subscr_2_num,
        tgt.payer_pmt_2_amt        = src.payer_pmt_2_amt,
        tgt.payer_bal_2_amt        = src.payer_bal_2_amt,
        --
        tgt.payer_fin_class_3_code = src.payer_fin_class_3_code,
        tgt.payer_3_id             = src.payer_3_id,
        tgt.payer_subscr_3_num     = src.payer_subscr_3_num,
        tgt.payer_pmt_3_amt        = src.payer_pmt_3_amt,
        tgt.payer_bal_3_amt        = src.payer_bal_3_amt,
        --
        tgt.payer_fin_class_4_code = src.payer_fin_class_4_code,
        tgt.payer_4_id             = src.payer_4_id,
        tgt.payer_subscr_4_num     = src.payer_subscr_4_num,
        tgt.payer_pmt_4_amt        = src.payer_pmt_4_amt,
        tgt.payer_bal_4_amt        = src.payer_bal_4_amt,
        --
        tgt.payer_fin_class_5_code = src.payer_fin_class_5_code,
        tgt.payer_5_id             = src.payer_5_id,
        tgt.payer_subscr_5_num     = src.payer_subscr_5_num,
        tgt.payer_pmt_5_amt        = src.payer_pmt_5_amt,
        tgt.payer_bal_5_amt        = src.payer_bal_5_amt
    ;
    commit ;
    
    -- Insurance Medicare...
    merge into t_rca_atb_snapshot_pb tgt
    using (
            select
                acct_id, acct_bill_area_id, payer_subscr_mcare_num
            from (    
                    select
                        snp.acct_id,
                        snp.acct_bill_area_id,
                        cvg.subscr_num as payer_subscr_mcare_num,               --     as medicare_hic_number
                        rank() over ( partition by snp.acct_id, snp.acct_bill_area_id order by lst.line, rownum desc) as lst_rank
                    from t_rca_atb_snapshot_pb               snp    
                    join clarity.acct_coverage@edws2clarity  lst  on  lst.account_id  = snp.patnt_guar_id
                    join clarity.coverage@edws2clarity       cvg  on  cvg.coverage_id = lst.coverage_id
                    join clarity.clarity_epm@edws2clarity    epm  on  epm.payor_id        = cvg.payor_id
                    join clarity.clarity_epp@edws2clarity    epp  on  epp.benefit_plan_id = cvg.plan_id    -- AND pln2.record_stat_epp_c IS NULL ??
                    where epm.payor_id in (100, 101)                            -- 100 = MEDICARE, 101 = MEDICARE PART A&B RAILROAD
                      and epp.alt_id_rc_by_pln = 'MCR' 
                 )    
            where lst_rank = 1    -- to assure no dups
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.payer_subscr_mcare_num = src.payer_subscr_mcare_num
    ;
    commit ;

    -- Insurance Medicaid...
    merge into t_rca_atb_snapshot_pb tgt
    using (
            select
                acct_id, acct_bill_area_id, payer_subscr_mcaid_num, payer_subscr_mcaid_state_name
            from (    
                    select
                        snp.acct_id,
                        snp.acct_bill_area_id,
                        cvg.subscr_num as payer_subscr_mcaid_num,               -- as medicaid_number
                        st."NAME"      as payer_subscr_mcaid_state_name,        -- as medicaid state
                        rank() over ( partition by snp.acct_id, snp.acct_bill_area_id order by lst.line, rownum desc) as lst_rank
                    from t_rca_atb_snapshot_pb               snp    
                    join clarity.acct_coverage@edws2clarity  lst  on  lst.account_id  = snp.patnt_guar_id
                    join clarity.coverage@edws2clarity       cvg  on  cvg.coverage_id = lst.coverage_id
                    join clarity.clarity_epm@edws2clarity    epm  on  epm.payor_id    = cvg.payor_id
                    left join clarity.zc_state@edws2clarity  st   on  st.state_c      = cvg.state_c
                    where epm.financial_class = '3'                             -- 3 = Medicaid 
                 )    
            where lst_rank = 1    -- to assure no dups
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.payer_subscr_mcaid_num        = src.payer_subscr_mcaid_num, 
        tgt.payer_subscr_mcaid_state_name = src.payer_subscr_mcaid_state_name
    ;
    commit ;

    -- Payments - Patient...
    merge into t_rca_atb_snapshot_pb tgt
    using (
            select
                acct_id,
                acct_bill_area_id,
                decode( payer_1_id, -1, payer_pmt_1_amt, 0 ) +                  -- -1 = self-pay
                    decode( payer_2_id, -1, payer_pmt_2_amt, 0 ) + 
                    decode( payer_3_id, -1, payer_pmt_3_amt, 0 ) + 
                    decode( payer_4_id, -1, payer_pmt_4_amt, 0 ) + 
                    decode( payer_5_id, -1, payer_pmt_5_amt, 0 ) as payer_pmt_patnt_amt
            from t_rca_atb_snapshot_pb   
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.payer_pmt_patnt_amt = decode( src.payer_pmt_patnt_amt, 0, null, src.payer_pmt_patnt_amt )
    ;
    commit ;

    -- Balance - Patient...
    merge into t_rca_atb_snapshot_pb tgt
    using (
            select
                acct_id,
                acct_bill_area_id,
                decode( payer_1_id, -1, payer_bal_1_amt, 0 ) +                  -- -1 = self-pay
                    decode( payer_2_id, -1, payer_bal_2_amt, 0 ) + 
                    decode( payer_3_id, -1, payer_bal_3_amt, 0 ) + 
                    decode( payer_4_id, -1, payer_bal_4_amt, 0 ) + 
                    decode( payer_5_id, -1, payer_bal_5_amt, 0 ) as payer_bal_patnt_amt
            from t_rca_atb_snapshot_pb   
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.payer_bal_patnt_amt = decode( src.payer_bal_patnt_amt, 0, null, src.payer_bal_patnt_amt )
    ;
    commit ;

    -- Providers...
    merge into t_rca_atb_snapshot_pb tgt
    using (
              select
                  snp.acct_id,
                  snp.acct_bill_area_id,
                  csn.visit_prov_id  as  prvdr_id                           -- as physician_code
              from t_rca_atb_snapshot_pb         snp    
              join clarity.pat_enc@edws2clarity  csn  on  csn.pat_enc_csn_id = snp.acct_prim_enc_csn_id
          ) src
    on ( tgt.acct_id           = src.acct_id   and
         tgt.acct_bill_area_id = src.acct_bill_area_id )
    when matched then
    update /*+ parallel */ set
        tgt.prvdr_id = src.prvdr_id
    ;
    commit ;

    -- Expected Revenue...

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Insert Table...
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    execute immediate 'truncate table rca_atb_snapshot_pb' ;
    commit;

    insert into rca_atb_snapshot_pb
    (
        account_number, level_1_code, 
        parent_account_number, account_type,
        medical_record_number, last_name, first_name, middle_initial, birth_date, social_security_number,
        patient_type_code, hospital_service_code,     
        admit_date, discharge_date, last_bill_date,
        current_financial_class, financial_class_code1, financial_class_code2, financial_class_code3, financial_class_code4, financial_class_code5, 
        current_insurance_code, insurance_code1, insurance_code2, insurance_code3, insurance_code4, insurance_code5,
        insurance_payments1, insurance_payments2, insurance_payments3, insurance_payments4, insurance_payments5,
        insurance_balance1, insurance_balance2, insurance_balance3, insurance_balance4, insurance_balance5,
        patient_payments, patient_balance, 
        total_charges, total_payments, total_adjustments, account_balance,
        expected_revenue, primary_drg,
        patient_representative, responsibility_code, physician_code
    )    
    -- WFB-B1, WFB-B2, WFB-B3...
    select 
        acct_id                            as account_number,
        acct_bill_area_id                  as level_1_code,
        acct_recur_id                      as parent_account_number,
        null                               as account_type,                     -- Not needed at this time...
        patnt_mrn_id                       as medical_record_number, 
        patnt_last_name                    as last_name,
        patnt_frst_name                    as first_name,
        substr( patnt_mid_name, 1, 1 )     as middle_initial,
        patnt_birth_date                   as birth_date,
        patnt_ssn_num                      as social_security_number, 
        nvl( acct_class_code, -1 )         as patient_type_code,
        nvl( hosptl_servc_code, '-1' )     as hospital_service_code,     
        case acct_base_class_code
            when 'OP'
            then nvl( acct_admit_date, acct_dischrg_date )                      -- Per Spec: "Outpatient admission and discharge dates should be the same if one of the dates cannot be provided"
            else acct_admit_date
        end                                as admit_date,
        case acct_base_class_code
            when 'OP'
            then nvl( acct_dischrg_date, acct_admit_date )                      -- Per Spec: "Outpatient admission and discharge dates should be the same if one of the dates cannot be provided"
            else acct_dischrg_date
        end                                as discharge_date,
        coalesce( acct_last_bill_date, to_date( '01-JAN-1900' ) ) as last_bill_date, 
        case when nvl(payer_bal_1_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then coalesce( payer_fin_class_1_code, payer_prmry_fin_class_code, '4' )
             when nvl(payer_bal_2_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then payer_fin_class_2_code
             when nvl(payer_bal_3_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then payer_fin_class_3_code
             when nvl(payer_bal_4_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then payer_fin_class_4_code
             when nvl(payer_bal_5_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then payer_fin_class_5_code
             when nvl(payer_bal_patnt_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then '4'
             else null
        end                                as current_financial_class,         
        payer_fin_class_1_code             as financial_class_code1,
        payer_fin_class_2_code             as financial_class_code2,
        payer_fin_class_3_code             as financial_class_code3,
        payer_fin_class_4_code             as financial_class_code4,
        payer_fin_class_5_code             as financial_class_code5, 
        case when nvl(payer_bal_1_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then coalesce( payer_1_id, payer_prmry_id, -1 )
             when nvl(payer_bal_2_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then payer_2_id
             when nvl(payer_bal_3_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then payer_3_id
             when nvl(payer_bal_4_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then payer_4_id
             when nvl(payer_bal_5_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then payer_5_id
             when nvl(payer_bal_patnt_amt,-999999999) = greatest(nvl(payer_bal_1_amt,-999999999), nvl(payer_bal_2_amt,-999999999), nvl(payer_bal_3_amt,-999999999), nvl(payer_bal_4_amt,-999999999), nvl(payer_bal_5_amt,-999999999), nvl(payer_bal_patnt_amt,-999999999))
             then -1
             else null
        end                                as current_insurance_code,         
        payer_1_id                         as insurance_code1,
        payer_2_id                         as insurance_code2,
        payer_3_id                         as insurance_code3,
        payer_4_id                         as insurance_code4,
        payer_5_id                         as insurance_code5,
        decode( payer_pmt_1_amt, 0, null, payer_pmt_1_amt )          as insurance_payments1,
        decode( payer_pmt_2_amt, 0, null, payer_pmt_2_amt )          as insurance_payments2,
        decode( payer_pmt_3_amt, 0, null, payer_pmt_3_amt )          as insurance_payments3,
        decode( payer_pmt_4_amt, 0, null, payer_pmt_4_amt )          as insurance_payments4,
        decode( payer_pmt_5_amt, 0, null, payer_pmt_5_amt )          as insurance_payments5,
        decode( payer_bal_1_amt, 0, null, payer_bal_1_amt )          as insurance_balance1,
        decode( payer_bal_2_amt, 0, null, payer_bal_2_amt )          as insurance_balance2,
        decode( payer_bal_3_amt, 0, null, payer_bal_3_amt )          as insurance_balance3,
        decode( payer_bal_4_amt, 0, null, payer_bal_4_amt )          as insurance_balance4,
        decode( payer_bal_5_amt, 0, null, payer_bal_5_amt )          as insurance_balance5,
        decode( payer_pmt_patnt_amt, 0, null, payer_pmt_patnt_amt )  as patient_payments,
        decode( payer_bal_patnt_amt, 0, null, payer_bal_patnt_amt )  as patient_balance, 
        decode( total_chrg_amt, 0, null, total_chrg_amt )            as total_charges,
        decode( total_pymt_amt, 0, null, total_pymt_amt )            as total_payments,
        decode( total_adj_amt,  0, null, total_adj_amt  )            as total_adjustments,
        decode( total_bal_amt,  0, null, total_bal_amt  )            as account_balance,
        total_expctd_amt                   as expected_revenue,
        drg_code                           as primary_drg,
        patnt_acct_name                    as patient_representative,
        acct_user_code                     as responsibility_code,
        nvl( prvdr_id, '-1' )              as physician_code
    from t_rca_atb_snapshot_pb
    order by account_number, level_1_code
    ;
    commit;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Use this to export to "RCA - Epic - Daily ATB Snapshot PB.csv"...
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    select
        to_char( level_1_code,           'fm999999999999999999'  )  as level_1_code,
        to_char( account_number,         'fm999999999999999999'  ) || '_' || 
            to_char( level_1_code,           'fm999999999999999999'  ) as account_number, 
        -- to_char( account_number,         'fm999999999999999999'  )  as account_number,
        to_char( parent_account_number,  'fm999999999999999999'  )  as parent_account_number,
        account_type,
        medical_record_number,
        replace( substr( last_name, 1, 50 ), '"', '''' )            as last_name,
        replace( substr( first_name, 1, 50 ), '"', '''' )           as first_name,
        replace( middle_initial, '"', '''' )                        as middle_initial,
        to_char( birth_date,             'MM/DD/YYYY' )             as birth_date,      -- dates are 'MM/DD/YYYY HH24:MI' in the spec, but Jenna Bourdow said take out the timestamp (29-MAY-2013)...
        social_security_number,
        patient_type_code,
        hospital_service_code,     
        to_char( admit_date,             'MM/DD/YYYY' )             as admit_date, 
        to_char( discharge_date,         'MM/DD/YYYY' )             as discharge_date,
        to_char( last_bill_date,         'MM/DD/YYYY' )             as last_bill_date,
        current_financial_class,
        financial_class_code1,
        financial_class_code2,
        financial_class_code3,
        financial_class_code4,
        financial_class_code5, 
        to_char( current_insurance_code, 'fm999999999999999999'  )  as current_insurance_code, 
        to_char( insurance_code1,        'fm999999999999999999'  )  as insurance_code1,
        to_char( insurance_code2,        'fm999999999999999999'  )  as insurance_code2,
        to_char( insurance_code3,        'fm999999999999999999'  )  as insurance_code3,
        to_char( insurance_code4,        'fm999999999999999999'  )  as insurance_code4,
        to_char( insurance_code5,        'fm999999999999999999'  )  as insurance_code5,
        to_char( insurance_payments1,    'fm9999999999999990.00' )  as insurance_payments1, 
        to_char( insurance_payments2,    'fm9999999999999990.00' )  as insurance_payments2,
        to_char( insurance_payments3,    'fm9999999999999990.00' )  as insurance_payments3,
        to_char( insurance_payments4,    'fm9999999999999990.00' )  as insurance_payments4,
        to_char( insurance_payments5,    'fm9999999999999990.00' )  as insurance_payments5,
        to_char( insurance_balance1,     'fm9999999999999990.00' )  as insurance_balance1,
        to_char( insurance_balance2,     'fm9999999999999990.00' )  as insurance_balance2,
        to_char( insurance_balance3,     'fm9999999999999990.00' )  as insurance_balance3, 
        to_char( insurance_balance4,     'fm9999999999999990.00' )  as insurance_balance4,
        to_char( insurance_balance5,     'fm9999999999999990.00' )  as insurance_balance5,
        to_char( patient_payments,       'fm9999999999999990.00' )  as patient_payments,   
        to_char( patient_balance,        'fm9999999999999990.00' )  as patient_balance, 
        to_char( total_charges,          'fm9999999999999990.00' )  as total_charges, 
        to_char( account_balance,        'fm9999999999999990.00' )  as account_balance,
        to_char( expected_revenue,       'fm9999999999999990.00' )  as expected_revenue,
        primary_drg,
        replace( substr( patient_representative, 1, 20 ), '"', '''' ) as patient_representative,
        responsibility_code,
        physician_code
    from rca_atb_snapshot_pb 
    order by account_number, level_1_code 
    ;    
    */
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------


end ;

  exception
    when others then
        rollback ;
        raise ;
end ;


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
-- MAPPING FILES (ONE-TIME)   ( Initial mapping tables )
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
procedure sp_mapping_pb is    
begin

declare

begin       


    commit;  -- so it will compile


end ;

  exception
    when others then
        rollback ;
        raise ;
end ;


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
-- PATIENT DETAIL (ONE-TIME)   ( provides potential missing data for Historical ATB detail reports )
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
procedure sp_patient_detail_pb is    
begin

declare

begin       

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Insert Table...
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    execute immediate 'truncate table rca_patient_detail_pb' ;
    
    -- Charges...
    insert into rca_patient_detail_pb
    (
        account_number, level_1_code,
        total_charges
    )    
    select
        hsp_account_id                                  as account_number,
        nvl( bill_area_id, -1 )                         as level_1_code,
        decode( total_charges, 0, null, total_charges ) as total_charges
    from (    
            select
                hsp_account_id,
                bill_area_id,
                sum( amount ) as total_charges               -- use active_ar_amount instead?
            from clarity.clarity_tdl_tran@edws2clarity 
            where detail_type in ( 1, 10 )                   -- Charges
              and hsp_account_id is not null                 -- ( I found 38 records where har is null... assuming bad data... ) 
            group by 
                hsp_account_id,
                bill_area_id
         )        
    ;        
    commit ;
    
    -- Accounts...
    merge into rca_patient_detail_pb tgt
    using (
             select
                 snp.account_number,
                 snp.level_1_code,
                 har.adm_date_time    as admit_date,
                 har.disch_date_time  as discharge_date,
                 har.guarantor_id     as guarantor_id,
                 case nvl( base.base_class_map_c, 2 )                          -- Base patient class (many patient classes missing from hsd_base_class_map... Robert says okay to default to 2)
                     when 1 then 'IP'                                          -- 1 = "Inpatient"
                     when 2 then 'OP'                                          -- 2 = "Outpatient"
                     when 3 then 'OP'                                          -- 3 = "Emergency"
                     else null
                 end                  as base_class_code
              from rca_patient_detail_pb                         snp    
              join clarity.hsp_account@edws2clarity              har  on  har.hsp_account_id = snp.account_number
              left join clarity.pat_enc_2@edws2clarity           csn2  on  csn2.pat_enc_csn_id  = har.prim_enc_csn_id
              left join clarity.zc_acct_class_ha@edws2clarity    cls   on  cls.acct_class_ha_c  = nvl( har.acct_class_ha_c, csn2.adt_pat_class_c )
              left join clarity.hsd_base_class_map@edws2clarity  base  on  base.acct_class_map_c = cls.acct_class_ha_c  and  base.profile_id = 1  -- 1 = "WFBMC" 
          ) src
    on ( tgt.account_number = src.account_number and
         tgt.level_1_code   = src.level_1_code )
    when matched then
    update /*+ parallel */ set
        tgt.admit_date      = src.admit_date,
        tgt.discharge_date  = src.discharge_date,
        tgt.guarantor_id    = src.guarantor_id,
        tgt.base_class_code = src.base_class_code
    ;
    commit ;    
    
    -- Insurance...
    merge into rca_patient_detail_pb tgt
    using (
              with buckets as
              (
                  select
                     account_number, level_1_code, line_rank, payor_id
                  from (   
                          select
                            account_number, level_1_code, payor_id,
                            rank() over ( partition by account_number, level_1_code order by line ) as line_rank
                          from (
                                  select
                                      snp.account_number,
                                      snp.level_1_code,
                                      ac.line,
                                      cvg.payor_id,
                                      rank() over ( partition by snp.account_number, snp.level_1_code, cvg.payor_id order by ac.line ) as dup_rank
                                  from rca_patient_detail_pb                  snp    
                                  join clarity.acct_coverage@edws2clarity     ac   on  ac.account_id   = snp.guarantor_id
                                  join clarity.coverage@edws2clarity          cvg  on  cvg.coverage_id = ac.coverage_id  
                               ) 
                          where dup_rank = 1                -- get only one row per payor_id (the one with the smaller ac.line)...
                       )    
                    where line_rank <= 5                    -- limited to 5 payers for this extract
              )
              select
                  account_number, level_1_code,
                  "1" as insurance_code1, "2" as insurance_code2, "3" as insurance_code3, "4" as insurance_code4, "5" as insurance_code5
              from (
                      select bkt.account_number, bkt.level_1_code, bkt.line_rank, bkt.payor_id
                      from buckets               bkt
                  ) 
              pivot( max( payor_id ) for line_rank in ( 1, 2, 3, 4, 5 ))
          ) src
    on ( tgt.account_number = src.account_number and
         tgt.level_1_code   = src.level_1_code )
    when matched then
    update /*+ parallel */ set
        tgt.insurance_code1 = src.insurance_code1, 
        tgt.insurance_code2 = src.insurance_code2,
        tgt.insurance_code3 = src.insurance_code3,
        tgt.insurance_code4 = src.insurance_code4,
        tgt.insurance_code5 = src.insurance_code5
    ;
    commit ;    

   
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Use this to export to "RCA - Epic - One Time Patient Account Level Detail.csv"......
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    /*
    select
        to_char( level_1_code, 'fm999999999999999999'  )     as level_1_code,
        to_char( account_number, 'fm999999999999999999'  ) || '_' || 
            to_char( level_1_code, 'fm999999999999999999'  ) as account_number, 
        to_char( case base_class_code
                    when 'OP'
                    then nvl( admit_date, discharge_date )                                    -- Per ATB Spec: "Outpatient admission and discharge dates should be the same if one of the dates cannot be provided"
                    else admit_date
                 end ,'MM/DD/YYYY' )                         as admit_date,
        to_char( case base_class_code
                    when 'OP'
                    then nvl( discharge_date, admit_date )                                    -- Per ATB Spec: "Outpatient admission and discharge dates should be the same if one of the dates cannot be provided"
                    else discharge_date
                 end ,'MM/DD/YYYY' )                         as discharge_date,
        to_char( nvl( insurance_code1, -1 ),  'fm999999999999999999'  ) as insurance_code1,
        to_char( insurance_code2,  'fm999999999999999999'  ) as insurance_code2,
        to_char( insurance_code3,  'fm999999999999999999'  ) as insurance_code3,
        to_char( insurance_code4,  'fm999999999999999999'  ) as insurance_code4,
        to_char( insurance_code5,  'fm999999999999999999'  ) as insurance_code5,
        to_char( total_charges  ,  'fm9999999999999990.00' ) as total_charges
    from rca_patient_detail_pb 
    order by account_number, level_1_code 
    ;    
    */
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

end ;

  exception
    when others then
        rollback ;
        raise ;
end ;

end extp_rca_pb ;