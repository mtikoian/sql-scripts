WITH PLAN_LIST AS (SELECT ETR.TX_ID
              --, ETR.ORIGINAL_CVG_ID ORIGINAL_PRIMARY_COVERAGE
              --, ETR.CUR_CVG_ID CURRENT_COVERAGE --COVERAGE_ID CURRENT_COVERAGE
              --, COVERAGE_MEM_LIST.COVERAGE_ID CURRENT_PRIMARY_COVERAGE
              --, COVERAGE_MEM_LIST.PAT_ID PATIENT_ID
              --, COVERAGE_MEM_LIST.MEM_EFF_FROM_DATE
              --, COVERAGE_MEM_LIST.MEM_EFF_TO_DATE
              --, COVERAGE.CVG_EFF_DT
              --, COVERAGE.CVG_TERM_DT
                                  , COVERAGE.PAYOR_ID
                                  , COVERAGE.PLAN_ID
                                  , COVERAGE.SUBSCR_NAME
                                  , COVERAGE.SUBSCR_NUM
                                  , rel.title
                      --, PAT_CVG_FILE_ORDER.FILING_ORDER
                , ROW_NUMBER() OVER(PARTITION BY ETR.TX_ID ORDER BY COVERAGE_MEM_LIST.PAT_ID,                                     FILING_ORDER,COVERAGE_MEM_LIST.COVERAGE_ID ) TX_FILING_ORDER
              FROM COVERAGE_MEM_LIST
              INNER JOIN CLARITY_TDL_TRAN ETR ON 
      ETR.INT_PAT_ID = COVERAGE_MEM_LIST.PAT_ID --make sure you have the correct patient
      AND 
      ((etr.post_date>='1/1/2018' and etr.post_date<='1/7/2018'))
         --((etr.post_date>='7/1/2015' and etr.post_date<='12/31/2015'))
      -- or
      --('{?Run Period Parameter}'='Previous Day' and  
      --etr.post_date>=to_date(to_char(sysdate-1,'MM/DD/YYYY')||' 00:00:00','MM/DD/YYYY HH24:MI:SS') and 
      --etr.post_date<=to_date(to_char(sysdate,'MM/DD/YYYY')||' 00:00:00','MM/DD/YYYY HH24:MI:SS')))
      --AND ETR.post_date>=to_date(to_char(sysdate-1,'MM/DD/YYYY')||' 00:00:00','MM/DD/YYYY HH24:MI:SS')
      AND ETR.DETAIL_TYPE IN (1,10)
      --AND ETR.orig_service_date > to_date('01/01/2014','MM/DD/YYYY')
      --AND ETR.serv_area_id=2
         AND ETR.serv_area_id=11
		               INNER JOIN ACCT_COVERAGE EAR ON 
      EAR.ACCOUNT_ID = ETR.ACCOUNT_ID AND 
      COVERAGE_MEM_LIST.COVERAGE_ID = EAR.COVERAGE_ID --make sure you have the correct accounts
              INNER JOIN PAT_CVG_FILE_ORDER ON 
      COVERAGE_MEM_LIST.COVERAGE_ID = PAT_CVG_FILE_ORDER.COVERAGE_ID AND COVERAGE_MEM_LIST.PAT_ID = PAT_CVG_FILE_ORDER.PAT_ID --get the filing order
              INNER JOIN COVERAGE ON 
      COVERAGE.COVERAGE_ID = COVERAGE_MEM_LIST.COVERAGE_ID --get coverage level checks also
    left outer join zc_guar_rel_to_pat rel on
      coverage.subsc_rel_to_guar_c = rel.guar_rel_to_pat_c
              WHERE (MEM_EFF_FROM_DATE <= ETR.ORIG_SERVICE_DATE AND MEM_EFF_TO_DATE IS NULL) --check member effective dates
              OR (MEM_EFF_FROM_DATE <= ETR.ORIG_SERVICE_DATE AND MEM_EFF_TO_DATE >= ETR.ORIG_SERVICE_DATE)
              OR (MEM_EFF_FROM_DATE IS NULL AND MEM_EFF_TO_DATE >= ETR.ORIG_SERVICE_DATE)
              OR (
              MEM_EFF_FROM_DATE IS NULL AND MEM_EFF_TO_DATE IS NULL AND --coverage level date checks only if member level is empty
              (
              (CVG_EFF_DT <= ETR.ORIG_SERVICE_DATE AND CVG_TERM_DT IS NULL) OR
              (CVG_EFF_DT <= ETR.ORIG_SERVICE_DATE AND CVG_TERM_DT >= ETR.ORIG_SERVICE_DATE) OR
              (CVG_EFF_DT IS NULL AND CVG_TERM_DT >= ETR.ORIG_SERVICE_DATE) OR
              (CVG_EFF_DT IS NULL AND CVG_TERM_DT IS NULL)))),
              
  command as (select 
   aa.tx_id,
   aa.payor_id as payor1,
   aa.plan_id as plan1,
   aa.subscr_name as substr_name1,
   aa.subscr_num as subscr_num1,
   aa.title as rel_to_pat1,
   bb.payor_id as payor2,
   bb.plan_id as plan2,
   bb.subscr_name as substr_name2,
   bb.subscr_num as subscr_num2,
   bb.title as rel_to_pat2,
   cc.payor_id as payor3,
   cc.plan_id as plan3,
   cc.subscr_name as substr_name3,
   cc.subscr_num as subscr_num3,
   cc.title as rel_to_pat3,
   dd.payor_id as payor4,
   dd.plan_id as plan4,
   dd.subscr_name as substr_name4,
   dd.subscr_num as subscr_num4,
   dd.title as rel_to_pat4
   from plan_list aa
      left join plan_list bb on
       aa.tx_id = bb.tx_id and bb.tx_filing_order=2
      left join plan_list cc on
       aa.tx_id = cc.tx_id and cc.tx_filing_order=3
      left join plan_list dd on
       aa.tx_id = dd.tx_id and dd.tx_filing_order=4
   where
    aa.TX_FILING_ORDER=1)

select
ct.account_id,
ct.loc_id,
ct.orig_service_date,
ct.billing_provider_id,
pt.birth_date,
pt.city,
cmd.substr_name1,
cmd.subscr_num1,
pt.pat_mrn_id,
pt.pat_first_name,
pt.pat_name,
cmd.payor1,
cmd.payor2,
cmd.payor3,
cmd.payor4,
cmd.plan1,
cmd.plan2,
cmd.plan3,
cmd.plan4,
cmd.rel_to_pat1,
cmd.rel_to_pat2,
cmd.rel_to_pat3,
cmd.rel_to_pat4,
pt.zip,
ct.tx_id,
ct.detail_type,
ct.post_date,
ct.performing_prov_id,
ct.pos_id,
clarity_pos.pos_code,
ct.hsp_account_id,
ct.pat_enc_csn_id,
at2.tx_acct_serial_number,
ct.charge_slip_number,
at.debit_credit_flag,
sbo.sbo_har_type_c,
csd.first_invoice_num
from Clarity_tdl_tran ct
  left outer join arpb_transactions at on
     ct.tx_id = at.tx_id
  left outer join arpb_transactions2 at2 on
     ct.tx_id = at2.tx_id
  left outer join patient pt on
     ct.int_pat_id = pt.pat_id
  left outer join hsp_acct_sbo sbo on
     ct.hsp_account_id = sbo.hsp_account_id
  left outer join Command cmd on
     ct.tx_id = cmd.tx_id
  left outer join claim_stmnt_date csd on
     ct.tx_id = csd.tx_id
  left outer join clarity_pos on
     ct.pos_id = clarity_pos.pos_id
where 
((ct.post_date>='1/1/2018' and ct.post_date<='1/7/2018'))
--((ct.post_date>='7/1/2015' and ct.post_date<='12/31/2015'))
--(('{?Run Period Parameter}'='Custom Date Range' and ct.post_date>={?StartDate} and ct.post_date<={?EndDate}))
--or
--('{?Run Period Parameter}'='Previous Day' and  
--ct.post_date>=to_date(to_char(sysdate-1,'MM/DD/YYYY')||' 00:00:00','MM/DD/YYYY HH24:MI:SS') and 
--ct.post_date<=to_date(to_char(sysdate,'MM/DD/YYYY')||' 00:00:00','MM/DD/YYYY HH24:MI:SS'))) 
and
--ct.post_date>=to_date(to_char(sysdate-1,'MM/DD/YYYY')||' 00:00:00','MM/DD/YYYY HH24:MI:SS') and
ct.detail_type in (1,10) and
--ct.orig_service_date > to_date('01/01/2014','MM/DD/YYYY') and
--ct.serv_area_id=2 and
ct.serv_area_id=11 and
csd.first_invoice_num is not null
