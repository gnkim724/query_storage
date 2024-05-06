/**
  유저별 메뉴 권한 부여 작업
 */
SELECT *
  FROM USERS
 WHERE 1 = 1
   AND USERID IN ('cnsfc09', 'cnsfc10', 'cnsfc12');

SELECT *
  FROM USERS
 WHERE 1 = 1
   AND USERID = 'cnsfc09';


-- ERP 메뉴 구성
SELECT *
  FROM FNF.MENU;

-- ERP 메뉴 권한 코드표
SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'menu_unitcode';

-- ERP 메뉴 권한
SELECT *
  FROM FNF.USERPERMISSION
 WHERE 1 = 1
   AND USERID IN ('cnsfc09', 'cnsfc10', 'cnsfc12')
 ORDER BY BU_UNITCODE;

-- ERP 메뉴 권한 변경 로그
SELECT *
  FROM FNF.USERPERMISSION_LOG;

