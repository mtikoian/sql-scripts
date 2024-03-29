SELECT   '' AS LEVEL_5_CODE
        ,'' AS LEVEL_5_NAME
        ,'1' AS LEVEL_4_CODE
        ,UPPER('Faculty Group Practice Excluding Austin') AS LEVEL_4_NAME
        ,NVL(FDIV.FIN_DIV_ID,10) AS LEVEL_3_CODE
        ,NVL(REPLACE(UPPER(SUBSTR( FDIV.FIN_DIV_NM, 1, 50)), ' DIVISION', ''),'FACULTY GROUP PRACTICE') AS LEVEL_3_NAME
        ,NVL(SDIV.FIN_SUBDIV_ID,620004329)  AS LEVEL_2_CODE
        ,NVL(REPLACE(UPPER(SUBSTR( SDIV.FIN_SUBDIV_NM, 1, 50)), ' SUBDIVISION', ''), 'FACULTY GROUP PRACTICE')  AS LEVEL_2_NAME
        ,BILL.BILL_AREA_ID AS LEVEL_1_CODE
        ,UPPER(SUBSTR( BILL.RECORD_NAME, 1, 50)) AS LEVEL_1_NAME

FROM     CLARITY.BILL_AREA  BILL
         LEFT JOIN CLARITY.FIN_SUBDIV SDIV ON BILL.FIN_SUBDIV_ID = SDIV.FIN_SUBDIV_ID
         LEFT JOIN CLARITY.FIN_DIV FDIV ON BILL.FIN_DIV_ID = FDIV.FIN_DIV_ID
         
ORDER BY LEVEL_3_NAME ASC, LEVEL_2_NAME ASC, LEVEL_1_NAME ASC  