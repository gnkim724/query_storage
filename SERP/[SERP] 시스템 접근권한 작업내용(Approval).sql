/*
 * Approval
 * 신규 입사 예정자 품의 (59)
 * 시스템 접근제한 품의 (133)
 */


/*
PRC_USERBRAND
PRC_USERCOMPANY
PRC_USERPERMISSION
PRC_USERS_MODULE
*/


SELECT TBLCODE
     , NAME_KOR
     , VALUE_01 -- 신규입사자 권한 신청 모듈 노출
     , VALUE_02 -- 입사예정권한 디폴트
     , VALUE_03 -- 모듈 담당 (2024.05.24 현재 미사용)
     , VALUE_04 -- 시스템 접근권한 신청 모듈 노출
     , USEYN    -- SSO 연동 여부
  FROM SYSTABLES
 WHERE TBLNAME = 'module'
   AND TBLCODE IN ('S-ERP', 'SMS', 'MAINERP');

SELECT *
  FROM SYSTABLESH
 WHERE TBLNAME = 'module';

-- S-ERP & SMS 모듈 노출 작업
UPDATE FNF.SYSTABLES A
   SET A.VALUE_01 = 'Y'
     , A.VALUE_02 = 'N'
     , A.VALUE_04 = 'Y'
 WHERE 1 = 1
   AND A.TBLNAME = 'module'
   AND A.TBLCODE IN ('S-ERP', 'SMS', 'MAINERP')
   ;

commit;

SELECT TBLCODE
     , NAME_KOR
     , NAME_ETC -- 품의에 노출되는 이름
     , VALUE_02 -- 모듈명 기입 (필수, 감사에 사용)
     , VALUE_03 -- 레벨 'D' -> 특수권한에 노출
  FROM SYSTABLES
 WHERE TBLNAME = 'menu_unitcode'
   AND VALUE_03 >= 'D';



SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'menu_unitcode'
   AND VALUE_03 >= 'D'
 ORDER BY TBLCODE
;

-- 특수권한 추가 작업
INSERT INTO FNF.SYSTABLES ( TBLNAME
                          , TBLCODE
                          , NAME_KOR
                          , NAME_CHN
                          , SORT
                          , USEYN
                          , VALUE_01
                          , VALUE_02
                          , VALUE_03
                          , NAME_ETC
                          , NAME_ENG
                          , NAME_JPN
                          , INPUT_USERID
                          , INPUT_DATE
                          , UPDATE_USERID
                          , UPDATE_DATE)
VALUES ( 'menu_unitcode'
       , 'DST100'
       , '배분보충_확정포함'
       , '배분보충_확정포함'
       , 'DST100'
       , 'Y'
       , ''
       , 'S-ERP'
       , 'D'
       , 'S-ERP(유통) > 배분보충_확정포함(DST100)'
       , '배분보충_확정포함'
       , '배분보충_확정포함'
       , 'gnkim724'
       , SYSDATE
       , 'gnkim724'
       , SYSDATE);

INSERT INTO FNF.SYSTABLES ( TBLNAME
                          , TBLCODE
                          , NAME_KOR
                          , NAME_CHN
                          , SORT
                          , USEYN
                          , VALUE_01
                          , VALUE_02
                          , VALUE_03
                          , NAME_ETC
                          , NAME_ENG
                          , NAME_JPN
                          , INPUT_USERID
                          , INPUT_DATE
                          , UPDATE_USERID
                          , UPDATE_DATE)
VALUES ( 'menu_unitcode'
       , 'DST200'
       , '반품_확정포함'
       , '반품_확정포함'
       , 'DST200'
       , 'Y'
       , ''
       , 'S-ERP'
       , 'D'
       , 'S-ERP(유통) > 반품_확정포함(DST200)'
       , '반품_확정포함'
       , '반품_확정포함'
       , 'gnkim724'
       , SYSDATE
       , 'gnkim724'
       , SYSDATE);

INSERT INTO FNF.SYSTABLES ( TBLNAME
                          , TBLCODE
                          , NAME_KOR
                          , NAME_CHN
                          , SORT
                          , USEYN
                          , VALUE_01
                          , VALUE_02
                          , VALUE_03
                          , NAME_ETC
                          , NAME_ENG
                          , NAME_JPN
                          , INPUT_USERID
                          , INPUT_DATE
                          , UPDATE_USERID
                          , UPDATE_DATE)
VALUES ( 'menu_unitcode'
       , 'DST300'
       , '배분보충_확정제외'
       , '배분보충_확정제외'
       , 'DST300'
       , 'Y'
       , ''
       , 'S-ERP'
       , 'D'
       , 'S-ERP(유통) > 배분보충_확정제외(DST300)'
       , '배분보충_확정제외'
       , '배분보충_확정제외'
       , 'gnkim724'
       , SYSDATE
       , 'gnkim724'
       , SYSDATE);

commit;
