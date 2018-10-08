SELECT epm.PAYOR_ID
      ,epm.PAYOR_NAME
      ,epp.RPT_GRP_ONE
      ,epp.RPT_GRP_TWO
      ,epm.FINANCIAL_CLASS
      ,epm.PRODUCT_TYPE
      ,epm.ADDR_LINE_1
      ,epm.ADDR_LINE_2
      ,epm.CITY
      ,epm.STATE_C
      ,epm.COUNTY_C
      ,epm.ZIP_CODE
      ,epm.PHONE
FROM 
	CLARITY_EPM epm
	LEFT JOIN CLARITY_EPP epp on epm.PAYOR_ID = epp.PAYOR_ID
WHERE epp.RPT_GRP_ONE is not null
GROUP BY
	   epm.PAYOR_ID
      ,epm.PAYOR_NAME
      ,epp.RPT_GRP_ONE
      ,epp.RPT_GRP_TWO
      ,epm.FINANCIAL_CLASS
      ,epm.PRODUCT_TYPE
      ,epm.ADDR_LINE_1
      ,epm.ADDR_LINE_2
      ,epm.CITY
      ,epm.STATE_C
      ,epm.COUNTY_C
      ,epm.ZIP_CODE
      ,epm.PHONE
