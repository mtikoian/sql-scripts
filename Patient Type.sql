select 
   'ALL' as 'LEVEL_1_CODE'
  ,zpc.adt_pat_class_c as 'PATIENT_TYPE_CODE'
  ,zpc.name as 'PATIENT_TYPE_DESCRIPTION'
  ,zabh.name as 'PATIENT_ACCOUNT_TYPE'
  ,case when zpc.name like '%recurring%' then 'Recurring' else 'Not Recurring' end as 'PATIENT_TYPE_ID'
 

from zc_acct_basecls_ha zabh
left join hsd_base_class_map hbcm on zabh.acct_basecls_ha_c = hbcm.base_class_map_c
left join zc_pat_class zpc on hbcm.acct_class_map_c = zpc.adt_pat_class_c

order by acct_basecls_ha_c
