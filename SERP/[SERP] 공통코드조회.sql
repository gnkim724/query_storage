--
/*
 * 공통코드 조회
 * sotransit : 출고상태코드
 * sotype    : 출고유형코드
 */
SELECT A.GRP_CD, A.DTL_CD, B.DTL_CD_NM, A.REM, B.LANG_CD
  FROM ESACDDT A, ESACDDL B
 WHERE 1 = 1
   AND A.SYS_ID = B.SYS_ID
   AND A.GRP_CD = B.GRP_CD
   AND A.DTL_CD = B.DTL_CD
   AND A.USE_YN = 'Y'
   AND B.LANG_CD = 'ko_KR'
   AND A.GRP_CD LIKE '%sotransit%'
   GROUP BY A.GRP_CD, A.DTL_CD, A.REM, B.LANG_CD, B.DTL_CD_NM
   ORDER BY A.GRP_CD, A.DTL_CD;