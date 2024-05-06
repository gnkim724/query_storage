/* stmt.findListHqShopSttmtList : 점별거래부 조회 */
SELECT STK.BRAND_CD
     , SHOP.SHOP_CD
     , SHOP.SHOP_ABBR_NM
     , SHOP.CUS_DE                                                             AS 폐점일자
     , RAT.SPY_PRC_RAT                                                         AS 공급가율
     , SUM( STK.REAL_STK_QTY )                                                 AS STK_QTY_재고수량
     , SUM( STK.REAL_NOR_TOT_GI_SPY_AMT ) - SUM( STK.REAL_RTN_TOT_GI_SPY_AMT ) AS SPY_AMT_공금금액
     , SUM( STK.REAL_STK_QTY * PROD.SALE_PRC )                                 AS STK_AMT_택가
     , SUM( STK.STK_QTY )                                                      AS STK_QTY_재고수량_마감
     , SUM( STK.NOR_TOT_GI_SPY_AMT ) - SUM( STK.RTN_TOT_GI_SPY_AMT )           AS SPY_AMT_공금금액_마감
     , SUM( STK.STK_QTY * PROD.SALE_PRC )                                      AS STK_AMT_택가_마감
  FROM (SELECT BRAND_CD
             , SHOP_CD
             , SSN_CD
             , PROD_CD
             , COLOR_CD
             , SIZ_CD
             , NVL( STK_QTY, 0 )                                           AS STK_QTY
             , NVL( RTN_TOT_GI_SPY_AMT, 0 )                                AS RTN_TOT_GI_SPY_AMT
             , NVL( NOR_TOT_GI_SPY_AMT, 0 )                                AS NOR_TOT_GI_SPY_AMT
             , NVL( NOR_TOT_GI_QTY, 0 )
                   - NVL( NOR_ADJ_GI_QTY, 0 )
                   - NVL( RTN_TOT_GI_QTY, 0 )
                   + NVL( RTN_ADJ_GI_QTY, 0 )
                   - NVL( NOR_SALE_QTY, 0 )
          + NVL( RTN_SALE_QTY, 0 )                                         AS REAL_STK_QTY
             , NVL( RTN_TOT_GI_SPY_AMT, 0 ) - NVL( RTN_ADJ_GI_SPY_AMT, 0 ) AS REAL_RTN_TOT_GI_SPY_AMT
             , NVL( NOR_TOT_GI_SPY_AMT, 0 ) - NVL( NOR_ADJ_GI_SPY_AMT, 0 ) AS REAL_NOR_TOT_GI_SPY_AMT
          FROM BIM_SHOP_ACCM_STK
         WHERE BRAND_CD = 'X'
           AND SSN_CD IN ('23S')
           AND SHOP_CD IN ('10004')
           AND STD_DE <=
               TO_CHAR( TO_DATE( '2024-05-06', 'YYYY-MM-DD' ) - 1
                   , 'YYYY-MM-DD' )
           AND TO_STD_DE >=
               TO_CHAR( TO_DATE( '2024-05-06', 'YYYY-MM-DD' ) - 1
                   , 'YYYY-MM-DD' )
         UNION ALL
        SELECT BRAND_CD
             , SHOP_CD
             , SSN_CD
             , PROD_CD
             , COLOR_CD
             , SIZ_CD
             , NVL( NOR_TOT_GI_QTY, 0 )
                   - NVL( RTN_TOT_GI_QTY, 0 )
                   - NVL( NOR_SALE_QTY, 0 )
            + NVL( RTN_SALE_QTY, 0 )                                       AS STK_QTY
             , NVL( RTN_TOT_GI_SPY_AMT, 0 )                                AS RTN_TOT_GI_SPY_AMT
             , NVL( NOR_TOT_GI_SPY_AMT, 0 )                                AS NOR_TOT_GI_SPY_AMT
             , NVL( NOR_TOT_GI_QTY, 0 )
                   - NVL( NOR_ADJ_GI_QTY, 0 )
                   - NVL( RTN_TOT_GI_QTY, 0 )
                   + NVL( RTN_ADJ_GI_QTY, 0 )
                   - NVL( NOR_SALE_QTY, 0 )
            + NVL( RTN_SALE_QTY, 0 )                                       AS REAL_STK_QTY
             , NVL( RTN_TOT_GI_SPY_AMT, 0 ) - NVL( RTN_ADJ_GI_SPY_AMT, 0 ) AS REAL_RTN_TOT_GI_SPY_AMT
             , NVL( NOR_TOT_GI_SPY_AMT, 0 ) - NVL( NOR_ADJ_GI_SPY_AMT, 0 ) AS REAL_NOR_TOT_GI_SPY_AMT
          FROM BIM_SHOP_DD_STK
         WHERE BRAND_CD = 'X'
           AND STD_DE = '2024-05-06'
           AND SSN_CD IN ('23S')
           AND SHOP_CD IN ('10004')) STK
           INNER JOIN VIEW_PROD_INFO PROD
                      ON STK.BRAND_CD = PROD.BRAND_CD
                          AND STK.SSN_CD = PROD.SSN_CD
                          AND STK.PROD_CD = PROD.PROD_CD
           INNER JOIN BIM_SHOP SHOP
                      ON STK.BRAND_CD = SHOP.BRAND_CD
                          AND STK.SHOP_CD = SHOP.SHOP_CD
           LEFT OUTER JOIN BIM_SHOP_SPY_PRC_RAT RAT
                           ON SHOP.BRAND_CD = RAT.BRAND_CD
                               AND SHOP.SHOP_CD = RAT.SHOP_CD
                               AND RAT.SALE_TYP_CD = '1'
                               AND RAT.STA_DE <= '2024-05-06'
                               AND RAT.END_DE >= '2024-05-06'
 WHERE STK.BRAND_CD = 'X'
   AND STK.SSN_CD IN ('23S')
   AND STK.SHOP_CD IN ('10004')
 GROUP BY STK.BRAND_CD
        , SHOP.SHOP_CD
        , SHOP.SHOP_ABBR_NM
        , SHOP.CUS_DE
        , RAT.SPY_PRC_RAT
 ORDER BY STK.BRAND_CD, SHOP.SHOP_CD;