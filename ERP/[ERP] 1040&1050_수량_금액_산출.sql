-- 1040 출고 금액 확인
SELECT SUM( CASE
                WHEN A.SOTYPE <= '500' THEN B.QTYSHIPED
                                       ELSE B.QTYSHIPED * -1
            END )                                                        AS 출고수량
     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.AMT ELSE B.AMT * -1 END ) AS 출고금액
     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.VAT ELSE B.VAT * -1 END ) AS VAT
  FROM FNF.INVOICES A
     , FNF.INVITEMS B
 WHERE 1 = 1
   AND A.BRAND = B.BRAND
   AND A.SEASON = B.SEASON
   AND A.SORDERNUM = B.SORDERNUM
   AND A.BRAND = 'X'
   AND A.SHOPCODE = '11008'
   AND A.DUEDATE BETWEEN '2024-01-01' AND '2024-01-31'
   AND A.STATUS <> 'D';


-- 1050 판매 금액 확인
SELECT SUM( CASE WHEN A.SALETYPE = '1' THEN A.QTY ELSE A.QTY * -1 END ) AS 수량
     , SUM( CASE
                WHEN A.SALETYPE = '1' THEN A.ACTUALAMT
                                      ELSE A.ACTUALAMT * -1
            END )                                                       AS 판매금액
  FROM FNF.SALEITEMS A
 WHERE 1 = 1
   AND A.BRAND = 'X'
   AND A.SALEDATE BETWEEN '2024-01-01' AND '2024-01-31'
   AND A.SHOPCODE = '11008';