/*
거래명세 조회
ORD_NO : 주문번호
IV_NO : 송장번호
GI_TYP_CD : sotype(출고유형코드)
GI_RAT : 출고율
SALE_TYP_CD : saletrtype(판매유형코드_
*/
SELECT B.*
  FROM BIM_TRD_STTMT A
     , BIM_TRD_STTMT_DTL B
 WHERE 1 = 1
   AND A.BRAND_CD = B.BRAND_CD
   AND A.ORD_NO = B.ORD_NO
   AND A.SSN_CD = B.SSN_CD
   AND A.BRAND_CD = 'M'
   AND A.ORD_NO = 'M19F00702205'
   AND A.GI_STS_CD = 'C';