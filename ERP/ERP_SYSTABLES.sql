/*
SYSTABLES
*/

-- mainERP 메뉴 코드
SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'menu_unitcode'
 ORDER BY TBLCODE;

-- mainERP 메뉴 권한 등급
SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'menu_permission'
 ORDER BY TBLCODE;

-- mainERP INVOICE_TYPE
SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'invoicetype'
 ORDER BY TBLCODE;

-- mainERP SOTYPE
SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'sotype'
 ORDER BY TBLCODE;

-- mainERP accounttype (상품, 제품, 저장품) 코드
SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'accounttype';

-- mainERP 제품오더상태 코드
SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'product_order_status';

SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'saletrtype'
 ORDER BY TBLCODE;

-- SAP 이동코드
SELECT *
  FROM SYSTABLES
 WHERE TBLNAME = 'sap_move_code'
 ORDER BY TBLCODE;

-- SMS 매장재고 제한 관련
SELECT ROWID, A.*
  FROM SYSTABLES A
 WHERE TBLNAME = 'groupsales_ratio';

-- 매장구분
SELECT *
  FROM SYSTABLES A
 WHERE A.TBLNAME = 'type_shop';

-- 매장 type_zone
SELECT *
  FROM SYSTABLES A
 WHERE A.TBLNAME = 'type_zone';