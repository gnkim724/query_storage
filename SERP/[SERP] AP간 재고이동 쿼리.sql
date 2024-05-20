/*
 * AP간 재고 이동 쿼리
 */

INSERT INTO BIM_STK_PROC (STK_PROC_SNO
                        , PROC_DIV_CD
                        , PROC_DE
                        , BRAND_CD
                        , SSN_CD
                        , PROD_CD
                        , COLOR_CD
                        , SIZ_CD
                        , FROM_SYS_CD
                        , FROM_AP_WH_CD
                        , TO_SYS_CD
                        , TO_AP_WH_CD
                        , MARK_CD
                        , QTY
                        , INSR_ID)
    SELECT SEQ_BIM_STK_PROC.NEXTVAL
         , 'TC'           AS PROC_DIV_CD
         , TO_CHAR (SYSDATE, 'YYYY-MM-DD')
         , BRAND_CD
         , SSN_CD
         , PROD_CD
         , COLOR_CD
         , SIZ_CD
         , 'HQ'           AS FROM_SYS_CD
         , 'S200T'        AS FROM_AP_WH_CD
         , 'HQ'           AS TO_SYS_CD
         , 'S200'         AS TO_AP_WH_CD
         , '+'            AS MARK_CD
         , 2              AS QTY
         , 'GNKIM724'     AS INSR_ID
      FROM BIM_PROD_COLOR_SIZ
     WHERE BRAND_CD = 'X'
       AND SIZ_CD LIKE '95' AND COLOR_CD LIKE 'BKS' AND PROD_CD LIKE 'DMTS51033'
;

COMMIT;

INSERT INTO BIM_STK_PROC (STK_PROC_SNO
                        , PROC_DIV_CD
                        , PROC_DE
                        , BRAND_CD
                        , SSN_CD
                        , PROD_CD
                        , COLOR_CD
                        , SIZ_CD
                        , FROM_SYS_CD
                        , FROM_AP_WH_CD
                        , TO_SYS_CD
                        , TO_AP_WH_CD
                        , MARK_CD
                        , QTY
                        , INSR_ID)
    SELECT SEQ_BIM_STK_PROC.NEXTVAL
         , 'TC'           AS PROC_DIV_CD
         , TO_CHAR (SYSDATE, 'YYYY-MM-DD')
         , BRAND_CD
         , SSN_CD
         , PROD_CD
         , COLOR_CD
         , SIZ_CD
         , 'HQ'           AS FROM_SYS_CD
         , 'S200'         AS FROM_AP_WH_CD
         , 'HQ'           AS TO_SYS_CD
         , 'U110'         AS TO_AP_WH_CD
         , '+'            AS MARK_CD
         , 3             AS QTY
         , 'GNKIM724'     AS INSR_ID
      FROM BIM_PROD_COLOR_SIZ
     WHERE BRAND_CD = 'X'
       AND SIZ_CD LIKE '100' AND COLOR_CD LIKE 'BKS' AND PROD_CD LIKE 'DWOP91033'
;


COMMIT;


