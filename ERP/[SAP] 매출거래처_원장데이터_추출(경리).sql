-- SAP 웅진 매출거래처 원장 데이터 추출 건 (경리)
SELECT A.BRAND
     , A.CALDATE
     , A.SHOPCODE
     , SUM( A.GOODSQTY )
     , SUM( A.GOODSAMT )
     , SUM( A.GRETURNQTY )
     , SUM( A.GRETURNAMT )
     , SUM( A.PRODUCTSQTY )
     , SUM( A.PRODUCTSAMT )
     , SUM( A.PRETURNQTY )
     , SUM( A.PRETURNAMT )
     , SUM( A.GPVAT )
     , SUM( A.GPRETURNVAT )
     , SUM( A.SUPPLIESQTY )
     , SUM( A.SUPPLIESAMT )
     , SUM( A.SUPPLIESVAT )
     , SUM( A.BDQTY )
     , SUM( CASE WHEN A.CALDATE = D.CALDATE THEN A.BDAMT ELSE 0 END )
     , SUM( A.CASHINWARD )
     , SUM( A.NOTEINWARD )
     , SUM( NVL( A.MILEINWARD, 0 ) )
  FROM CALENDDAYS A
     , CUSTOMS B
     , (SELECT A.BRAND, A.SHOPCODE, MIN( A.CALDATE ) AS CALDATE
          FROM CALENDDAYS A
             , CUSTOMS B
         WHERE 1 = 1
           AND A.BRAND IN ('X',
                           'M',
                           'I',
                           'A',
                           'V',
                           'ST',
                           'W')
           AND B.TYPE_CONTRACT LIKE '%'
           AND A.CALDATE <= '2023-12-31'
           AND A.BDAMT <> 0
         GROUP BY A.BRAND, A.SHOPCODE) D
 WHERE 1 = 1
   AND A.BRAND = B.BRAND
   AND A.SHOPCODE = B.SHOPCODE
   AND A.BRAND = D.BRAND(+)
   AND A.SHOPCODE = D.SHOPCODE(+)
   AND A.CALDATE = D.CALDATE(+)
   AND A.BRAND IN ('X',
                   'M',
                   'I',
                   'A',
                   'V',
                   'ST',
                   'W')
   AND B.TYPE_CONTRACT LIKE '%'
   AND A.CALDATE <= '2023-12-31'
 GROUP BY A.BRAND, A.SHOPCODE, B.SHOPNAME, B.SHORTNAME, A.CALDATE
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
 ORDER BY A.BRAND DESC, A.SHOPCODE, A.CALDATE;
