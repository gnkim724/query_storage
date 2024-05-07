/**
  SMS 수금내역서 조회
  1. 외상 매출금 : 전기이월, 출고, 반품, 입금, 잔액
  2. 수금 : 저장품, 수선비, O2O수수료, RFID장비임대료
  3. 전월미수금, 전미수금, 입금액, 결제예정액, 미수잔액
 */

-- 헤더
CALL SMS.PKG_SAP.PRC_COLLECT_MONEY_LIST(
        '<OUT>',
        'X',
        '70001',
        1,
        '2024-04',
        'ko_KR'
     );

SELECT BRK.BRAND_CD
     , BRK.SHOP_CD
     , BRK.STD_YYMM
     , BRK.DEG
     , NVL( BRK.GI_AMT, 0 )                                                                                 AS GI_AMT
     , NVL( BRK.RTN_AMT, 0 )                                                                                AS RTN_AMT
     , NVL( BRK.SPLS_AMT, 0 )                                                                               AS SPLS_AMT
     , NVL( BRK.RPR_AMT, 0 )                                                                                AS RPR_AMT
     , NVL( BRK.O2O_CMS, 0 )                                                                                AS O2O_CMS
     , NVL( BRK.RFID_EQ_LEASE_AMT, 0 )                                                                      AS RFID_EQ_LEASE_AMT
     , NVL( BRK.ADJ_AMT, 0 )                                                                                AS ADJ_AMT
     , NVL( BRK.NOT_CTB_AMT, 0 )                                                                            AS NOT_CTB_AMT
     , NVL( BRK.DPST_AMT, 0 )                                                                               AS DPST_AMT
     , NVL( BRK.CRDT_BUY_AMT, 0 )                                                                           AS CRDT_BUY_AMT
     , NVL( BRK.PMT_EXPT_AMT, 0 )                                                                           AS PMT_EXPT_AMT
     , NVL( BRK.NOT_CTB_BAL, 0 )                                                                            AS NOT_CTB_BAL
     , NVL( BRK.CROV_AMT, 0 )                                                                               AS CROV_AMT
     , SH.SHOP_ABBR_NM                                                                                      AS SHOP_NM
     , SH.REP_NM
     , NVL( BRK.NOT_CTB_AMT, 0 ) + (NVL( BRK.DPST_AMT, 0 ))                                                 AS COLLECT_AMT
     , NVL( BRK.CROV_AMT, 0 ) + NVL( BRK.GI_AMT, 0 ) - NVL( BRK.RTN_AMT, 0 ) + NVL( BRK.SPLS_AMT, 0 ) +
       NVL( BRK.RPR_AMT, 0 ) -
       NVL( BRK.DPST_AMT, 0 )                                                                               AS BALANCE_AMT
     , DECODE( '1' /* 차수 */, '1', '2024-04' || '-01', '2024-04' || '-16' )                                  AS FR_DE
     , DECODE( '1' /* 차수 */, '1', '2024-04' || '-15',
               TO_CHAR( LAST_DAY( TO_DATE( '2024-04' || '-01', 'YYYY-MM-DD' ) ), 'YYYY-MM-DD' ) )           AS TO_DE
     , DECODE( CFM_YN, 'Y', '' || TO_CHAR( BRK.UPD_DT, 'YYYY-MM-DD HH24:MI:SS' ) || ' 읽음 처리된 수금 내역서.', '' ) AS CONTENT
  FROM SMS.SET_CTB_BRK BRK
           LEFT JOIN
       SMS.MST_SHOP SH
       ON
           BRK.BRAND_CD = SH.BRAND_CD
               AND BRK.SHOP_CD = SH.SHOP_CD
 WHERE BRK.BRAND_CD = 'X'
   AND BRK.SHOP_CD = '70001'
   AND BRK.STD_YYMM = '2024-04'
   AND BRK.DEG = '1';


-- 디테일
CALL SMS.PKG_SAP.PRC_COLLECT_MONEY_DETAIL_LIST(
        '<OUT>',
        'X',
        '70001',
        1,
        '2024-04',
        'ko_KR'
     );

SELECT SD.SUM_SALE_AMT
     , SD.SALE_TYP_CD
     , FC_GET_CD_DTL_NM( 'SALE_TYP_CD', 'ko_KR', SD.SALE_TYP_CD ) AS SALE_TYP_NM
     , SD.SUM_SALE_AMT * NVL( SD.GI_RAT, 100 ) / 100              AS APPR_AMT
     , 100 - SD.GI_RAT                                            AS SPY_PRC_RAT
  FROM (SELECT BRAND_CD
             , SHOP_CD
             , SALE_TYP_CD
             , NVL( SUM( DECODE( SALE_DIV_CD, '1', ACT_SALE_AMT, -ACT_SALE_AMT ) ), 0 ) AS SUM_SALE_AMT
             , MAX( SALE_DE )                                                           AS SALE_DE
             , GI_RAT
          FROM SAL_SALE_DTL
         WHERE BRAND_CD = 'X'
           AND SHOP_CD = '70001'
           AND SALE_DE BETWEEN DECODE( '1' /* 차수 */, '1', '2024-04' || '-01', '2024-04' || '-16' ) AND DECODE(
                 '1' /* 차수 */, '1', '2024-04' || '-15',
                 TO_CHAR( LAST_DAY( TO_DATE( '2024-04' || '-01', 'YYYY-MM-DD' ) ), 'YYYY-MM-DD' ) )
         GROUP BY BRAND_CD, SHOP_CD, SALE_TYP_CD, GI_RAT) SD
 WHERE SD.BRAND_CD = 'M'
   AND SD.SHOP_CD = '70001'
 ORDER BY SD.SALE_TYP_CD ASC;