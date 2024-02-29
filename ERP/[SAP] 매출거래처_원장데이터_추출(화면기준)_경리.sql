SELECT A.BRAND
     , A.SHOPCODE
     , A.CALDATE
     , A.SHIP_QTY AS 출고_수량
     , A.SHIP_AMT AS 출고_매출액
     , A.SHIP_VAT AS 출고_부가세
     , A.SHIP_TOTAL AS 출고_합계
     , A.RTN_QTY AS 반품_수량
     , A.RTN_AMT AS 반품_매출액
     , A.RTN_VAT AS 반품_부가세
     , A.RTN_TOTAL AS 반품_합계
     , A.SUPP_QTY AS 비품_수량
     , A.SUPP_AMT AS 비품_매출액
     , A.SUPP_VAT AS 비품_부가세
     , A.SUPP_TOTAL AS 비품_합계
     , A.CRD_CASH AS 대변_현금입금
     , A.CRD_BILL AS 대변_어음입금
     , A.CRD_MILL AS 대변_마일리지입금
     , A.CRD_TOTAL AS 대변_합계
     , SUM( A.BDAMT + A.CAL_AMT ) OVER (PARTITION BY A.BRAND, A.SHOPCODE, TO_CHAR(TO_DATE(A.CALDATE, 'YYYY-MM-DD'), 'YYYY-MM') ORDER BY A.BRAND, A.SHOPCODE, A.CALDATE) AS 잔액
  FROM (SELECT A.BRAND
             , A.SHOPCODE
             , A.CALDATE
             , SUM( A.GOODSQTY ) + SUM( A.PRODUCTSQTY )                                    AS SHIP_QTY
             , SUM( A.GOODSAMT ) + SUM( A.PRODUCTSAMT )                                    AS SHIP_AMT
             , SUM( A.GPVAT )                                                              AS SHIP_VAT
             , SUM( A.GOODSAMT ) + SUM( A.PRODUCTSAMT ) + SUM( A.GPVAT )                   AS SHIP_TOTAL
             , SUM( A.GRETURNQTY ) + SUM( A.PRETURNQTY )                                   AS RTN_QTY
             , SUM( A.GRETURNAMT ) + SUM( A.PRETURNAMT )                                   AS RTN_AMT
             , SUM( A.GPRETURNVAT )                                                        AS RTN_VAT
             , SUM( A.GRETURNAMT ) + SUM( A.PRETURNAMT ) + SUM( A.GPRETURNVAT )            AS RTN_TOTAL
             , SUM( A.SUPPLIESQTY )                                                        AS SUPP_QTY
             , SUM( A.SUPPLIESAMT )                                                        AS SUPP_AMT
             , SUM( A.SUPPLIESVAT )                                                        AS SUPP_VAT
             , SUM( A.SUPPLIESAMT ) + SUM( A.SUPPLIESVAT )                                 AS SUPP_TOTAL
             , SUM( A.CASHINWARD )                                                         AS CRD_CASH
             , SUM( A.NOTEINWARD )                                                         AS CRD_BILL
             , SUM( NVL( A.MILEINWARD, 0 ) )                                               AS CRD_MILL
             , SUM( A.CASHINWARD ) + SUM( A.NOTEINWARD ) + SUM( NVL( A.MILEINWARD, 0 ) )   AS CRD_TOTAL
             , SUM( A.GOODSAMT ) + SUM( A.PRODUCTSAMT ) + SUM( A.GPVAT ) - SUM( A.GRETURNAMT ) - SUM( A.PRETURNAMT ) - SUM( A.CASHINWARD ) - SUM( A.GPRETURNVAT ) - SUM( A.NOTEINWARD ) + SUM( A.SUPPLIESAMT ) + SUM( A.SUPPLIESVAT ) - SUM( NVL( A.MILEINWARD, 0 ) ) AS CAL_AMT
             , A.BDAMT
          FROM CALENDDAYS A
             , CUSTOMS B
             , (SELECT A.BRAND, A.SHOPCODE, MIN( A.CALDATE ) AS CALDATE
                  FROM CALENDDAYS A
                     , CUSTOMS B
                 WHERE A.BRAND IN ('ST','V','A','W')
                   AND B.TYPE_CONTRACT LIKE '%'
--                    AND A.SHOPCODE IN ('10004', '10005')
--                    AND A.CALDATE >= '2023-11-01'
                   AND A.CALDATE <= '2023-12-31'
                   AND A.BDAMT <> 0
                 GROUP BY A.BRAND, A.SHOPCODE) D
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.BRAND = D.BRAND (+)
           AND A.SHOPCODE = D.SHOPCODE (+)
           AND A.CALDATE = D.CALDATE (+)
           AND A.BRAND IN ('ST','V','A','W')
--            AND A.SHOPCODE IN ('10004', '10005')
           AND B.TYPE_CONTRACT LIKE '%'
--            AND A.CALDATE >= '2023-11-01'
           AND A.CALDATE <= '2023-12-31'
         GROUP BY A.BRAND, A.SHOPCODE, A.CALDATE, A.BDAMT
        HAVING SUM( A.GOODSQTY ) <> 0
            OR SUM( A.GOODSAMT ) <> 0
            OR SUM( A.GRETURNQTY ) <> 0
            OR SUM( A.GRETURNAMT ) <> 0
            OR SUM( A.PRODUCTSQTY ) <> 0
            OR SUM( A.PRODUCTSAMT ) <> 0
            OR SUM( A.PRETURNQTY ) <> 0
            OR SUM( A.PRETURNAMT ) <> 0
            OR SUM( A.GPVAT ) <> 0
            OR SUM( A.GPRETURNVAT ) <> 0
            OR SUM( A.SUPPLIESQTY ) <> 0
            OR SUM( A.SUPPLIESAMT ) <> 0
            OR SUM( A.SUPPLIESVAT ) <> 0
            OR SUM( A.BDQTY ) <> 0
            OR SUM( A.BDAMT ) <> 0
            OR SUM( A.CASHINWARD ) <> 0
            OR SUM( A.NOTEINWARD ) <> 0
            OR SUM( NVL( A.MILEINWARD, 0 ) ) <> 0
         ORDER BY A.BRAND, A.SHOPCODE, A.CALDATE) A
;

SELECT TO_CHAR(TO_DATE(A.CALDATE, 'YYYY-MM-DD'), 'YYYY-MM') FROM CALENDDAYS A;