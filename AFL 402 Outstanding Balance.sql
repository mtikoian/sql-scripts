select arpb.ACCOUNT_ID, acct.ACCOUNT_NAME, sum(patient_amt) 'Patient Amt', sum(insurance_amt) as 'Insurance Amt'
from arpb_transactions arpb
left join account acct on arpb.account_id = acct.account_id
where service_area_id = 402
and OUTSTANDING_AMT > 0
group by arpb.ACCOUNT_ID, acct.ACCOUNT_NAME
order by acct.ACCOUNT_NAME