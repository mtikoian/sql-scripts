DECLARE 
              @Table VARCHAR(40)        
SET 
              @Table='RECONCILE_CLM_STAT' --<<--Type your table name here

SELECT
              CLARITY_TBL.TABLE_NAME
              ,CLARITY_TBL_COLS.LINE                                               as Column_Number
              ,CLARITY_TBL.IS_EXTRACTED_YN
              ,CLARITY_TBL.DEPRECATED_YN
              ,CLARITY_TBL.LOAD_FREQUENCY
              ,CLARITY_COL.COLUMN_NAME
              ,CLARITY_COL_INIITM.COLUMN_INI                                as INI
              ,CLARITY_COL_INIITM.COLUMN_ITEM                               as Item 
              ,CLARITY_COL.DATA_TYPE
              ,Clarity_col.CLARITY_PRECISION
              ,clarity_col.CLARITY_SCALE
              ,Clarity_col.HOUR_FORMAT
              ,CLARITY_COL.DESCRIPTION                                      as Description_Name
FROM 
              clarity.dbo.CLARITY_TBL
              INNER JOIN clarity.dbo.CLARITY_TBL_COLS ON CLARITY_TBL.TABLE_ID = CLARITY_TBL_COLS.TABLE_ID
              INNER JOIN clarity.dbo.CLARITY_COL ON CLARITY_TBL_COLS.COLUMN_ID = CLARITY_COL.COLUMN_ID
              LEFT JOIN clarity.dbo.CLARITY_COL_INIITM ON CLARITY_COL.COLUMN_ID = CLARITY_COL_INIITM.COLUMN_ID 
                           AND CLARITY_COL_INIITM.LINE=1   
WHERE
              LEFT(CLARITY_TBL.TABLE_ID,1) = 'C'  --> Custom tables
              AND Clarity_tbl.TABLE_NAME = @Table
ORDER BY
              CLARITY_TBL.TABLE_NAME
              ,CLARITY_TBL_COLS.LINE

