/*stockFlow.findListCtbBrkBuy: 수금내역서(상설사입) 목록 조회*/

SELECT A.BRAND_CD                                                   -- 브랜드코드
     , A.SO_NM                                                      -- 점주명
     , A.REP_NM                                                     -- 대표자명
     , A.SHOP_CD                                                    -- 매장코드
     , A.SHOP_NM                                                    -- 매장명
     , A.SHOP_SCRT_AMT                                              -- 담보총액
     , A.SALE_BAL                                                   -- 현 미수잔액
     , CASE
           WHEN A.SALE_BAL - A.SHOP_SCRT_AMT >= 0
               THEN
               A.SALE_BAL - A.SHOP_SCRT_AMT
               ELSE
               0
       END                                          AS LOAN_OVR_AMT -- 현 여신 초과액(현미수잔액 - 담보총액)
     , B.STD_YYMM                                                   -- 년월
     , B.TAG_AMT                                                    -- TAG가
     , B.PRE_REVAMT                                                 -- 예상수금액
     , B.SUPPLIES_AMT                                               -- 저장품
     , B.REPAIR_AMT                                                 -- 수선비
     , B.PRE_REVAMT + B.SUPPLIES_AMT + B.REPAIR_AMT AS PRE_INWARD   -- 입금예정액
     , B.INWARD_AMT                                 AS INWARD_AMT   -- 월입금액(마감확정, SAP I/F)
     , '조회'                                         AS DEP          -- 입금내역
  FROM ( /* 매장정보 (오너, 사업자명, 담보총액, 담당자) */
      SELECT A.BRAND_CD
           , A.SHOP_CD
           , B.SHOP_ABBR_NM AS SHOP_NM
           , C.SO_NM
           , B.REP_NM
           , A.SHOP_SCRT_AMT
           , A.SALE_BAL
           , D.EMP_NM
           , B.SHOP_TRD_TYP_CD
           , B.SHOP_MGMT_TYP_CD
           , B.PROD_TRD_TYP_CD
           , B.SHOP_CTRT_TYP_CD
        FROM BIM_SHOP_LOAN A
           , BIM_SHOP B
           , BIM_SHOP_SO C
           , (SELECT BRAND_CD
                   , SHOP_CD
                   , USER_ID
                   , FC_GET_NAME( 'USER'
                , USER_ID
                , 'FNF'
                , 'ko_KR'
                , 'C007'
                , ''
                , ''
                , ''
                , ''
                , '' ) AS EMP_NM
                FROM BIM_SHOP_SALES_PIC
               WHERE USE_YN = 'Y'
                 AND TO_CHAR( SYSDATE, 'YYYY-MM-DD' ) BETWEEN STA_DE
                   AND END_DE) D
       WHERE A.BRAND_CD = B.BRAND_CD
         AND A.SHOP_CD = B.SHOP_CD
         AND A.SO_ID = C.SO_ID(+)
         AND A.BRAND_CD = D.BRAND_CD(+)
         AND A.SHOP_CD = D.SHOP_CD(+)) A
     , (SELECT TA.BRAND_CD
             , TA.SHOP_CD
             , TA.STD_YYMM
             , NVL( TA.TAG_AMT, 0 )             AS TAG_AMT      -- TAG가
             , NVL( GI.GI_AMT - GI.RTN_AMT, 0 ) AS PRE_REVAMT   -- 예상수금액(출고-반품)
             , NVL( GI.SUPPLIES_AMT, 0 )        AS SUPPLIES_AMT -- 저장품
             , NVL( RP.REPAIR_AMT, 0 )          AS REPAIR_AMT   -- 수선비
             , NVL( IW.INWARD_AMT, 0 )          AS INWARD_AMT   -- 입금액
          FROM ( /* TAG가 */
              SELECT A.BRAND_CD
                   , A.SHOP_CD
                   , A.STD_YYMM
                   , SUM( A.NOR_GI_QTY * B.SALE_PRC )
                  - SUM( A.RTN_GI_QTY * B.SALE_PRC ) AS TAG_AMT
                FROM BIM_SHOP_MM_STK A
                   , BIM_PROD B
               WHERE A.BRAND_CD = B.BRAND_CD
                 AND A.SSN_CD = B.SSN_CD
                 AND A.PROD_CD = B.PROD_CD
                 AND A.SSN_CD != 'X'
                 AND A.STD_YYMM BETWEEN '2024-04' AND '2024-05'
               GROUP BY A.BRAND_CD, A.SHOP_CD, A.STD_YYMM) TA
             , ( /* 예상수금액 (출고금액(VAT포함)-반품) , 저장품 */
              SELECT A.BRAND_CD
                   , A.STD_SHOP_CD           AS SHOP_CD
                   , SUBSTR( A.GI_DE, 1, 7 ) AS STD_YYMM
                   , NVL( SUM( CASE
                                   WHEN A.GI_TYP_CD <= '500'
                                       AND C.PROD_DIV_CD IN ('1', '3')
                                       THEN
                                       NVL( B.GI_AMT, 0 ) + NVL( B.VAT, 0 )
                                       ELSE
                                       0
                               END )
                  , 0 )                      AS GI_AMT
                   , NVL( SUM( CASE
                                   WHEN A.GI_TYP_CD <= '500'
                                       AND C.PROD_DIV_CD IN ('1', '3')
                                       THEN
                                       0
                                       ELSE
                                       NVL( B.GI_AMT, 0 ) + NVL( B.VAT, 0 )
                               END )
                  , 0 )                      AS RTN_AMT
                   , NVL( SUM( CASE
                                   WHEN A.GI_TYP_CD <= '500'
                                       AND C.PROD_DIV_CD IN ('5')
                                       THEN
                                       NVL( B.GI_AMT, 0 ) + NVL( B.VAT, 0 )
                                       ELSE
                                       0
                               END )
                         , 0 )
                  - NVL(
                             SUM(
                                     CASE
                                         WHEN A.GI_TYP_CD > '500'
                                             AND C.PROD_DIV_CD IN ('5')
                                             THEN
                                             (NVL( B.GI_AMT, 0 ) + NVL( B.VAT, 0 ))
                                             ELSE
                                             0
                                     END )
                         , 0 )               AS SUPPLIES_AMT
                FROM BIM_TRD_STTMT A
                   , BIM_TRD_STTMT_DTL B
                   , BIM_PROD C
               WHERE A.BRAND_CD = B.BRAND_CD
                 AND A.ORD_NO = B.ORD_NO
                 AND B.BRAND_CD = C.BRAND_CD
                 AND B.SSN_CD = C.SSN_CD
                 AND B.PROD_CD = C.PROD_CD
                 AND A.GI_STS_CD = 'C'
                 AND SUBSTR( A.GI_DE, 1, 7 ) BETWEEN '2024-04' AND '2024-05'
               GROUP BY A.BRAND_CD, A.STD_SHOP_CD, SUBSTR( A.GI_DE, 1, 7 )) GI
             , ( /* 수선비 */
              SELECT A.BRAND_CD
                   , A.SHOP_CD
                   , SUBSTR( B.BILL_ISS_DE, 1, 7 ) AS STD_YYMM
                   , SUM( RPR_AMT * 1.1 )          AS REPAIR_AMT
                FROM BIM_RPR A
                   , BIM_RPR_BILL B
               WHERE A.RPR_RCPTN_NO = B.RPR_RCPTN_NO
                 AND B.BILL_ISS_YN = 'Y'
                 AND SUBSTR( B.BILL_ISS_DE, 1, 7 ) BETWEEN '2024-04'
                   AND '2024-05'
               GROUP BY A.BRAND_CD, A.SHOP_CD, SUBSTR( B.BILL_ISS_DE, 1, 7 )) RP
             , ( /* 매장입금액 */
              SELECT BRAND_CD
                   , SHOP_CD
                   , SUBSTR( DPST_DE, 1, 7 )                             AS STD_YYMM
                   , SUM( CASH_DPST_AMT + ETC_DPST_AMT + MILE_DPST_AMT ) AS INWARD_AMT
                FROM BIM_SHOP_BOND_PMT
               WHERE SUBSTR( DPST_DE, 1, 7 ) BETWEEN '2024-04' AND '2024-05'
               GROUP BY BRAND_CD, SHOP_CD, SUBSTR( DPST_DE, 1, 7 )) IW
         WHERE 1 = 1
           AND TA.BRAND_CD = GI.BRAND_CD(+)
           AND TA.SHOP_CD = GI.SHOP_CD(+)
           AND TA.STD_YYMM = GI.STD_YYMM(+)
           AND TA.BRAND_CD = RP.BRAND_CD(+)
           AND TA.SHOP_CD = RP.SHOP_CD(+)
           AND TA.STD_YYMM = RP.STD_YYMM(+)
           AND TA.BRAND_CD = IW.BRAND_CD(+)
           AND TA.SHOP_CD = IW.SHOP_CD(+)
           AND TA.STD_YYMM = IW.STD_YYMM(+)) B
 WHERE 1 = 1
   AND A.BRAND_CD = B.BRAND_CD
   AND A.SHOP_CD = B.SHOP_CD
   AND A.BRAND_CD = 'M'
   AND A.SHOP_CD IN (SELECT '791' FROM DUAL) -- 매장 조회 시
   AND A.SHOP_TRD_TYP_CD = 'A'
   AND A.SHOP_MGMT_TYP_CD = 'W'
   AND A.PROD_TRD_TYP_CD = 'B'
   AND A.SHOP_CTRT_TYP_CD = 'B'
 ORDER BY A.SHOP_CD, B.STD_YYMM DESC;


-- SAP 매장채권 반제 수신
CALL PRC_IF_SAP_SHOP_BOND_PMT_RCV();