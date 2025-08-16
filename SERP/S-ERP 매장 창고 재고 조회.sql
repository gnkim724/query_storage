/* stockFlow.findListShopWhStkForTr : 매장 창고 재고 조회 */

  SELECT A.BRAND_CD
       , A.SSN_CD
       , A.PROD_LLS_NM
       , A.PROD_MLS_NM
       , A.ITM_NM
       , A.PROD_CD
       , A.PROD_NM
       , A.COLOR_CD
       , A.SIZ_CD
       , A.SHOP_CD
       , A.WH_CD
       , 'I-90007-200'            AS TO_WH_CD
       , NVL ((SELECT TOT_STK_QTY
                 FROM VIEW_SHOP_STK_INFO
                WHERE BRAND_CD = A.BRAND_CD
                  AND SSN_CD = A.SSN_CD
                  AND PROD_CD = A.PROD_CD
                  AND COLOR_CD = A.COLOR_CD
                  AND SIZ_CD = A.SIZ_CD
                  AND SHOP_CD = A.SHOP_CD
                  AND WH_CD = 'I-90007-200')
            , 0)                  AS TO_STK_QTY
       , A.TOT_STK_QTY            AS STK_QTY
       , 0                        AS TR_QTY
       , (SELECT SORT
            FROM BIM_SSN
           WHERE SSN_CD = A.SSN_CD
             AND USE_YN = 'Y')    AS SSN_SORT
       , (SELECT SORT_ORD
            FROM ESACDDT Z
           WHERE Z.GRP_CD = 'SIZE_SORT'
             AND Z.DTL_CD = A.SIZ_CD
             AND Z.USE_YN = 'Y'
             AND Z.STS != 'D')    AS SIZE_SORT
    FROM VIEW_SHOP_STK_INFO A
   WHERE A.BRAND_CD = 'I'
     AND A.SSN_CD IN ('24S')
     AND A.SHOP_CD = '90007'
     AND A.PROD_CD IN ('7AS1V0443')
     AND UPPER (A.COLOR_CD) LIKE UPPER ('%50NYS%')
     AND UPPER (A.SIZ_CD) LIKE UPPER ('%145%')
     AND A.WH_CD IN ('I-90007-400')
ORDER BY SSN_SORT
       , A.PROD_CD
       , A.COLOR_CD
       , SIZE_SORT
       , LPAD (A.SIZ_CD, 3, 0)
       , A.WH_CD;