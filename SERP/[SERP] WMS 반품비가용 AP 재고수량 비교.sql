/*
 * WMS, ERP 반품비가용 AP 재고 수량 비교
 */

SELECT *
  FROM (SELECT NVL (X.BRAND_CD, Y.BRAND_CD)     AS BRAND_CD
             , NVL (X.SSN_CD, Y.SSN_CD)         AS SSN_CD
             , NVL (X.PROD_CD, Y.PROD_CD)       AS PROD_CD
             , NVL (X.COLOR_CD, Y.COLOR_CD)     AS COLOR_CD
             , NVL (X.SIZ_CD, Y.SIZ_CD)         AS SIZ_CD
             , X.STK_QTY                        AS WMS_QTY
             , Y.STK_QTY                        AS ERP_QTY
             , X.RTN_QTY                        AS WMS_RTN
             , Y.RTN_QTY                        AS ERP_RTN
          FROM (  SELECT BRAND_CD
                       , SSN_CD
                       , PROD_CD
                       , COLOR_CD
                       , SIZ_CD
                       , SUM (STK_QTY)     AS STK_QTY
                       , SUM (RTN_QTY)     AS RTN_QTY
                    FROM SERP_IF.IF_WMS_STOCK_RCV
                   WHERE 1 = 1
                     AND TO_CHAR (EAI_DATE, 'YYYY-MM-DD') = '2024-05-17'
                     --AND PROD_CD = 'DKBK1104N'
                     --AND COLOR_CD  = 'BES'
                     --AND SIZ_CD  = 'F'
                     AND BRAND_CD = 'X'
                     AND SSN_CD LIKE '23%'
                GROUP BY BRAND_CD, SSN_CD, PROD_CD, COLOR_CD, SIZ_CD) X
               FULL OUTER JOIN
               (  SELECT BRAND_CD
                       , SSN_CD
                       , PROD_CD
                       , COLOR_CD
                       , SIZ_CD
                       , SUM (
                             CASE
                                 WHEN AP_CD IN ('S300', 'S999') THEN 0
                                 ELSE STK_QTY
                             END)    AS STK_QTY
                       , SUM (
                             CASE
                                 WHEN AP_CD IN ('S200T') THEN STK_QTY
                                 ELSE 0
                             END)    AS RTN_QTY
                    FROM SERP_IF.IF_WMS_STOCK_SND
                   WHERE 1 = 1
                     AND TO_CHAR (DATA_INPUT_DATE, 'YYYY-MM-DD') = '2024-05-17'
                     AND BRAND_CD = 'X'
                     AND SSN_CD LIKE '23%'
                GROUP BY BRAND_CD, SSN_CD, PROD_CD, COLOR_CD, SIZ_CD) Y
                   ON X.BRAND_CD = Y.BRAND_CD
                  AND X.SSN_CD = Y.SSN_CD
                  AND X.PROD_CD = Y.PROD_CD
                  AND X.COLOR_CD = Y.COLOR_CD
                  AND X.SIZ_CD = Y.SIZ_CD)
 WHERE 1 = 1
   AND (WMS_QTY != ERP_QTY
     OR WMS_RTN != ERP_RTN);
