/*
 영업/고객 관리 > 수선 진행현황 등록 > 입출고 내역 처리 (행낭)
 */

-- 브랜드 리스트 조회 (repair.getRprUseBrandList)
SELECT BRAND_CD
     , BRAND_CD    AS DATA
     , BRAND_EN_NM AS LABEL
  FROM BIM_BRAND
 WHERE BRAND_EN_NM IS NOT NULL
   AND RPR_USE_YN = 'Y'
 ORDER BY SORT;


/* repair.findSummaryList: 입출고 처리내역 요약 */
-- BIM_RPR (수선), BIM_RV_RCPTN(수선처접수)
SELECT '상담실 처리내역'            AS TITLE
     , NVL( SUM( B.M ), 0 )  AS M
     , NVL( SUM( B.I ), 0 )  AS I
     , NVL( SUM( B.X ), 0 )  AS X
     , NVL( SUM( B.A ), 0 )  AS A
     , NVL( SUM( B.W ), 0 )  AS W
     , NVL( SUM( B.ST ), 0 ) AS ST
     , NVL( SUM( B.V ), 0 )  AS V
  FROM (SELECT CASE WHEN A.BRAND_CD = 'M' THEN 1 END  AS M
             , CASE WHEN A.BRAND_CD = 'I' THEN 1 END  AS I
             , CASE WHEN A.BRAND_CD = 'X' THEN 1 END  AS X
             , CASE WHEN A.BRAND_CD = 'A' THEN 1 END  AS A
             , CASE WHEN A.BRAND_CD = 'W' THEN 1 END  AS W
             , CASE WHEN A.BRAND_CD = 'ST' THEN 1 END AS ST
             , CASE WHEN A.BRAND_CD = 'V' THEN 1 END  AS V
          FROM (SELECT DISTINCT RPR.RPR_RCPTN_NO
                              , RPR.SCAN_YN
                              , RPR.BRAND_CD
                  FROM BIM_RPR RPR
                           LEFT OUTER JOIN BIM_RV_RCPTN BRR
                                           ON BRR.RPR_RCPTN_NO = RPR.RPR_RCPTN_NO
                 WHERE 1 = 1
                   AND (BRR.SND_METH_CD != '1' OR RPR.SHOP_SND_DE IS NOT NULL)
                   AND RPR.USE_YN = 'Y'
                   AND SHOP_SND_DE = '2024-03-08') A) B
 UNION ALL
SELECT '행랑실 처리건수'            AS TITLE
     , NVL( SUM( B.M ), 0 )  AS M
     , NVL( SUM( B.I ), 0 )  AS I
     , NVL( SUM( B.X ), 0 )  AS X
     , NVL( SUM( B.A ), 0 )  AS A
     , NVL( SUM( B.W ), 0 )  AS W
     , NVL( SUM( B.ST ), 0 ) AS ST
     , NVL( SUM( B.V ), 0 )  AS V
  FROM (SELECT CASE WHEN A.BRAND_CD = 'M' AND A.SCAN_YN = 'Y' THEN 1 END  AS M
             , CASE WHEN A.BRAND_CD = 'I' AND A.SCAN_YN = 'Y' THEN 1 END  AS I
             , CASE WHEN A.BRAND_CD = 'X' AND A.SCAN_YN = 'Y' THEN 1 END  AS X
             , CASE WHEN A.BRAND_CD = 'A' AND A.SCAN_YN = 'Y' THEN 1 END  AS A
             , CASE WHEN A.BRAND_CD = 'W' AND A.SCAN_YN = 'Y' THEN 1 END  AS W
             , CASE WHEN A.BRAND_CD = 'ST' AND A.SCAN_YN = 'Y' THEN 1 END AS ST
             , CASE WHEN A.BRAND_CD = 'V' AND A.SCAN_YN = 'Y' THEN 1 END  AS V
          FROM (SELECT DISTINCT RPR.RPR_RCPTN_NO
                              , RPR.SCAN_YN
                              , RPR.BRAND_CD
                  FROM BIM_RPR RPR
                           LEFT OUTER JOIN BIM_RV_RCPTN BRR
                                           ON BRR.RPR_RCPTN_NO = RPR.RPR_RCPTN_NO
                 WHERE 1 = 1
                   AND (BRR.SND_METH_CD != '1' OR RPR.SHOP_SND_DE IS NOT NULL)
                   AND RPR.USE_YN = 'Y'
                   AND SHOP_SND_DE = '2024-03-08') A) B
 UNION ALL
SELECT '행랑실 미처리건'            AS TITLE
     , NVL( SUM( B.M ), 0 )  AS M
     , NVL( SUM( B.I ), 0 )  AS I
     , NVL( SUM( B.X ), 0 )  AS X
     , NVL( SUM( B.A ), 0 )  AS A
     , NVL( SUM( B.W ), 0 )  AS W
     , NVL( SUM( B.ST ), 0 ) AS ST
     , NVL( SUM( B.V ), 0 )  AS V
  FROM (SELECT CASE WHEN A.BRAND_CD = 'M' AND A.SCAN_YN = 'N' THEN 1 END  AS M
             , CASE WHEN A.BRAND_CD = 'I' AND A.SCAN_YN = 'N' THEN 1 END  AS I
             , CASE WHEN A.BRAND_CD = 'X' AND A.SCAN_YN = 'N' THEN 1 END  AS X
             , CASE WHEN A.BRAND_CD = 'A' AND A.SCAN_YN = 'N' THEN 1 END  AS A
             , CASE WHEN A.BRAND_CD = 'W' AND A.SCAN_YN = 'N' THEN 1 END  AS W
             , CASE WHEN A.BRAND_CD = 'ST' AND A.SCAN_YN = 'N' THEN 1 END AS ST
             , CASE WHEN A.BRAND_CD = 'V' AND A.SCAN_YN = 'N' THEN 1 END  AS V
          FROM (SELECT DISTINCT RPR.RPR_RCPTN_NO
                              , RPR.SCAN_YN
                              , RPR.BRAND_CD
                  FROM BIM_RPR RPR
                           LEFT OUTER JOIN BIM_RV_RCPTN BRR
                                           ON BRR.RPR_RCPTN_NO = RPR.RPR_RCPTN_NO
                 WHERE 1 = 1
                   AND (BRR.SND_METH_CD != '1' OR RPR.SHOP_SND_DE IS NOT NULL)
                   AND RPR.USE_YN = 'Y'
                   AND SHOP_SND_DE = '2024-03-08') A) B;


/* repair.findCsProcList: 상담실 처리내역 리스트 */
SELECT DISTINCT RPR.RPR_RCPTN_NO                                                                                    -- 수선접수번호
              , FC_GET_NAME( 'SHOP_ABBR', RPR.SHOP_CD, '', '', '', '', RPR.BRAND_CD, '', '', '' ) AS SHOP_NM        -- 매장명
              , RPR.SHOP_CD                                                                                         -- 매장 코드
              , RPR.SSN_CD                                                                                          -- 시즌코드
              , RPR.CUST_ID                                                                                         -- 고객명
              , RPR.PROD_CD                                                                                         -- 스타일코드
              , RPR.COLOR_CD                                                                                        -- 컬러코드
              , RPR.SIZ_CD                                                                                          -- 사이즈코드
              , FC_GET_NAME( 'USER', RPR.UPDR_ID, 'FNF', 'ko_KR', '', 'A', '', '', '', '' )       AS UPDR_ID        -- 처리자
              , RPR.SCAN_YN                                                                                         -- 스캔여부
              , RPR.RFID_UID                                                                                        -- 바코드
              , FC_GET_NAME( 'USER', RPR.POUCH_PROCR_ID, 'FNF', 'ko_KR', '', 'A', '', '', '',
                             '' )                                                                 AS POUCH_PROCR_ID -- 행낭 처리자
  FROM BIM_RPR RPR
           LEFT OUTER JOIN BIM_RV_RCPTN BRR
                           ON BRR.RPR_RCPTN_NO = RPR.RPR_RCPTN_NO
 WHERE 1 = 1
   AND (BRR.SND_METH_CD != '1' OR RPR.SHOP_SND_DE IS NOT NULL) -- 발송방법 : 행낭, 택배
   AND RPR.SCAN_YN = 'N'
   AND RPR.BRAND_CD IN ('M')
   AND RPR.SHOP_SND_DE = '2024-03-08';


/*repair.findPouchList: 행낭실 스캔완료 리스트 */
SELECT DISTINCT RPR.RPR_RCPTN_NO                                                                                    -- 수선접수번호
              , FC_GET_NAME( 'SHOP_ABBR', RPR.SHOP_CD, '', '', '', '', RPR.BRAND_CD, '', '', '' ) AS SHOP_NM        -- 매장명
              , RPR.SHOP_CD                                                                                         -- 매장 코드
              , RPR.SSN_CD                                                                                          -- 시즌코드
              , RPR.CUST_ID                                                                                         -- 고객명
              , RPR.PROD_CD                                                                                         -- 스타일코드
              , RPR.COLOR_CD                                                                                        -- 컬러코드
              , RPR.SIZ_CD                                                                                          -- 사이즈코드
              , FC_GET_NAME( 'USER', RPR.UPDR_ID, 'FNF', 'ko_KR', '', 'A', '', '', '', '' )       AS UPDR_ID        -- 처리자
              , RPR.SCAN_YN                                                                                         -- 스캔여부
              , RPR.RFID_UID                                                                                        -- 바코드
              , FC_GET_NAME( 'USER', RPR.POUCH_PROCR_ID, 'FNF', 'ko_KR', '', 'A', '', '', '',
                             '' )                                                                 AS POUCH_PROCR_ID -- 행낭 처리자
  FROM BIM_RPR RPR
           LEFT OUTER JOIN BIM_RV_RCPTN BRR
                           ON BRR.RPR_RCPTN_NO = RPR.RPR_RCPTN_NO
 WHERE 1 = 1
   AND (BRR.SND_METH_CD != '1' OR RPR.SHOP_SND_DE IS NOT NULL) -- 발송방법 : 행낭, 택배
   AND RPR.SCAN_YN = 'Y'
   AND RPR.BRAND_CD IN ('M')
   AND RPR.SHOP_SND_DE = '2024-03-08';