/*
 * 출고오더 > 배분번호별 조회
 */
SELECT B.SO_NO
     , TO_CHAR( MIN( A.OUTB_ECT_DATE ), 'YYYYMMDD' )                         AS MIN_OB_ECT
     , TO_CHAR( MAX( A.OUTB_ECT_DATE ), 'YYYYMMDD' )                         AS MAX_OB_ECT
     , COUNT( DISTINCT A.WAVE_NO )                                           AS WAVE_CNT
     , COUNT( DISTINCT A.SHIPTO_ID )                                         AS SHIPTO_CNT
     , COUNT( DISTINCT B.ITEM_CD )                                           AS SKU_CNT
     , SUM( B.OUTB_ECT_QTY )                                                 AS TOT_QTY
     , SUM( CASE WHEN A.WAVE_NO IS NOT NULL THEN B.OUTB_ECT_QTY ELSE 0 END ) AS WAVING_QTY
     , SUM( CASE WHEN A.WAVE_NO IS NULL THEN B.OUTB_ECT_QTY ELSE 0 END )     AS TOWAVE_QTY
     , MAX( B.INS_DATETIME )                                                 AS INS_DATETIME
  FROM WMT_COB_OUTBOUND_HR A
     , WMT_COB_OUTBOUND_DR B
 WHERE A.WH_CD = 'ICF'
   AND TO_CHAR( A.OUTB_ECT_DATE, 'YYYYMMDD' ) BETWEEN '20240522' AND '20240527'
   AND A.WH_CD = B.WH_CD
   AND A.OUTB_NO = B.OUTB_NO
   AND A.DEL_YN = 'N'
   AND B.DEL_YN = 'N'
   AND A.STRR_ID = 'X'
   AND B.SO_NO IS NOT NULL
 GROUP BY B.SO_NO
 ORDER BY COUNT( DISTINCT A.SHIPTO_ID ) DESC, SUM( B.OUTB_ECT_QTY ) DESC;

/*
 * 매장 출고 오더별
 */
SELECT B.WH_CD
     , B.STRR_ID
     , B.SHIPTO_ID
     , B.SHIPTO_NM
     , WMF_CSY_CODE_NM( 'OUTB_SCD', B.OUTB_SCD, 'KO' ) AS OUTB_SCD
     , B.WAVE_NO
     , (SELECT DESCR
          FROM WMT_COB_WAVE_HR
         WHERE WH_CD = B.WH_CD
           AND WAVE_NO = B.WAVE_NO)                    AS DESCR
     , B.OUTB_TCD
     , B.OUTB_NO
     , WMF_SCSS( B.STRR_ID, MIN( A.ITEM_CD ) )         AS FR_SCS
     , WMF_SCSS( B.STRR_ID, MAX( A.ITEM_CD ) )         AS TO_SCS
     , SUM( A.OUTB_ECT_QTY )                           AS OUTB_ECT_QTY
     , MAX( A.INS_DATETIME )                           AS INS_DATETIME
     , A.SO_NO
  FROM WMT_COB_OUTBOUND_DR A
     , WMT_COB_OUTBOUND_HR B
 WHERE A.WH_CD = 'ICF'
   AND A.SO_NO = 'XDIST202405270000235105'
   AND A.DEL_YN = 'N'
   AND A.WH_CD = B.WH_CD
   AND A.OUTB_NO = B.OUTB_NO
 GROUP BY B.WH_CD, B.STRR_ID, B.SHIPTO_ID, B.SHIPTO_NM, B.OUTB_SCD, B.WAVE_NO, B.OUTB_TCD, B.OUTB_NO, A.INS_DATETIME
        , A.SO_NO
 ORDER BY B.SHIPTO_ID
;

/*
 * 상세 상품
 */
SELECT A.ITEM_CD
     , WMF_CSY_CODE_NM( 'LALOC_SCD', A.LALOC_SCD, 'KO' ) AS LALOC_SCD
     , A.OUTB_ECT_QTY
     , A.LALOC_QTY
     , A.PICK_QTY
  FROM WMT_COB_OUTBOUND_DR A
     , WMT_CMD_ITEM B
 WHERE A.WH_CD = 'ICF'
   AND A.SO_NO = 'XDIST202405270000235105'
   AND A.OUTB_NO = '0065972981'
   AND A.DEL_YN = 'N'
   AND A.STRR_ID = B.STRR_ID
   AND A.ITEM_CD = B.ITEM_CD
 ORDER BY A.ITEM_CD
;