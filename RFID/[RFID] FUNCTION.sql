
/******************************************
            PDA (RFID) FUNCTION
*******************************************/

-- 매장판매가 조회 (PDA) - 자동단가
SELECT SMS.FNC_IF_RFID_GET_SELL_PRICE_UID( 'M', '527', '23F', '3FTRB2034:43CRD' ) FROM DUAL;

-- 상품이미지 조회 (PDA)
SELECT SMS.FNC_IF_RFID_GET_IMG_URL_UID('X', '23F','3FTRB2034','43CRD', 'ECB') FROM DUAL;



-- 로그인 정책
SELECT NERP.SF_RFID_LOGIN('gnkim724') FROM DUAL;





/******************************************
            PDA (RFID) PROCEDURE
*******************************************/
CALL SMS.PRC_IF_RFIDPDA_LOGIN('M524','test', :PSV_CODE, :PSV_MSG);

CALL SERP.PRC_IF_RFIDSTOCK_RECV('ADM', '1111', :VO_RTNCODE, :VO_RTNMSG);


