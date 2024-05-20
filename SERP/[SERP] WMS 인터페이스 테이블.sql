/**
  WMS - SERP 인터페이스 테이블
  1. WMS 출고 지시 송신
  2. WMS 입고 예정 정보
  3. 물류 출고 완료 수신 I/F 테이블
 */
-- WMS 출고 지시 송신
SELECT * FROM SERP_IF.IF_WMS_OUTBOUND_SND A WHERE A.BRAND_CD = 'M';

-- WMS 입고 예정 정보
SELECT * FROM SERP_IF.IF_WMS_INBOUND_SND A WHERE 1=1;

-- 물류 출고 완료 수신 조회
SELECT * FROM SERP_IF.IF_WMS_GI_RCV A WHERE 1 = 1 AND A.PROD_CD = 'DKWJ41031' AND COLOR_CD = 'BKS';
