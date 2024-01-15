/*
SERP -> SAP 거래명세 전송
*/
-- IF 테이블
SELECT *
  FROM SERP_IF.IF_SAP_TRD_STTMT_SND A
 WHERE TO_CHAR( A.DATA_INPUT_DATE, 'YYYY-MM-DD' ) >= TO_CHAR( SYSDATE, 'YYYY-MM-DD' )
   AND SHOP_CD IN ('I10085', '10111')
   AND EAI_SEQ >= 1183913
 ORDER BY DATA_INPUT_DATE DESC;