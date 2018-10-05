--version 3/17/2015

---opcost startdate DATEADD(yyyy, DATEDIFF(yy, 0, dateadd(dd,-1,dateadd(mm,datediff(mm,0,GETDATE()),0))) , 0)   enddate    dateadd(d,0,datediff(d,0,getdate())-1) 
---copay startdate dateadd(d,0,datediff(d,0,getdate())-7) enddate  dateadd(d,0,datediff(d,0,getdate())-1) 
---daily details startdate dateadd(dd,datediff(dd,0,getdate()),-1)   enddate dateadd(dd,datediff(dd,0,getdate()),-1)

declare @startdate date  = dateadd(d,0,datediff(d,0,getdate())-7) 
		,@enddate date = dateadd(d,0,datediff(d,0,getdate())-1) ---yesterday

;
with cteCopay as
(
select   ----account lvl grouping - sums up copay due/paid for multiple visits -  pull pat balance due once per day - all flags are 1 = no copay due
		visit.Division
		,visit.Section
		,visit.ACCOUNT_ID
		,visit.ACCOUNT_NAME
		,visit.department_id
		,visit.department_name
		,visit.contact_date
		,visit.patient_balance
		,visit.PAT_NAME
		,visit.PAT_MRN_ID
		,visit.BIRTH_DATE 
		,sum(CASE when (visit.Fin_class_flag = 2 and visit.No_CoPay_Flag = 2 and visit.coverage_count < 2) then isnull(visit.COPAY_DUE,0) else 0 end) as Copay_Due -- (not self pay or medicaid) and (not a no copay procID) and (not mutliple coverages)
		,sum(CASE when (visit.Fin_class_flag = 2 and visit.No_CoPay_Flag = 2 and visit.coverage_count < 2) then isnull(visit.COPAY_collected,0) else 0 end) as Copay_Collected -- (not self pay or medicaid) and (not a no copay procID) and (not mutliple coverages)
			
from
		(	-------------visit level groupings - pulling copay, and pat balance, setting loc_flg, fin_class_flag, and coverage count flag
		select 
				min(case when clarity_eap.proc_id in (23578,66685,66693,66701,66709,66717,66725,66733,66741,66749,66757,66765,66773,69094,100016,109313,99924,99926,100296,99918,99906,99908,99910,99912,99914,99916,99920,99902,99892,99894,99896,99898,99900,99904,99890,99996,99888,99922,16532,16534,16536,114453,114457,114461,22298,22300,22302,22304,22306,22308,22310,22312,22314,22316,22318,22320,22322,22324,22326,22328,22330,22332,23584,1077,1081,23846,23848,23850,23852,23854,23856,23858,23860,23862,23864,23866,23868,23870,23872,23888,23892,65224,94319,94323,94327,94331,23902,23904,23906,94339,94347,23908,103554,84719,243924,243926,32028,68008,68004,22334,22356,1065,1069,1073,27508,23656, 83789, 83792, 83795) then 1 else 2 end) as No_CoPay_Flag		--1 for no copay, 2 for copay
				,min (isnull(coverages.Fin_class_flag,1)) as Fin_class_flag   ---1 for medicaid 2 for everything else - nulls are self pays and should not have a co-pay
				,max(isnull(coverages.coverage_count,0)) as Coverage_count ----# of coverages for that visit
				,case when clarity_dep.DEPARTMENT_ID = 104650065 then 'Florence Pediatrics' else ZC_DEP_RPT_GRP_16.NAME end as DIVISION
				,case when clarity_dep.DEPARTMENT_ID = 104650065 then 'Florence Pediatrics' else coalesce(ZC_DEP_RPT_GRP_15.name, ZC_DEP_RPT_GRP_14.name, ' No Dept/Sect') end as Section
				,pat_enc.DEPARTMENT_ID
				,CLARITY_DEP.DEPARTMENT_NAME
				,pat_enc.ACCOUNT_ID
				,ACCOUNT.ACCOUNT_NAME
				,PAT_ENC.PAT_ID
				,PAT_ENC.CONTACT_DATE
				,case when (x_sep_patient_balance_history.MedicaidPending is null and X_SEP_PATIENT_BALANCE_HISTORY.PaymentPlan is null and X_SEP_PATIENT_BALANCE_HISTORY.Charity is null) then isnull(X_SEP_PATIENT_BALANCE_HISTORY.PATIENT_BALANCE,0) else 0 end as Patient_Balance
				,pat_enc.COPAY_DUE
				,pat_enc.COPAY_COLLECTED
				,patient.PAT_MRN_ID
				,patient.PAT_NAME
				,patient.BIRTH_DATE
		from 
				PAT_ENC
				inner join CLARITY_DEP on PAT_ENC.DEPARTMENT_ID=CLARITY_DEP.DEPARTMENT_ID and CLARITY_DEP.RPT_GRP_SIX in (1,2)
				inner join ZC_DEP_RPT_GRP_16 on CLARITY_DEP.RPT_GRP_SIXTEEN_C=ZC_DEP_RPT_GRP_16.RPT_GRP_SIXTEEN_C
				left join ZC_DEP_RPT_GRP_15 on ZC_DEP_RPT_GRP_15.RPT_GRP_FIFTEEN_C = clarity_dep.RPT_GRP_FIFTEEN_C     --added Jan 2015
				left join ZC_DEP_RPT_GRP_14 on ZC_DEP_RPT_GRP_14.rpt_Grp_fourteen_c = clarity_dep.rpt_grp_fourteen_c
				inner join CLARITY_EAP on CLARITY_EAP.PROC_Code = Pat_enc.LOS_PROC_CODE and CLARITY_EAP.RPT_GRP_ELEVEN_C in (10, 11)    ----office visit type codes only                                        
				inner join ACCOUNT on account.ACCOUNT_ID = PAT_ENC.ACCOUNT_ID and NOT(account.ACCOUNT_name like('sep %') or account.ACCOUNT_NAME like ('sep,%'))
				left join  X_SEP_PATIENT_BALANCE_HISTORY ON PAT_ENC.ACCOUNT_ID=X_SEP_PATIENT_BALANCE_HISTORY.account_id AND PAT_ENC.CONTACT_DATE=X_SEP_PATIENT_BALANCE_HISTORY.contact_date
				left join PATIENT on patient.PAT_ID = pat_enc.PAT_ID  
				left join 
				(
					select    ------------------------------counts the number of payors (insurances) a patient had on the day of their visit.
						PAT_ENC.PAT_id,
						PAT_ENC.CONTACT_DATE,
						min(case when isnull(CLARITY_EPM.FINANCIAL_CLASS,4) in (3, 105) then 1 else 2 end) as Fin_class_flag,   --looking for medicaid 
						count(distinct COVERAGE.Payor_id) as Coverage_count
					from 
						Pat_enc
						inner join clarity_dep on clarity_dep.DEPARTMENT_ID = PAT_ENC.DEPARTMENT_ID and clarity_dep.rpt_grp_six in (1,2)
						left join ACCOUNT on ACCOUNT.ACCOUNT_ID = PAT_ENC.ACCOUNT_ID  --------CHANGED THIS JOIN FROM  left join ACCOUNT on ACCOUNT.ACCOUNT_ID = ACCT_COVERAGE.ACCOUNT_ID ON 24 oCT 2014
						left join COVERAGE_MEM_LIST on COVERAGE_MEM_LIST.PAT_ID = PAT_ENC.pat_id
						left join COVERAGE on COVERAGE.COVERAGE_ID = COVERAGE_MEM_LIST.COVERAGE_ID
						left join CLARITY_EPM on CLARITY_EPM.PAYOR_ID = COVERAGE.PAYOR_ID
						left join CLARITY_EPP on clarity_epp.BENEFIT_PLAN_ID = coverage.PLAN_ID
						left join PLAN_BILL_TYPES on PLAN_BILL_TYPES.BENEFIT_PLAN_ID = coverage.PLAN_ID
					where
						isnull(PLAN_BILL_TYPES.BILLING_TYPES_C, 1) = 1  --dumps coverages that are not valid for professional billing 
						and isnull(MEM_COVERED_YN,'n') = 'Y'   --dumps anyone not covered null = not covered
			            and isnull(COVERAGE_MEM_LIST.MEM_EFF_FROM_DATE, pat_enc.CONTACT_DATE) <= pat_enc.CONTACT_DATE  --dumps all members of coverage that we not members as of startdate, = null = covered
						and isnull(COVERAGE_MEM_LIST.MEM_EFF_TO_DATE, pat_enc.CONTACT_DATE) >= pat_enc.CONTACT_DATE       ---dumps all members of coverages canceled prior to enddate, null=covered
						and isnull(COVERAGE.CVG_TERM_DT,pat_enc.CONTACT_DATE) >= pat_enc.CONTACT_DATE    ---dumps all coverages canceled prior to enddate,  null = covered
						and ISNULL(coverage.cvg_eff_dt, pat_enc.CONTACT_DATE) <= pat_enc.CONTACT_DATE  --dumps all coverages that were not effective as of startdate, null = covered
						and isnull(ACCOUNT.IS_ACTIVE, 'Y') = 'Y'
						and CLARITY_EPM.FINANCIAL_CLASS <> 5  --dumps workers comp coverages and visits
						and ((account.ACCOUNT_TYPE_C in (113, 115, 120, 122, 123, 124, 154) and clarity_dep.RPT_GRP_ELEVEN_C <> 6520) or (account.account_type_c in (143, 144) and clarity_dep.RPT_GRP_ELEVEN_C = 6520))
						---and account.ACCOUNT_TYPE_C in (113, 115, 120, 122, 123, 124, 154)    --sep accounts only and no 3rd party liability, workers comp, (beh health accounts removed 2015)
						and PAT_ENC.CONTACT_DATE between @startdate and @enddate
						--and PAT_ENC.pat_enc_csn_id = 1038701978 ---------------------------------------------------------------------------------------------------------test data
					group by
						pat_enc.PAT_id,
						PAT_ENC.CONTACT_DATE
				)as coverages on coverages.PAT_ID = Pat_Enc.PAT_ID and coverages.CONTACT_DATE = Pat_Enc.CONTACT_DATE
		where 
				pat_enc.APPT_STATUS_C= 2 
				and convert(int, ENC_TYPE_C) in (50, 101, 1001, 1003, 1200, 1214, 2, 2101, 2507, 2508)  -----------------Jan 2015 modified for more encounter types
				and CANCEL_REASON_C is null 
				and PAT_ENC.CONTACT_DATE between @startdate and @enddate
				---and PAT_ENC.pat_enc_csn_id = 1038701978---------------------------------------------------------------------------------------------------------------------test data

		group by                  ----to get details for patient (not account) encounter
				case when clarity_dep.DEPARTMENT_ID = 104650065 then 'Florence Pediatrics' else ZC_DEP_RPT_GRP_16.NAME end 
				,case when clarity_dep.DEPARTMENT_ID = 104650065 then 'Florence Pediatrics' else coalesce(ZC_DEP_RPT_GRP_15.name, ZC_DEP_RPT_GRP_14.name, ' No Dept/Sect') end 
				,pat_enc.DEPARTMENT_ID
				,CLARITY_DEP.DEPARTMENT_NAME
				,pat_enc.ACCOUNT_ID
				,ACCOUNT.ACCOUNT_NAME
				,PAT_ENC.PAT_ID
				,PAT_ENC.CONTACT_DATE
				,case when (x_sep_patient_balance_history.MedicaidPending is null and X_SEP_PATIENT_BALANCE_HISTORY.PaymentPlan is null and X_SEP_PATIENT_BALANCE_HISTORY.Charity is null) then isnull(X_SEP_PATIENT_BALANCE_HISTORY.PATIENT_BALANCE,0) else 0 end 
				,pat_enc.COPAY_DUE
				,pat_enc.COPAY_COLLECTED
				,patient.PAT_MRN_ID
				,patient.PAT_NAME
				,patient.BIRTH_DATE
		) as visit
group by
		visit.Division
		,visit.Section
		,visit.ACCOUNT_ID
		,visit.ACCOUNT_NAME
		,visit.department_id
		,visit.department_name
		,visit.contact_date
		,visit.patient_balance 
		,visit.PAT_NAME
		,visit.PAT_MRN_ID
		,visit.BIRTH_DATE 
)
,		

ctePayment as
(		
				
select 
		case when clarity_dep.DEPARTMENT_ID = 104650065 then 'Florence Pediatrics' else ZC_DEP_RPT_GRP_16.NAME end as DIVISION
		,case when clarity_dep.DEPARTMENT_ID = 104650065 then 'Florence Pediatriccs' else coalesce(ZC_DEP_RPT_GRP_15.name, ZC_DEP_RPT_GRP_14.name, ' No Dept/Sect') end as Section
		,CLARITY_DEP.DEPARTMENT_ID 
		,DEPARTMENT_NAME
		,account.account_name
		,account.ACCOUNT_ID
		,ARPB_TRANSACTIONS.POST_DATE
		,sum(case when (X_SEP_PATIENT_BALANCE_HISTORY.PaymentPlan is null and X_SEP_PATIENT_BALANCE_HISTORY.MedicaidPending is null and X_SEP_PATIENT_BALANCE_HISTORY.Charity is null) then isnull(X_SEP_PATIENT_BALANCE_HISTORY.PATIENT_BALANCE,0) else 0 end) as patient_balance
		,sum(case when (X_SEP_PATIENT_BALANCE_HISTORY.PaymentPlan is null and X_SEP_PATIENT_BALANCE_HISTORY.MedicaidPending is null and X_SEP_PATIENT_BALANCE_HISTORY.Charity is null) then isnull(ARPB_TRANSACTIONS.AMOUNT,0)*-1 else 0 end )as patient_payment

FROM 
		X_SEP_PATIENT_BALANCE_HISTORY
		left join ARPB_TRANSACTIONS ON ARPB_TRANSACTIONS.ACCOUNT_ID=X_SEP_PATIENT_BALANCE_HISTORY.account_id and X_SEP_PATIENT_BALANCE_HISTORY.contact_date=ARPB_TRANSACTIONS.POST_DATE and ARPB_TRANSACTIONS.proc_id in (36263, 7334, 7332, 84726, 7084)
		INNER JOIN CLARITY_DEP ON CLARITY_DEP.DEPARTMENT_ID=ARPB_TRANSACTIONS.DEPARTMENT_ID
		inner join ZC_DEP_RPT_GRP_16 on CLARITY_DEP.RPT_GRP_SIXTEEN_C=ZC_DEP_RPT_GRP_16.RPT_GRP_SIXTEEN_C
		left join ZC_DEP_RPT_GRP_15 on ZC_DEP_RPT_GRP_15.RPT_GRP_FIFTEEN_C = clarity_dep.RPT_GRP_FIFTEEN_C     --added Jan 2015
		left join ZC_DEP_RPT_GRP_14 on ZC_DEP_RPT_GRP_14.rpt_Grp_fourteen_c = clarity_dep.rpt_grp_fourteen_c    --added Jan 2015
		inner join ACCOUNT on account.ACCOUNT_ID = ARPB_TRANSACTIONS.ACCOUNT_ID
WHERE 
		CLARITY_DEP.RPT_GRP_SIX IN (1,2)
		and ARPB_TRANSACTIONS.proc_id in (7084,7332,7334,36263,84726)    ---Jan 2015 added payments - proc code 1004 and 1002
		and ARPB_TRANSACTIONS.post_date between @startdate and @enddate 
		and ARPB_TRANSACTIONS.VOID_DATE is null
		and ARPB_TRANSACTIONS.TX_TYPE_C = 2
		and	NOT( account.ACCOUNT_name like('sep %') or account.ACCOUNT_NAME like ('sep,%'))   
		----and ARPB_TRANSACTIONS.ACCOUNT_ID = 800067640 ---------------------------------------------------------------------------------------------------test data
				
group by 
		case when clarity_dep.DEPARTMENT_ID = 104650065 then 'Florence Pediatrics' else ZC_DEP_RPT_GRP_16.NAME end 
		,case when clarity_dep.DEPARTMENT_ID = 104650065 then 'Florence Pediatriccs' else coalesce(ZC_DEP_RPT_GRP_15.name, ZC_DEP_RPT_GRP_14.name, ' No Dept/Sect') end
		,CLARITY_DEP.DEPARTMENT_ID 
		,DEPARTMENT_NAME
		,account.account_name
		,account.ACCOUNT_ID
		,ARPB_TRANSACTIONS.POST_DATE

)

------------------------------------------------------------------------------------------END CTE-------------------------------------------------------------------

--SELECT 

--case 
--when calc.Division in('SEP Flo Pediatrics','Florence Pediatrics') then 10
--when calc.groupbycolumn = 'St. Elizabeth Physicians' then 35
--		when calc.section = 'Convenient Care' then 45
--		when calc.Division = 'Primary Care' then 35 
--		when calc.section = 'Heart & Vascular' then 35
--		when calc.division = 'Medical Specialty' then 30
--		when calc.division = 'Surgical Specialty' then 40
--		else 50 end as benchmark

--,calc.groupbycolumn
--,calc.Division
--,calc.section
--,calc.Office
--,calc.Week_Number
--,calc.WeeklyPatBalance
--,calc.WeeklyPatPayment
--,calc.WeeklyCoPayDue
--,calc.WeeklyCoPayCollected
--,calc.WeeklyCoPayRate * 100 as WeeklyCoPayRat
--,calc.WeeklyPatPayRate * 100 as WeeklyPatPayRate
--,calc.WeeklyOpportunity
--,calc.WeeklyTotalPayments
--,calc.WeeklySuccessRate * 100 as WeeklySuccessRate
--,calc.YearlycoPayDue
--,calc.YearlyCoPayCollected
--,calc.YearlyPatBalance
--,calc.YearlyPatPay
--,calc.YearlyOpportunity
--,calc.YearlyTotalPayments
--,sum(case when calc.YearlycoPayDue = 0 then 0 else (calc.YearlyCoPayCollected / calc.YearlycoPayDue) * 100 end) over (partition by calc.groupbycolumn,calc.Division,calc.section,calc.Office,calc.Week_Number) as YearlyCoPayRate
--,sum(case when calc.YearlyPatBalance = 0 then 0 else (calc.YearlyPatPay / calc.YearlyPatBalance) * 100 end) over (partition by calc.groupbycolumn,calc.Division,calc.section,calc.Office,calc.Week_Number) as YearlyPatPayRate
--,sum(case when calc.YearlyOpportunity = 0 then 0 else (calc.YearlyTotalPayments / calc.YearlyOpportunity) * 100 end) over (partition by calc.groupbycolumn,calc.Division,calc.section,calc.Office,calc.Week_Number) as YearlySuccessRate

--FROM
--(



--select 

--	YearRollUp.groupbycolumn
--	,YearRollUp.Division
--	,YearRollUp.Section
--	,YearRollUp.Office
--	,YearRollUp.Week_Number
--	,YearRollUp.WeeklyPatBalance
--	,YearRollUp.WeeklyPatPayment
--	,YearRollUp.WeeklyCoPayDue
--	,YearRollUp.WeeklyCoPayCollected
--	,YearRollUp.WeeklyCoPayRate
--	,YearRollUp.WeeklyPatPayRate
--	,YearRollUp.WeeklyOpportunity
--	,YearRollUp.WeeklyTotalPayments
--	,YearRollUp.WeeklySuccessRate
--	,sum(YearRollUp.WeeklyCoPayDue) over (partition by YearRollUp.groupbycolumn,YearRollUp.Division,YearRollUp.Section,YearRollUp.Office) as YearlyCoPayDue
--	,sum(YearRollUp.WeeklyCoPayCollected) over (partition by YearRollUp.groupbycolumn,YearRollUp.Division,YearRollUp.Section,YearRollUp.Office) as YearlyCoPayCollected
--	,sum(YearRollUp.WeeklyPatBalance) over (partition by YearRollUp.groupbycolumn,YearRollUp.Division,YearRollUp.Section,YearRollUp.Office) as YearlyPatBalance
--	,sum(YearRollUp.WeeklyPatPayment) over (partition by YearRollUp.groupbycolumn,YearRollUp.Division,YearRollUp.Section,YearRollUp.Office) as YearlyPatPay
--	,sum(YearRollUp.WeeklyOpportunity) over (partition by YearRollUp.groupbycolumn,YearRollUp.Division,YearRollUp.Section,YearRollUp.Office) as YearlyOpportunity
--	,sum(YearRollUp.WeeklyTotalPayments) over (partition by YearRollUp.groupbycolumn,YearRollUp.Division,YearRollUp.Section,YearRollUp.Office) as YearlyTotalPayments

--		from
--		(
--		select 

--			case		
--				when RuTemp.Division is null then 'St. Elizabeth Physicians' 
--				when RuTemp.Section is null then RuTemp.Division
--				when RuTemp.Department_ID is null then RuTemp.Section
--				else RuTemp.Department_Name 
--			end as GroupByColumn
--			,RuTemp.Division
--			,rutemp.section
--			,RuTemp.Department_Name as Office
--			,RuTemp.WEEK_NUMBER
--			,ruTemp.Patient_Balance as WeeklyPatBalance
--			,RuTemp.Patient_Payment as WeeklyPatPayment
--			,RuTemp.CoPay_Due as WeeklyCoPayDue
--			,RuTemp.CoPay_Collected as WeeklyCoPayCollected
--			,case when RuTemp.CoPay_Due = 0 then 0 else RuTemp.CoPay_Collected / CoPay_Due end as WeeklyCoPayRate
--			,case when RuTemp.Patient_Balance = 0 then 0 else  RuTemp.Patient_Payment / RuTemp.Patient_Balance end as WeeklyPatPayRate
--			,RuTemp.CoPay_Due + RuTemp.Patient_Balance as WeeklyOpportunity
--			,rutemp.CoPay_Collected + rutemp.Patient_Payment as WeeklyTotalPayments
--			,case when RuTemp.CoPay_Due + RuTemp.Patient_Balance = 0  then 0 else (rutemp.CoPay_Collected + rutemp.Patient_Payment ) / (RuTemp.CoPay_Due + RuTemp.Patient_Balance) end as WeeklySuccessRate
			
--		from
--			(
--			select 
--				temp9.Company
--				,temp9.Division
--				,temp9.section
--				,temp9.Department_ID
--				,temp9.Department_Name
--				,DATE_DIMENSION.WEEK_NUMBER
--				,date_dimension.WEEK_BEGIN_DT
--				,date_dimension.WEEK_ENDING_DT
--				,sum(temp9.Patient_Balance) as Patient_Balance
--				,sum(temp9.Patient_Payment) as Patient_Payment
--				,sum(temp9.CoPay_Due) as CoPay_Due
--				,sum(temp9.CoPay_Collected) as CoPay_Collected
--				from
--				(
		 ---------------------------------------------------------------------------comment out everything above for detail reporting---------------------------------------------------------------------------
				select 
						'StE' as Company
						,coalesce(cteCopay.Division, ctePayment.DIVISION) as Division
						,coalesce(ctecopay.section, ctepayment.section) as section
						,coalesce(cteCopay.DEPARTMENT_ID, ctePayment.DEPARTMENT_ID) as Department_ID
						,coalesce(cteCopay.DEPARTMENT_NAME, ctePayment.DEPARTMENT_NAME) as Department_Name
						,coalesce(cteCopay.ACCOUNT_ID, ctePayment.ACCOUNT_ID) as Account_ID
						,coalesce(cteCopay.ACCOUNT_NAME, ctePayment.ACCOUNT_NAME) as Account_Name
						,coalesce(cteCopay.CONTACT_DATE, ctePayment.POST_DATE) as Contact_Date
						,coalesce( cteCopay.Patient_Balance, ctePayment.patient_balance) as Patient_Balance
						,coalesce(ctePayment.patient_payment,0) as Patient_Payment
						,coalesce(cteCopay.Copay_Due,0) as CoPay_Due
						,coalesce(cteCopay.Copay_Collected,0) as CoPay_Collected

						,COUNT(pat_name) over (partition by coalesce(cteCopay.DEPARTMENT_ID, ctePayment.DEPARTMENT_ID) ,coalesce(cteCopay.ACCOUNT_ID, ctePayment.ACCOUNT_ID), coalesce(cteCopay.CONTACT_DATE, ctePayment.POST_DATE)) as patcount
						,rank() over (partition by coalesce(cteCopay.DEPARTMENT_ID, ctePayment.DEPARTMENT_ID) ,coalesce(cteCopay.ACCOUNT_ID, ctePayment.ACCOUNT_ID), coalesce(cteCopay.CONTACT_DATE, ctePayment.POST_DATE) order by pat_name) as patorder
						,cteCopay.PAT_NAME
						,cteCopay.PAT_MRN_ID
						,cteCopay.BIRTH_DATE
				from
						cteCopay
						full outer join ctePayment on ctePayment.ACCOUNT_ID = cteCopay.ACCOUNT_ID and ctePayment.DEPARTMENT_ID = cteCopay.DEPARTMENT_ID	and cteCopay.CONTACT_DATE = ctePayment.POST_DATE 
		-----------------------------------------------------------------------------comment out everything below for detail reporting-------------------------------------------------------------------------
--				) as temp9	
--				Left join date_dimension on DATE_DIMENSION.CALENDAR_DT = temp9.Contact_Date
--			group by rollup
--				(
--				(DATE_DIMENSION.WEEK_NUMBER,date_dimension.WEEK_BEGIN_DT,date_dimension.WEEK_ENDING_DT)
--				,temp9.Company
--				,temp9.Division
--				,temp9.section
--				,(temp9.Department_ID,temp9.Department_Name)
--				)
--			) as RuTemp

--		Where 
--				RuTemp.company is not null

--		) as YearRollUp


--where 
--		YearRollUp.GroupByColumn <> ' No Dept/Sect'

--) as calc


