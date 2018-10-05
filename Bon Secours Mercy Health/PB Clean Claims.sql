DECLARE 
	  @startDate DATE
	, @endDate DATE;

SET @startDate='7/01/2018';
SET @endDate='7/4/2018';

/*
 * Get a list of primary claims processed within a specific date range, and determine the appropriate
 * factors for calculating a clean claims rate.
 *
 * Question: If a claim was originally clean (no errors and accepted), but is later resubmitted, should
 *           it move from clean to dirty? This would likely require joining to another copy of CLARITY_TDL_TRAN,
 *           which would negatively impact performance.
 */ 

SELECT
	  inv.ACCOUNT_ID
	, invInfo.INV_ID
	, invInfo.INV_NUM
	, MAX(invHx.HX_DATETIME) PROCESS_DT
	, MAX
		(CASE								
		 WHEN invInfo.CLM_ACCEPT_DT IS NULL THEN 0
		 ELSE 1
		END) IS_ACCEPTED					-- Is this claim accepted in Epic? (If not, we don't know that it's clean.)
    , MAX
		(CASE								
		 WHEN errHx.INVOICE_ID IS NULL THEN 0
		 ELSE 1
		END) HAD_ERROR						-- Did this claim ever have an error?

FROM  INVOICE_HX invHx
  INNER JOIN INV_BASIC_INFO invInfo ON (invHx.INVOICE_ID = invInfo.INV_ID AND invHx.INV_NUM_100_GRP_LN = invInfo.LINE)
  INNER JOIN INVOICE inv ON (inv.INVOICE_ID = invHx.INVOICE_ID)
  LEFT OUTER JOIN RECONCILE_CLM clmRec ON (clmRec.CLAIM_REC_ID = invInfo.CRD_ID)
  LEFT OUTER JOIN PAT_CVG_FILE_ORDER cvgFo ON (inv.PAT_ID = cvgFo.PAT_ID AND invInfo.CVG_ID = cvgFo.COVERAGE_ID)
  LEFT OUTER JOIN TX_INVOICES inv_tx ON (inv_tx.INVOICE_ID = invInfo.INV_ID AND inv_tx.INVOICE_NUM = invInfo.INV_NUM)
  LEFT OUTER JOIN CLARITY_TDL_TRAN t1 ON (t1.TX_ID = inv_tx.TX_ID AND t1.DETAIL_TYPE = 50 AND t1.INVOICE_NUMBER = invInfo.INV_NUM)
  LEFT OUTER JOIN INVOICE_HX errHx ON (invHx.INVOICE_ID = errHx.INVOICE_ID AND invHx.INV_NUM_100_GRP_LN = errHx.INV_NUM_100_GRP_LN AND errHx.ACTIVITY_C = 3)

WHERE     (invHx.ACTIVITY_C = 1 AND invHx.HX_DATETIME BETWEEN @startDate AND @endDate)                                                 -- Claim was processed within the date range
		AND
		  (invInfo.FILING_ORDER_C = 1 OR clmRec.FILING_ORDER_C = 1 OR t1.ORIGINAL_CVG_ID = invInfo.CVG_ID OR cvgFo.FILING_ORDER = 1)   -- Claim is primary. We can remove the CRD (RECONCILE_CLM) check
		AND																															   --    for organizations that went live after the 2014 release.
		  (invInfo.LINE = 1 OR RIGHT(t1.TDL_ID,1) = 1)                                                                                 -- Claim is not the product of a resubmit action

GROUP BY inv.ACCOUNT_ID, invInfo.INV_ID, invInfo.INV_NUM
