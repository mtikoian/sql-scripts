USE [ClarityCHPUtil]
GO

/****** Object:  View [dbo].[V_CHP_CUBE_D_PB_TRANSACTION]    Script Date: 1/30/2016 8:31:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[V_CHP_CUBE_D_PB_TRANSACTION]
(
 [TRANSACTION_ID]
,[TRANSACTION_TYPE]
,[CHARGE_SOURCE]
,[PROCEDURE_CODE]
,[PAYMENT_SOURCE]
,[TRANSACTION_NUMBER]
,[TYPE_OF_SERVICE]
,[MODIFIER_ONE]
,[MODIFIER_TWO]
,[MODIFIER_THREE]
,[MODIFIER_FOUR]
,[POSTING_BATCH_NUM]
)
AS
/*Copyright (C) 2011-2014 Epic Systems Corporation
********************************************************************************
TITLE:   V_CUBE_D_PB_TRANSACTION
PURPOSE: This view contains information on PB Transactions and is used to build the PB Transaction dimension of the PB Cube.
AUTHOR:  Ravi Shrivastava
PROPERTIES: P_START_YEAR (NUMBER) - All transactions taking place within and after the entered year will be included in the view.
REVISION HISTORY: 
*RS 07/12 DLG#242404 - created
*JPM 06/13 DLG#274905 - force PROCEDURE_CODE to upper case
*rsh 11/13 DLG#I8104953 - add modifiers and posting batch number
********************************************************************************
*/
SELECT
   arpb.[tx_id]
  ,tx_type.[NAME]
  ,coalesce(zc_chg.[NAME],'Professional Billing')
  ,upper(arpb.[CPT_CODE])
  ,coalesce(paysrc.[name],'Unspecified Payment Source')
  ,moderate.[tx_num_in_acct]
  ,coalesce(tos.[NAME],'Unspecified Type of Service')
  ,coalesce(arpb.MODIFIER_ONE,' ')
  ,coalesce(arpb.MODIFIER_TWO,' ')
  ,coalesce(arpb.MODIFIER_THREE,' ')
  ,coalesce(arpb.MODIFIER_FOUR,' ')
  ,moderate.POST_BATCH_NUM
FROM [CLARITY]..[ARPB_TRANSACTIONS] arpb
INNER JOIN (SELECT DISTINCT TX_ID from [CLARITY]..CLARITY_TDL_TRAN where POST_DATE >='2015-01-01' and serv_area_id in (304,609)) tdl on tdl.tx_id=arpb.tx_id
LEFT OUTER JOIN [CLARITY]..[ZC_TRAN_TYPE] tx_type on tx_type.tran_type=arpb.tx_type_c
left outer join [CLARITY]..[CLARITY_UCL] ucl on arpb.CHG_ROUTER_SRC_ID = ucl.UCL_ID
left outer join [CLARITY]..[ARPB_TX_MODERATE] moderate on arpb.TX_ID = moderate.TX_ID
left outer join [CLARITY]..[ZC_CHG_SOURCE_UCL] zc_chg on zc_chg.CHG_SOURCE_UCL_C=ucl.charge_source_c
left outer join [CLARITY]..[ZC_PAYMENT_SOURCE] paysrc on arpb.payment_source_c=paysrc.payment_source_c
left outer join [CLARITY]..[ZC_TYPE_OF_SERVICE] tos on moderate.type_of_service_c=tos.type_of_service_c


GO


