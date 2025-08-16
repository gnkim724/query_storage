/*
 * HR 인터페이스
 * HR-APIX-03
 */

-- HR-APIX-03
SELECT U.EMPNO
     , U.NAME
     , U.USERID
     , FNF.PKG_HASH_CRYPTO.ENCRYPT( U.PASSWORD ) AS PWD        --단방향 암호화
     , U.EMAIL
     , U.DEPT
     , U.POSITION                                AS POSIT
     , TO_CHAR( U.INPUT_DATE, 'YYYY-MM-DD' )     AS ORDERDATE
     , (SELECT LISTAGG( MODULE, ',' ) WITHIN GROUP (ORDER BY MODULE)
          FROM FNF.USERS_MODULE
         WHERE USERID = U.USERID
           AND MODULE IN ('SMS', 'S-ERP') --대상 시스템만 한정
)                                                AS USERMODULE -- 접근가능 시스템
     , (SELECT LISTAGG( UB.BRAND, ',' ) WITHIN GROUP (ORDER BY UB.BRAND)
          FROM FNF.USERBRAND UB
             , FNF.BRAND B
         WHERE UB.USERID = U.USERID
           AND UB.BRAND = B.BRAND
           AND UB.BRAND NOT IN ('CB')
           AND B.USEYN = 'Y')                    AS USERBRAND  --브랜드 권한
  FROM FNF.USERS U
     , FNF.HR_PERSON P
 WHERE U.EMPNO = P.EMP_NO
   AND P.COMPANY = 'A'           -- A:에프앤에프 법인
   AND U.TYPE_USER IN ('E', 'O') --E:본사직원
   AND U.ONWORKYN = 'Y'          --근무중
   AND U.DELYN = 'N';
