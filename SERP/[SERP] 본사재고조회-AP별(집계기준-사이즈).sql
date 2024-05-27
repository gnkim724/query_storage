/* stockFlow.findListHqApStkSiz : 본사재고조회 AP별(집계기준- 사이즈) */
SELECT A.BRAND_CD /* 브랜드코드 */
     , A.SSN_CD /* 시즌코드 */
     , A.PROD_LLS_CD /* 상품대분류코드 */
     , A.PROD_LLS_NM /* 상품대분류명 */
     , A.PROD_MLS_CD /* 상품중분류코드 */
     , A.PROD_MLS_NM /* 상품중분류명 */
     , A.ITM_CD /* 아이템코드 */
     , A.ITM_NM /* 아이템명 */
     , A.PROD_CD /* 상품코드 */
     , A.PROD_NM /* 상품명 */
     , A.COLOR_CD /* 컬러코드 */
     , A.SIZ_CD /* 사이즈코드 */
     , A.WMS_GRP_CD /* WMS그룹코드 */
     , A.WMS_GRP_NM /* WMS그룹명 */
     , A.CTRY_CD /* 국가코드 */
     , A.CTRY_NM /* 국가명 */
     , A.AP_USG_CD /* AP용도코드 */
     , A.AP_USG_NM /* AP용도명 */
     , A.AP_TYP_CD /* AP유형코드 */
     , A.AP_TYP_NM /* AP유형명 */
     , A.AP_STS_CD /* AP상태코드 */
     , A.AP_STS_NM /* AP상태명 */
     , A.AP_CD /* AP코드 */
     , A.AP_KO_NM /* AP국문명 */
     , A.AP_STK_QTY /* AP 총재고 */
     , CASE
           WHEN D.AP_STS_CD IN ('ON1', 'OF1')
               AND A.AP_CD NOT IN ('S220', 'S240', 'S300', 'S400')
               THEN
               A.AP_AVAB_STK_QTY
               ELSE
               0
       END                                  AS AP_AVAB_STK_QTY /* AP 가용재고 */
     , A.ORD_QTY /* 주문수량 > 배분중 (1) */
     , A.SIGN_QTY /* 승인수량 > 배분확정 (3) */
     , A.DTT_QTY /* 검출수량 > 검출 (5)  */
     , A.SBY_QTY /* 출고대기수량 > 출고대기(7) */
     --,A.WMS_STK_QTY        /* WMS 총재고 */
     , B.PROD_STS_CD /* 상품상태코드 */
     , FC_GET_NAME( 'CODE'
    , B.PROD_STS_CD
    , 'FNF'
    , 'ko_KR'
    , 'PROD_STS_CD'
    , ''
    , ''
    , ''
    , ''
    , '' )                                  AS PROD_STS_NM /* 상품상태명 */
     , C.SORT_ORD /* 정렬순서 */
     , E.SALE_PRC /* 택가 */
     , FC_GET_SELLPRICE( TO_CHAR( SYSDATE, 'YYYY-MM-DD' )
    , A.BRAND_CD
    , A.SSN_CD
    , A.PROD_CD
    , A.COLOR_CD
    , 'C' )                                 AS ACT_SALE_PRC /* 판매가 */
     , (SELECT BRAND_CD
          FROM BIM_AP
         WHERE BRAND_CD = A.BRAND_CD
           AND AP_CD = A.AP_CD
           AND AP_USG_CD = 'DOM'
           AND AP_DIST_DIV_CD = 'D'
           AND AP_STS_CD IN ('ON1', 'OF1')) AS DISPLAY_COLOR
  FROM VIEW_HQ_STK_INFO A
           INNER JOIN BIM_PROD_COLOR B
                      ON A.BRAND_CD = B.BRAND_CD
                          AND A.SSN_CD = B.SSN_CD
                          AND A.PROD_CD = B.PROD_CD
                          AND A.COLOR_CD = B.COLOR_CD
           LEFT OUTER JOIN ESACDDT C
                           ON C.DTL_CD = A.SIZ_CD
                               AND C.GRP_CD = 'SIZE_SORT'
                               AND C.USE_YN = 'Y'
                               AND C.STS != 'D'
           INNER JOIN BIM_AP D
                      ON D.BRAND_CD = A.BRAND_CD
                          AND D.AP_CD = A.AP_CD
           INNER JOIN BIM_PROD E
                      ON A.BRAND_CD = E.BRAND_CD
                          AND A.SSN_CD = E.SSN_CD
                          AND A.PROD_CD = E.PROD_CD
 WHERE A.BRAND_CD = 'X'
   AND A.SSN_CD IN ('23S')
   AND UPPER( A.PROD_CD ) LIKE UPPER( '%DXRS5Q033%' )
   AND UPPER( A.COLOR_CD ) LIKE UPPER( '%MGL%' )
   AND UPPER( A.SIZ_CD ) LIKE UPPER( '%100%' )
   AND A.AP_STK_QTY != 0
   AND B.USE_YN = 'Y'
   AND E.USE_YN = 'Y'
 ORDER BY A.SSN_CD
        , A.PROD_CD
        , A.COLOR_CD
        , UPPER( LPAD( NVL( TO_CHAR( C.SORT_ORD ), A.SIZ_CD ), 3, '0' ) ) ASC
        , A.AP_CD;