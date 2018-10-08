SELECT 
       tdl.TX_ID
      ,doc_start_time
      ,doc_end_time
      ,tdl.POST_DATE
FROM
      CLARITY_TDL_TRAN tdl
      INNER JOIN DOC_PROVIDER doc on tdl.tx_id = doc.tx_id
WHERE 
      TYPE_OF_SERVICE = '7'
      and
      DETAIL_TYPE in ('1','10')
      and 
      tdl.POST_DATE between '06/01/2014' and '06/30/2014'
      and (DOC_START_TIME is not null
      or DOC_END_TIME is not null)
