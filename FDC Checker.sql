select
 cast(post_date as date) as 'Payment Date'
,dep.DEPARTMENT_NAME as 'Department'
,id.IDENTITY_ID as 'MRN'
,tx_id as 'Payment ID'
,emp.name as 'User'
,amount*-1 as 'Amount'
from arpb_transactions arpb_tx
left join clarity_emp emp on emp.user_id = arpb_tx.user_id
left join clarity_dep dep on dep.department_id = arpb_tx.DEPARTMENT_ID
left join identity_id id on id.pat_id = arpb_tx.PATIENT_ID
where tx_type_c = 2
and arpb_tx.department_id = 19390165
and post_date >= '2/1/2019'
and IDENTITY_TYPE_ID = 0