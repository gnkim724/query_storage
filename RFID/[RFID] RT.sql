/**
  PDA RT 프로세스
  - SMS_IF.IF_RFID_RT_SEND에 데이터는 삭제하지 않는다. (별개 커밋)
  - SMS.PRC_IF_RCV_RFID_RT() 프로시저만 롤백 ... (이후 재전송 시 다시 SMS_IF.IF_RFID_RT_SEND 테이블에 넣고 프로시저 호출
 */
-- RT 지시목록 조회
SELECT * FROM SMS.VIEW_IF_RT_REQ;

-- RT 보냄처리 가능 여부 조회 (REST 호출 JSON TO JSON)
-- POST https://es-api-dev.fnf.co.kr/v1/drp-be/api-gateway/dist/{{brandCd}}/stp

-- SMS로 RT 보냄/받음에 대한 정보를 송신 (RT보냄취소 포함)
SELECT * FROM SMS_IF.IF_RFID_RT_SEND;

-- SMS RT 정보 수신 (PDA에서 호출 - 커밋 포함)
CALL SMS.PRC_IF_RCV_RFID_RT();


/**
  PRC_IF_RCV_RFID_RT

  <보냄처리>
    insert SMS.STK_RT (RT)
    CALL PRC_RTRT_BY_RT_NO (NO_REQ) (재고이동)
    CALL PRC_IF_SERP_RT_SND('I', NO_REQ) (SEND I/F)

    완불 or 지시건
        UPDATE STK_RT_REQ (RT요청)
        MERGE SMS.STK_RT_REQ_RFID (RT요청RFID)

  <받음처리>
    update SMS.STK_RT (RT)

    자동 RT , 지시 RT
        update STK_RT_REQ

    CALL PRC_RTAC_BY_RT_NO (NO_REQ) - 재고이동, RT 받음
    CALL PRC_IF_RT_STATUS_RECV ('U', NO_REQ) (SEND I/F)
    CALL PRC_IF_SERP_RT_SND

  <보냄취소 처리>
    UPDATE SMS.STK_RT (CNL_YN = 'N')
    DELETE SMS.STK_RT_REQ_RFID (RT요청RFID)

    PRC_IF_SERP_RT_SND
    PRC_RTCL_BY_RT_NO (NO_REQ) - 재고이동
    PRC_IF_RT_STATUS_RECV

 */

-- RT 보냄/받음에 대한 정보 수신
SELECT * FROM SMS.VIEW_IF_RT_RECV;

-- SERP RT 지시 응답 수신 (PDA에서 호출)
-- POST https://es-api-dev.fnf.co.kr/v1/drp-be/api-gateway/response-rt
