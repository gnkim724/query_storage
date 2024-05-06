/******************************************
            ERP PB명으로 메뉴 조회
*******************************************/
-- ERP PB명으로 메뉴 조회
SELECT *
  FROM MENU
 WHERE 1 = 1
   AND NAME_KOR LIKE '%품번별 재고현황%'
   AND MOFF = 'N';

SELECT DISTINCT CASE
                    WHEN B.TREELEVEL = '2' THEN (SELECT NAME_KOR FROM FNF.MENU WHERE MENUCODE = B.MENU_PARENT)
                END        AS LV1
              , B.NAME_KOR AS LV2
              , A.NAME_KOR AS LV3
              , A.WINDOW   AS PB명
  FROM (SELECT * FROM FNF.MENU WHERE 1 = 1 AND WINDOW = 'w_sa061_tax_print_rfid' AND MOFF = 'N') A
     , FNF.MENU B
 WHERE 1 = 1
   AND B.MENUCODE = A.MENU_PARENT
;


