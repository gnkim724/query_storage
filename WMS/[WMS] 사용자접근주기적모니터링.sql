/*
 * WMS 사용자 접근 모니터링 데이터 추출
 * 1) 전체 사용자 리스트
 * 2) 모니터링 리스트
 * 3) 계정 생성
 * 4) 권한 변경
 * 5) 권한 회수
 * 6) 슈퍼 유저
 */
-- 1) 전체 사용자 리스트
SELECT DECODE( D.DEPT_NM, NULL, DECODE( A.SABUN_NO, NULL, '도급/기타', '기타' ), D.DEPT_NM )    AS 부서
     , NVL( A.SABUN_NO, '도급/기타' )                                                         AS 사번
     , A.USERID                                                                           AS 계정명
     , A.USERNAME                                                                         AS 사용자명
     , A.USERGROUPCODE                                                                    AS 보유권한
     , A.USEYN                                                                            AS 활성화_여부
     , TO_CHAR( A.ADDDATE, 'YYYY-MM-DD' )                                                 AS 계정생성일
     , NVL( TO_CHAR( B.HIS_DATETIME, 'YYYY-MM-DD' ), TO_CHAR( A.ADDDATE, 'YYYY-MM-DD' ) ) AS 권한부여일
     , A.ADDWHO                                                                           AS 권한부여자
  FROM FNF_ADM.ADT_CAU_USER A
     , FNF_ADM.VIEW_GROUP_CHG_DT B
     , FNF_ADM.VIEW_LAST_LOGIN C
     , (SELECT A.USERID, A.EMPNO, B.NAME_KOR AS DEPT_NM
          FROM FNF.USERS A
             , FNF.SYSTABLES B
         WHERE 1 = 1
           AND B.TBLNAME = 'hr_m_dept_code'
           AND A.DEPT = B.TBLCODE(+)) D
 WHERE 1 = 1
   AND A.USERID = B.USERID(+)
   AND A.USERID = C.USERID(+)
   AND A.USEYN = 'Y'
   AND A.SABUN_NO = D.EMPNO(+)
 ORDER BY 부서, A.SABUN_NO, A.USERID;


-- 2) 모니터링 리스트


-- 3) 계정 생성
--기간 신규계정 이력
SELECT DECODE( D.DEPT_NM, NULL, DECODE( B.SABUN_NO, NULL, '도급/기타', '기타' ), D.DEPT_NM ) AS 부서
     , NVL( B.SABUN_NO, '도급/기타' )                                                      AS 사번
     , A.USERID                                                                        AS 계정명
     , A.USERNAME                                                                      AS 사용자명
     , A.USERGROUPCODE                                                                 AS 보유권한
     , A.USEYN                                                                         AS 활성화여부
     , A.ADDDATE                                                                       AS 계정생성일
     , A.ADDWHO                                                                        AS 권한부여자
     , TO_DATE( C.LAST_LOGIN_YMD, 'YYYY-MM-DD' )                                       AS 최종로그인
     , A.HIS_DATETIME
  FROM ADT_CAU_USER_HIS A
     , ADT_CAU_USER B
     , FNF_ADM.VIEW_LAST_LOGIN C
     , (SELECT A.USERID, A.EMPNO, B.NAME_KOR AS DEPT_NM
          FROM FNF.USERS A
             , FNF.SYSTABLES B
         WHERE 1 = 1
           AND B.TBLNAME = 'hr_m_dept_code'
           AND A.DEPT = B.TBLCODE(+)) D
 WHERE TO_CHAR( A.HIS_DATETIME, 'YYYYMMDD' ) BETWEEN '20240101' AND '20240630'
   AND A.CRUD_TCD = 'I'
   AND A.USERID = B.USERID
   AND A.USERID = C.USERID(+)
   AND B.SABUN_NO = D.EMPNO(+)
 ORDER BY HIS_DATETIME;


SELECT A.USERID
     , A.USERNAME
     , NVL( B.SABUN_NO, '도급/기타' ) AS SABUN_NO
     , A.HIS_DATETIME
     , A.ADDDATE
     , A.USERGROUPCODE
     , A.OLD_USERGROUPCODE
  FROM ADT_CAU_USER_HIS A
     , ADT_CAU_USER B
 WHERE TO_CHAR( A.HIS_DATETIME, 'YYYYMMDD' ) BETWEEN '20240101' AND '20240630'
   AND A.CRUD_TCD = 'I'
   AND A.USERID = B.USERID
 ORDER BY HIS_DATETIME;


SELECT * FROM ADT_CAU_USER_HIS A WHERE TO_CHAR( A.HIS_DATETIME, 'YYYYMMDD' ) BETWEEN '20240101' AND '20240630' AND USERNAME = '김완식';

SELECT * FROM ADT_CAU_USER WHERE USERNAME = '김완식';

-- 4) 권한 변경
SELECT DECODE( D.DEPT_NM, NULL, DECODE( B.SABUN_NO, NULL, '도급/기타', '기타' ), D.DEPT_NM ) AS 부서
     , NVL( B.SABUN_NO, '도급/기타' )                                                      AS 사번
     , A.USERID                                                                        AS 계정명
     , A.USERNAME                                                                      AS 사용자명
     , A.OLD_USERGROUPCODE || ' -> ' || A.USERGROUPCODE                                AS 보유권한
     , A.USEYN                                                                         AS 활성화여부
     , A.ADDDATE                                                                       AS 계정생성일
     , A.EDITWHO                                                                       AS 수정자
     , A.EDITDATE                                                                      AS 수정일
     , TO_DATE( C.LAST_LOGIN_YMD, 'YYYY-MM-DD' )                                       AS 최종로그인
     , A.HIS_DATETIME
  FROM ADT_CAU_USER_HIS A
     , ADT_CAU_USER B
     , FNF_ADM.VIEW_LAST_LOGIN C
     , (SELECT A.USERID, A.EMPNO, B.NAME_KOR AS DEPT_NM
          FROM FNF.USERS A
             , FNF.SYSTABLES B
         WHERE 1 = 1
           AND B.TBLNAME = 'hr_m_dept_code'
           AND A.DEPT = B.TBLCODE(+)) D
 WHERE TO_CHAR( A.HIS_DATETIME, 'YYYYMMDD' ) BETWEEN '20220101' AND '20240630'
   AND A.USERGROUPCODE != A.OLD_USERGROUPCODE
   AND A.CRUD_TCD = 'U'
   AND A.USERID = B.USERID
   AND A.USERID = C.USERID(+)
   AND B.SABUN_NO = D.EMPNO(+)
 ORDER BY A.HIS_DATETIME;


-- 5) 권한회수
SELECT DECODE( G.DEPT_NM, NULL, DECODE( B.SABUN_NO, NULL, '도급/기타', '기타' ), G.DEPT_NM ) AS 부서
     , NVL( B.SABUN_NO, '도급/기타' )                                                      AS 사번
     , A.USERID                                                                        AS 계정명
     , A.USERNAME                                                                      AS 사용자명
     , A.USERGROUPCODE                                                                 AS 보유권한
     , A.USEYN                                                                         AS 활성화여부
     , A.ADDDATE                                                                       AS 계정생성일
     , A.EDITWHO                                                                       AS 수정자
     , A.EDITDATE                                                                      AS 수정일
     , TO_DATE( D.LAST_LOGIN_YMD, 'YYYY-MM-DD' )                                       AS 최종로그인
     , A.HIS_DATETIME
  FROM ADT_CAU_USER_HIS A
     , ADT_CAU_USER B
     , FNF.USERS C
     , FNF_ADM.VIEW_LAST_LOGIN D
     , (SELECT A.USERID, A.EMPNO, B.NAME_KOR AS DEPT_NM
          FROM FNF.USERS A
             , FNF.SYSTABLES B
         WHERE 1 = 1
           AND B.TBLNAME = 'hr_m_dept_code'
           AND A.DEPT = B.TBLCODE(+)) G
 WHERE 1 = 1
   AND TO_CHAR( A.HIS_DATETIME, 'YYYYMMDD' ) BETWEEN '20240101' AND '20240630'
   AND C.DEL_DATE BETWEEN '2024-01-01' AND '2024-06-30'
   AND A.CRUD_TCD = 'U'
   AND A.USERID = B.USERID
   AND A.USEYN = 'N'
   AND B.USEYN = 'N'
   AND B.SABUN_NO = C.EMPNO
   AND A.USERID = D.USERID(+)
   AND B.SABUN_NO = G.EMPNO(+)
 ORDER BY HIS_DATETIME;

-- 6) 슈퍼유저 리스트
SELECT DECODE( D.DEPT_NM
    , NULL, DECODE( A.SABUN_NO, NULL, '도급/기타', '기타' )
    , D.DEPT_NM )                        AS 부서
     , A.SABUN_NO                        AS 사번
     , A.USERID                          AS 계정명
     , A.USERNAME                        AS 사용자명
     , A.USERGROUPCODE                   AS 보유권한
     , A.USEYN                           AS 활성화_여부
     , TO_CHAR( A.ADDDATE, 'YYYYMMDD' )  AS 계정생성일
     , NVL( TO_CHAR( B.HIS_DATETIME, 'YYYYMMDD' )
    , TO_CHAR( A.ADDDATE, 'YYYYMMDD' ) ) AS 권한부여일
     , A.ADDWHO                          AS 권한부여자
  FROM FNF_ADM.ADT_CAU_USER A
     , FNF_ADM.VIEW_GROUP_CHG_DT B
     , FNF_ADM.VIEW_LAST_LOGIN C
     , (SELECT A.USERID, A.EMPNO, B.NAME_KOR AS DEPT_NM
          FROM FNF.USERS A
             , FNF.SYSTABLES B
         WHERE 1 = 1
           AND B.TBLNAME = 'hr_m_dept_code'
           AND A.DEPT = B.TBLCODE(+)) D
 WHERE 1 = 1
   AND A.USERID = B.USERID(+)
   AND A.USERID = C.USERID(+)
   AND A.USERGROUPCODE IN ('ADM', 'SUPR')
   AND A.USEYN = 'Y'
   AND A.SABUN_NO = D.EMPNO(+)
 ORDER BY A.SABUN_NO, A.USERID;
