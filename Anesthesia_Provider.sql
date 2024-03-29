SELECT 
	 tdl.TX_ID
	 ,DOC_PROV_ID -- same as PERFORMING_PROV_ID
	 ,dp.POST_DATE
FROM
	CLARITY_TDL_TRAN tdl
	LEFT JOIN DOC_PROVIDER dp on tdl.TX_ID = dp.TX_ID
WHERE 
	TYPE_OF_SERVICE = '7'
	and
	DETAIL_TYPE in ('1','10')
	and dp.POST_DATE between '06/01/2014' and '06/30/2014'