--declare @start_date as date = EPIC_UTIL.EFN_DIN('{?Start Date}')
--declare @end_date as date = EPIC_UTIL.EFN_DIN('{?End Date}')

declare @start_date as date = EPIC_UTIL.EFN_DIN('mb')
declare @end_date as date = EPIC_UTIL.EFN_DIN('me')

select

case when loc.loc_id in ('11106','11124')  then 'SPRINGFIELD'
	 when loc.loc_id in ('11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138') then 'CINCINNATI'
	 when loc.loc_id in ('13104','13105') then 'YOUNGSTOWN'
	 when loc.loc_id in ('16102','16103','16104') then 'LIMA'
	 when loc.loc_id in ('17105','17106','17107','17108','17109','17110','17112','17113') then 'LORAIN'
	 when loc.loc_id in ('18120','18121') then 'DEFIANCE'
	 when loc.loc_id in ('18101','18102','18103','18104','18105','18130','18131','18132','18133')  then 'TOLEDO'
	 when loc.loc_id in ('18110') then 'TOLEDO - MRG'
	 when loc.loc_id in ('19101','19102','19106') then 'KENTUCKY' 
	 when loc.loc_id in ('19107','19108','19116','19118') then 'KENTUCKY - OTHER ENTITIES'
	 when loc.loc_id in ('131201','131202') then 'SUMMA'
	 end as 'REGION'
,tdl.loc_id as 'LOCATION ID'
,loc.loc_name as 'LOCATION NAME'
,tdl.dept_id as 'DEPARTMENT ID'
,dep.department_name as 'DEPARTMENT NAME'
,tdl.account_id as 'ACCOUNT ID'
,acct.account_name as 'ACCOUNT NAME'
,dd.year as 'YEAR'
,dd.month_number as 'MONTH NUMBER'
,dd.month_name as 'MONTH'
,dd.week_number as 'WEEK'
,tdl.post_date as 'POST DATE'
,tdl.tx_num as 'TRANSACTION NUMBER'
,eap.proc_code as 'PROCEDURE CODE'
,eap.proc_name as 'PROCEDURE NAME'
,case when dep.department_id in (11102101, 13104134, 16104001, 17109101, 18104110, 19101110) then 'BILLING OFFICE'
	when eap.proc_code in ('1000','1002','1005','1006','1009','6008','8006') then 'OUTSTANDING BALANCES'
	when eap.proc_code in ('1001') then 'COPAY'
	end as 'COLLECTION TYPE'
,tdl.amount as 'PAYMENT AMOUNT'
,zps.name as 'PAYMENT SOURCE'
,zmds.name as 'PAYMENT MODULE'
,tdl.user_id as 'USER ID'
,emp.name as 'USER NAME'

from

clarity_tdl_tran tdl
left join clarity_dep dep on dep.department_id = tdl.dept_id  
left join clarity_loc loc on loc.loc_id = tdl.loc_id
left join clarity_eap eap on eap.proc_id = tdl.proc_id
left join account acct on acct.account_id = tdl.account_id
left join arpb_transactions arpb_tx on arpb_tx.tx_id = tdl.tx_id
left join zc_payment_source zps on zps.payment_source_c = tdl.orig_pay_source_c
left join clarity_emp emp on emp.user_id = tdl.user_id
left join zc_mtch_dist_src zmds on zmds.mtch_tx_hx_dist_c = arpb_tx.credit_src_module_c
left join date_dimension dd on dd.calendar_dt_str = tdl.post_date

where 

/*PROC_CODE	PROC_NAME
1000	PATIENT PAYMENT (ACCOUNT)
1001	CO-PAYMENT (ACCOUNT)
1002	PRE-PAYMENT (ACCOUNT)
1005	OB PRE-PAYMENT (ACCOUNT)
1006	COLLECTION AGENCY PAYMENT (ACCOUNT)
1009	BARIATRICS PRE-PAYMENT (ACCOUNT)
6008	PAYMENT REVERSAL (ACCOUNT)
8006	CLIENT PAYMENT (ACCOUNT)
*/

eap.proc_code in ('1000','1001','1002','1005','1006','1009','6008','8006') 

and (tdl.debit_gl_num = 'cash' or tdl.credit_gl_num = 'cash')

/*DETAIL_TYPE	NAME
2	New Payment
3	New Debit Adjustment
4	New Credit Adjustment
5	Payment Reversal
6	Credit Adjustment Reversal
11	Void Payment
12	Void Debit Adjustment
13	Void Credit Adjustment
*/

and tdl.detail_type in (2,3,4,5,6,11,12,13)
and tdl.post_date >= @start_date
and tdl.post_date <= @end_date


-- SPRINGFILED
and loc.loc_id in ('11106','11124'
-- CINCINNATI
,'11101','11102','11103','11104','11105','11115','11116','11122','11139','11140','11141','11142','11143','11144','11146','11149','11151','11132','11138'
-- YOUNGSTOWN
,'13104','13105'
-- LIMA
,'16102','16103','16104'
-- LandAIN
,'17105','17106','17107','17108','17109','17110','17112','17113'
-- DEFIANCE
,'18120','18121'
-- TOLEDO 
,'18101','18102','18103','18104','18105','18130','18131','18132','18133'
-- TOLEDO MRG
,'18110'
-- KENTUCKY
,'19101','19102','19106'
-- KENTUCKY - OTHER ENTITIES
,'19107','19108','19116','19118'
-- SUMMA
,'131201','131202')


