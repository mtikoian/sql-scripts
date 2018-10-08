select 
   'ALL' as 'LEVEL_1_CODE'
   ,PROC_ID
   ,proc_code as 'TRANSACTION_CODE'
  ,proc_name as 'TRANSACTION_NAME'
  ,'' as 'TRANSACTION_TYPE'
  ,'' as 'TRANSACTION_SUB_TYPE'
  ,IS_ACTIVE_YN

  

from clarity_eap
where IS_ACTIVE_YN = 'Y'

order by proc_id
