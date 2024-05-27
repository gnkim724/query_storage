/* stockFlow.findListMovSttmt : 물류 전 매장 출고 (Invoice)- 이동명세서 조회 */
SELECT MV.BRAND_CD
     , MV.ORD_NO
     , MV.SSN_CD
     , MV.STD_SHOP_CD                                                                                      -- 기준매장코드
     , FC_GET_NAME( 'SHOP_ABBR', MV.STD_SHOP_CD, '', '', '', '', MV.BRAND_CD, '', '', '' ) AS SHOP_ABBR_NM -- 매장명
     , MV.ORD_DE                                                                                           -- 주문일자
     , MV.REQ_DE                                                                                           -- 요청일자
     , MV.GI_DE                                                                                            -- 출고일자
     , MV.GI_TYP_CD                                                                                        -- 출고유형코드
     , MV.GI_STS_CD                                                                                        -- 출고상태코드
     , MV.WMS_GI_TYP_CD                                                                    AS WMS출고유형코드
     , MV.FROM_AP_WH_CD
     , MV.TO_AP_WH_CD
     , CASE
           WHEN MV.FROM_SYS_CD = 'HQ'
               THEN MV.FROM_AP_WH_CD || '(' ||
                    FC_GET_NAME( 'AP', MV.FROM_AP_WH_CD, '', 'ko_KR', '', '', MV.BRAND_CD, '', '', '' ) || ') '
           WHEN MV.FROM_SYS_CD = 'SHOP'
               THEN MV.FROM_AP_WH_CD || '(' ||
                    FC_GET_NAME( 'WH', MV.FROM_AP_WH_CD, '', 'ko_KR', '', '', MV.BRAND_CD, '', MV.STD_SHOP_CD, '' ) ||
                    ') '
               ELSE MV.FROM_AP_WH_CD
       END                                                                                 AS FROM_AP_WH_NM
     , CASE
           WHEN MV.TO_SYS_CD = 'HQ'
               THEN
               MV.TO_AP_WH_CD || '(' ||
               FC_GET_NAME( 'AP', MV.TO_AP_WH_CD, '', 'ko_KR', '', '', MV.BRAND_CD, '', '', '' ) || ') '
           WHEN MV.TO_SYS_CD = 'SHOP'
               THEN
               MV.TO_AP_WH_CD || '(' ||
               FC_GET_NAME( 'WH', MV.TO_AP_WH_CD, '', 'ko_KR', '', '', MV.BRAND_CD, '', MV.STD_SHOP_CD, '' ) || ') '
               ELSE
               MV.TO_AP_WH_CD
       END                                                                                 AS TO_AP_WH_NM
     , NVL( (SELECT SUM( GI_QTY )
               FROM BIM_MOV_STTMT_DTL
              WHERE BRAND_CD = MV.BRAND_CD
                AND ORD_NO = MV.ORD_NO)
    , 0 )                                                                                  AS GI_QTY       -- 출고수량
     , MV.DIST_REF_NO                                                                      AS 배분참조번호
     , MV.PRC_APLY_DE                                                                      AS 단가적용일자
     , NVL( (SELECT GI_RAT
               FROM BIM_MOV_STTMT_DTL
              WHERE BRAND_CD = MV.BRAND_CD
                AND ORD_NO = MV.ORD_NO
                AND ROWNUM = 1
              GROUP BY GI_RAT)
    , 0 )                                                                                  AS GI_RAT       -- 출고율
     , NVL( (SELECT SUM( GI_AMT )
               FROM BIM_MOV_STTMT_DTL
              WHERE BRAND_CD = MV.BRAND_CD
                AND ORD_NO = MV.ORD_NO)
    , 0 )                                                                                  AS GI_AMT       -- 출고금액
     , CASE
           WHEN NVL( MV.CUR_CD, 'KRW' ) = 'KRW'
               THEN
               NVL( (SELECT SUM( SALE_AMT )
                       FROM BIM_MOV_STTMT_DTL
                      WHERE BRAND_CD = MV.BRAND_CD
                        AND ORD_NO = MV.ORD_NO)
                   , 0 )
               ELSE
               0
       END                                                                                 AS SALE_AMT     -- 판매가금액
     , NVL( (SELECT SUM( VAT )
               FROM BIM_MOV_STTMT_DTL
              WHERE BRAND_CD = MV.BRAND_CD
                AND ORD_NO = MV.ORD_NO), 0 )                                               AS VAT          -- VAT
     , NVL( (SELECT SUM( GI_AMT ) + SUM( VAT )
               FROM BIM_MOV_STTMT_DTL
              WHERE BRAND_CD = MV.BRAND_CD
                AND ORD_NO = MV.ORD_NO), 0 )                                               AS GI_TOT_AMT
     , NVL( (SELECT SUM( FC_GI_AMT )
               FROM BIM_MOV_STTMT_DTL
              WHERE BRAND_CD = MV.BRAND_CD
                AND ORD_NO = MV.ORD_NO), 0 )                                               AS FC_GI_AMT    -- 출고금액
     , MV.INSR_ID                                                                                          -- 입력자ID
     , MV.INS_DT                                                                                           -- 입력일시
     , MV.UPDR_ID                                                                                          -- 수정자ID
     , MV.UPD_DT                                                                                           -- 수정일시
  FROM BIM_MOV_STTMT MV /* 이동명세 */
           LEFT OUTER JOIN BIM_PROD_CLS PR
                           ON PR.PROD_CLS_CD = MV.ORD_DIV_CD
                               AND PR.LV = 3
 WHERE MV.BRAND_CD = 'M'
   AND MV.SSN_CD IN ('23S')
   AND MV.GI_DE BETWEEN '2024-05-19' AND '2024-05-20'
   AND (0, MV.STD_SHOP_CD) IN ((0, '9001'))
   AND MV.GI_STS_CD = 'C'
   AND MV.GI_STS_CD != 'D'
   AND MV.USE_YN = 'Y'
 ORDER BY MV.GI_DE DESC, MV.SSN_CD DESC, MV.STD_SHOP_CD, MV.ORD_NO;






/**
  이동명세 수량 및 금액 확인
 */
SELECT SUM( CASE WHEN MV.GI_TYP_CD > 500 THEN -1 ELSE 1 END * MVD.GI_QTY )   AS 수량
     , SUM( CASE WHEN MV.GI_TYP_CD > 500 THEN -1 ELSE 1 END * MVD.GI_AMT )   AS 출고금액
     , SUM( CASE WHEN MV.GI_TYP_CD > 500 THEN -1 ELSE 1 END * MVD.SALE_AMT ) AS 판매금액
  FROM BIM_MOV_STTMT MV
     , BIM_MOV_STTMT_DTL MVD
 WHERE 1 = 1
   AND MV.BRAND_CD = MVD.BRAND_CD
   AND MV.ORD_NO = MVD.ORD_NO
   AND MV.SSN_CD = MVD.SSN_CD
   AND MV.BRAND_CD = 'M'
   AND MV.SSN_CD IN ('23S')
   AND MV.GI_DE BETWEEN '2024-05-20' AND '2024-05-20'
   AND (0, MV.STD_SHOP_CD) IN ((0, '9001'))
   AND MV.GI_STS_CD = 'C'
   AND MV.GI_STS_CD != 'D'
   AND MV.USE_YN = 'Y'