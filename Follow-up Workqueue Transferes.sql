select
 fi.FOL_ID
,fi.FOL_CREATED_DATE
,fi.TRANSACTION_ID
,fi.WQ_ENTRY_DATE
,fh.LINE
,fh.ACT_CUR_WQ_ID
,fw.WORKQUEUE_NAME
,emp.NAME
,zfa.NAME

from FOL_INFO fi
left join FOL_HISTORY fh on fh.FOL_ID = fi.FOL_ID
left join ZC_FOL_ACTIVITY zfa on zfa.FOL_ACTIVITY_C = fh.ACT_TYPE_C
left join CLARITY_EMP emp on emp.USER_ID = fh.ACT_USER_ID
left join FOL_WQ fw on fw.WORKQUEUE_ID = fh.ACT_CUR_WQ_ID
where transaction_id = 199246490
and zfa.NAME = 'Transfer'

