/**
  [SERP - WMS]
  1. 물류 출고 완료 수신 I/F 테이블
 */

-- 물류 출고 완료 수신 조회
SELECT *
  FROM SERP_IF.IF_WMS_GI_RCV
 WHERE 1 = 1
   AND PROD_CD = 'DKWJ41031'
   AND COLOR_CD = 'BKS';