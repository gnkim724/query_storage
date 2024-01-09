-- 정상/상설 | CAP | FLAT / NON FLAT

-- 1) 정상 / X / NULL
SELECT A.SEASON
     , A.SHOPCODE
     , A.SHORTNAME
     , NVL( T.PARTCODE, A.PARTCODE )
     , A.COLOR
     , SUM( A.TAKEQTY )                      AS TAKEQTY
     , ROUND( SUM( A.TAKEAMT ), 0 )          AS TAKEAMT
     , ROUND( SUM( A.TAKEAMT ) / 954.80, 2 ) AS TAKEUSAMT
  FROM (SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , B.PARTCODE
                     , B.COLOR                                                                       AS COLOR
                     , SUBSTR( A.DUEDATE, 1, 7 )                                                     AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.QTYSHIPED ELSE B.QTYSHIPED * -1 END ) AS QTY
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.AMT ELSE B.AMT * -1 END )             AS AMT
                  FROM INVOICES A
                     , INVITEMS B
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = B.BRAND
                   AND A.SEASON = B.SEASON
                   AND A.SORDERNUM = B.SORDERNUM
                   AND A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND B.BRAND = D.BRAND
                   AND B.SEASON = D.SEASON
                   AND B.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.DUEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND A.STATUS = 'C'
                   AND A.SEASON <> 'X'
                   AND C.TYPE_CONTRACT <> 'C'
                   AND C.TYPE_EDFM <> 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, B.PARTCODE, B.COLOR, SUBSTR( A.DUEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K'
         UNION ALL
        SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , A.PARTCODE
                     , A.COLOR
                     , SUBSTR( A.SALEDATE, 1, 7 )                                                  AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SALETYPE = '1' THEN A.QTY ELSE A.QTY * -1 END )            AS QTY
                     , SUM( ROUND( DECODE( A.SALETYPE, '1', 1, -1 ) * A.ACTUALAMT * 1 / 1.1, 0 ) ) AS AMT
                  FROM SALEITEMS A
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND A.BRAND = D.BRAND
                   AND A.SEASON = D.SEASON
                   AND A.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.SALEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND C.TYPE_CONTRACT = 'C'
                   AND C.TYPE_EDFM <> 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, A.PARTCODE, A.COLOR, SUBSTR( A.SALEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K') A
     , FNF.PARTS B
     , FNF.SC C
     , (SELECT A.BRAND, A.SEASON, A.PARTCODE, A.RYTY_ATTRIBUTE, B.PRODUCT_NO, B.PRODUCT_TYPE
          FROM FNF.PARTS_TS A
             , FNF.RYTY_ATTRIB B
         WHERE 1 = 1
           AND A.RYTY_ATTRIBUTE = B.RYTY_ATTRIBUTE
           AND A.BRAND = B.BRAND
           AND B.ITEM = 'TS') T
 WHERE A.BRAND = B.BRAND
   AND A.SEASON = B.SEASON
   AND A.PARTCODE = B.PARTCODE
   AND A.BRAND = C.BRAND
   AND A.SEASON = C.SEASON
   AND A.PARTCODE = C.PARTCODE
   AND A.COLOR = C.COLOR
   AND NVL( T.RYTY_ATTRIBUTE, B.RYTY_ATTRIB ) = '10053527'
   AND NVL( C.TS_RYTY_ASSET, C.RYTY_ASSET ) = 'STL'
   AND DECODE( B.SOLDVAT, NULL, 'Y', B.SOLDVAT ) IN ('Y', 'R', 'F', 'H')
   AND B.BRAND = T.BRAND (+)
   AND B.SEASON = T.SEASON (+)
   AND B.TS = T.PARTCODE (+)
 GROUP BY A.SEASON, A.SHOPCODE, A.SHORTNAME, NVL( T.PARTCODE, A.PARTCODE ), A.COLOR
HAVING SUM( A.TAKEQTY ) <> 0
    OR SUM( A.TAKEAMT ) <> 0;

-- 1-1) 상설 / X / NULL
SELECT A.SEASON
     , A.SHOPCODE
     , A.SHORTNAME
     , NVL( T.PARTCODE, A.PARTCODE )
     , A.COLOR
     , SUM( A.TAKEQTY )                      AS TAKEQTY
     , ROUND( SUM( A.TAKEAMT ), 0 )          AS TAKEAMT
     , ROUND( SUM( A.TAKEAMT ) / 954.80, 2 ) AS TAKEUSAMT
  FROM (SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , B.PARTCODE
                     , B.COLOR                                                                       AS COLOR
                     , SUBSTR( A.DUEDATE, 1, 7 )                                                     AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.QTYSHIPED ELSE B.QTYSHIPED * -1 END ) AS QTY
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.AMT ELSE B.AMT * -1 END )             AS AMT
                  FROM INVOICES A
                     , INVITEMS B
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = B.BRAND
                   AND A.SEASON = B.SEASON
                   AND A.SORDERNUM = B.SORDERNUM
                   AND A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND B.BRAND = D.BRAND
                   AND B.SEASON = D.SEASON
                   AND B.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.DUEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND A.STATUS = 'C'
                   AND A.SEASON <> 'X'
                   AND C.TYPE_CONTRACT <> 'C'
                   AND C.TYPE_EDFM = 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, B.PARTCODE, B.COLOR, SUBSTR( A.DUEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K'
         UNION ALL
        SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , A.PARTCODE
                     , A.COLOR
                     , SUBSTR( A.SALEDATE, 1, 7 )                                                  AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SALETYPE = '1' THEN A.QTY ELSE A.QTY * -1 END )            AS QTY
                     , SUM( ROUND( DECODE( A.SALETYPE, '1', 1, -1 ) * A.ACTUALAMT * 1 / 1.1, 0 ) ) AS AMT
                  FROM SALEITEMS A
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND A.BRAND = D.BRAND
                   AND A.SEASON = D.SEASON
                   AND A.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.SALEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND C.TYPE_CONTRACT = 'C'
                   AND C.TYPE_EDFM = 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, A.PARTCODE, A.COLOR, SUBSTR( A.SALEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K') A
     , FNF.PARTS B
     , FNF.SC C
     , (SELECT A.BRAND, A.SEASON, A.PARTCODE, A.RYTY_ATTRIBUTE, B.PRODUCT_NO, B.PRODUCT_TYPE
          FROM FNF.PARTS_TS A
             , FNF.RYTY_ATTRIB B
         WHERE 1 = 1
           AND A.RYTY_ATTRIBUTE = B.RYTY_ATTRIBUTE
           AND A.BRAND = B.BRAND
           AND B.ITEM = 'TS') T
 WHERE A.BRAND = B.BRAND
   AND A.SEASON = B.SEASON
   AND A.PARTCODE = B.PARTCODE
   AND A.BRAND = C.BRAND
   AND A.SEASON = C.SEASON
   AND A.PARTCODE = C.PARTCODE
   AND A.COLOR = C.COLOR
   AND NVL( T.RYTY_ATTRIBUTE, B.RYTY_ATTRIB ) = '10060744'
   AND NVL( C.TS_RYTY_ASSET, C.RYTY_ASSET ) = 'STL'
   AND DECODE( B.SOLDVAT, NULL, 'Y', B.SOLDVAT ) IN ('Y', 'R', 'F', 'H')
   AND B.BRAND = T.BRAND (+)
   AND B.SEASON = T.SEASON (+)
   AND B.TS = T.PARTCODE (+)
 GROUP BY A.SEASON, A.SHOPCODE, A.SHORTNAME, NVL( T.PARTCODE, A.PARTCODE ), A.COLOR
HAVING SUM( A.TAKEQTY ) <> 0
    OR SUM( A.TAKEAMT ) <> 0;

-----------------------------------------

-- 2) 정상 / O / FLAT
SELECT A.SEASON
     , A.SHOPCODE
     , A.SHORTNAME
     , NVL( T.PARTCODE, A.PARTCODE )
     , A.COLOR
     , SUM( A.TAKEQTY )                      AS TAKEQTY
     , ROUND( SUM( A.TAKEAMT ), 0 )          AS TAKEAMT
     , ROUND( SUM( A.TAKEAMT ) / 954.80, 2 ) AS TAKEUSAMT
  FROM (SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , B.PARTCODE
                     , B.COLOR                                                                       AS COLOR
                     , SUBSTR( A.DUEDATE, 1, 7 )                                                     AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.QTYSHIPED ELSE B.QTYSHIPED * -1 END ) AS QTY
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.AMT ELSE B.AMT * -1 END )             AS AMT
                  FROM INVOICES A
                     , INVITEMS B
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = B.BRAND
                   AND A.SEASON = B.SEASON
                   AND A.SORDERNUM = B.SORDERNUM
                   AND A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND B.BRAND = D.BRAND
                   AND B.SEASON = D.SEASON
                   AND B.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.DUEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND A.STATUS = 'C'
                   AND A.SEASON <> 'X'
                   AND C.TYPE_CONTRACT <> 'C'
                   AND NVL( D.MLB_CAP_TYPE, '1' ) = '2'
                   AND C.TYPE_EDFM <> 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, B.PARTCODE, B.COLOR, SUBSTR( A.DUEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K'
         UNION ALL
        SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , A.PARTCODE
                     , A.COLOR
                     , SUBSTR( A.SALEDATE, 1, 7 )                                                  AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SALETYPE = '1' THEN A.QTY ELSE A.QTY * -1 END )            AS QTY
                     , SUM( ROUND( DECODE( A.SALETYPE, '1', 1, -1 ) * A.ACTUALAMT * 1 / 1.1, 0 ) ) AS AMT
                  FROM SALEITEMS A
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND A.BRAND = D.BRAND
                   AND A.SEASON = D.SEASON
                   AND A.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.SALEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND C.TYPE_CONTRACT = 'C'
                   AND NVL( D.MLB_CAP_TYPE, '1' ) = '2'
                   AND C.TYPE_EDFM <> 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, A.PARTCODE, A.COLOR, SUBSTR( A.SALEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K') A
     , FNF.PARTS B
     , FNF.SC C
     , (SELECT A.BRAND, A.SEASON, A.PARTCODE, A.RYTY_ATTRIBUTE, B.PRODUCT_NO, B.PRODUCT_TYPE
          FROM FNF.PARTS_TS A
             , FNF.RYTY_ATTRIB B
         WHERE 1 = 1
           AND A.RYTY_ATTRIBUTE = B.RYTY_ATTRIBUTE
           AND A.BRAND = B.BRAND
           AND B.ITEM = 'TS') T
 WHERE A.BRAND = B.BRAND
   AND A.SEASON = B.SEASON
   AND A.PARTCODE = B.PARTCODE
   AND A.BRAND = C.BRAND
   AND A.SEASON = C.SEASON
   AND A.PARTCODE = C.PARTCODE
   AND A.COLOR = C.COLOR
   AND NVL( B.MLB_CAP_TYPE, '1' ) = '2'
   AND NVL( T.RYTY_ATTRIBUTE, B.RYTY_ATTRIB ) = '10065153'
   AND NVL( C.TS_RYTY_ASSET, C.RYTY_ASSET ) = 'LA'
   AND DECODE( B.SOLDVAT, NULL, 'Y', B.SOLDVAT ) IN ('Y', 'R', 'F', 'H')
   AND B.BRAND = T.BRAND (+)
   AND B.SEASON = T.SEASON (+)
   AND B.TS = T.PARTCODE (+)
 GROUP BY A.SEASON, A.SHOPCODE, A.SHORTNAME, NVL( T.PARTCODE, A.PARTCODE ), A.COLOR
HAVING SUM( A.TAKEQTY ) <> 0
    OR SUM( A.TAKEAMT ) <> 0;

-- 2-1) 상설 / O / FLAT
SELECT A.SEASON
     , A.SHOPCODE
     , A.SHORTNAME
     , NVL( T.PARTCODE, A.PARTCODE )
     , A.COLOR
     , SUM( A.TAKEQTY )                      AS TAKEQTY
     , ROUND( SUM( A.TAKEAMT ), 0 )          AS TAKEAMT
     , ROUND( SUM( A.TAKEAMT ) / 954.80, 2 ) AS TAKEUSAMT
  FROM (SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , B.PARTCODE
                     , B.COLOR                                                                       AS COLOR
                     , SUBSTR( A.DUEDATE, 1, 7 )                                                     AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.QTYSHIPED ELSE B.QTYSHIPED * -1 END ) AS QTY
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.AMT ELSE B.AMT * -1 END )             AS AMT
                  FROM INVOICES A
                     , INVITEMS B
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = B.BRAND
                   AND A.SEASON = B.SEASON
                   AND A.SORDERNUM = B.SORDERNUM
                   AND A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND B.BRAND = D.BRAND
                   AND B.SEASON = D.SEASON
                   AND B.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.DUEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND A.STATUS = 'C'
                   AND A.SEASON <> 'X'
                   AND C.TYPE_CONTRACT <> 'C'
                   AND NVL( D.MLB_CAP_TYPE, '1' ) = '2'
                   AND C.TYPE_EDFM = 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, B.PARTCODE, B.COLOR, SUBSTR( A.DUEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K'
         UNION ALL
        SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , A.PARTCODE
                     , A.COLOR
                     , SUBSTR( A.SALEDATE, 1, 7 )                                                  AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SALETYPE = '1' THEN A.QTY ELSE A.QTY * -1 END )            AS QTY
                     , SUM( ROUND( DECODE( A.SALETYPE, '1', 1, -1 ) * A.ACTUALAMT * 1 / 1.1, 0 ) ) AS AMT
                  FROM SALEITEMS A
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND A.BRAND = D.BRAND
                   AND A.SEASON = D.SEASON
                   AND A.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.SALEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND C.TYPE_CONTRACT = 'C'
                   AND NVL( D.MLB_CAP_TYPE, '1' ) = '2'
                   AND C.TYPE_EDFM = 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, A.PARTCODE, A.COLOR, SUBSTR( A.SALEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K') A
     , FNF.PARTS B
     , FNF.SC C
     , (SELECT A.BRAND, A.SEASON, A.PARTCODE, A.RYTY_ATTRIBUTE, B.PRODUCT_NO, B.PRODUCT_TYPE
          FROM FNF.PARTS_TS A
             , FNF.RYTY_ATTRIB B
         WHERE 1 = 1
           AND A.RYTY_ATTRIBUTE = B.RYTY_ATTRIBUTE
           AND A.BRAND = B.BRAND
           AND B.ITEM = 'TS') T
 WHERE A.BRAND = B.BRAND
   AND A.SEASON = B.SEASON
   AND A.PARTCODE = B.PARTCODE
   AND A.BRAND = C.BRAND
   AND A.SEASON = C.SEASON
   AND A.PARTCODE = C.PARTCODE
   AND A.COLOR = C.COLOR
   AND NVL( B.MLB_CAP_TYPE, '1' ) = '2'
   AND NVL( T.RYTY_ATTRIBUTE, B.RYTY_ATTRIB ) = '10065153'
   AND NVL( C.TS_RYTY_ASSET, C.RYTY_ASSET ) = 'LA'
   AND DECODE( B.SOLDVAT, NULL, 'Y', B.SOLDVAT ) IN ('Y', 'R', 'F', 'H')
   AND B.BRAND = T.BRAND (+)
   AND B.SEASON = T.SEASON (+)
   AND B.TS = T.PARTCODE (+)
 GROUP BY A.SEASON, A.SHOPCODE, A.SHORTNAME, NVL( T.PARTCODE, A.PARTCODE ), A.COLOR
HAVING SUM( A.TAKEQTY ) <> 0
    OR SUM( A.TAKEAMT ) <> 0;

-----------------------------------------

-- 3) 정상 / O / NON FLAT
SELECT A.SEASON
     , A.SHOPCODE
     , A.SHORTNAME
     , NVL( T.PARTCODE, A.PARTCODE )
     , A.COLOR
     , SUM( A.TAKEQTY )                      AS TAKEQTY
     , ROUND( SUM( A.TAKEAMT ), 0 )          AS TAKEAMT
     , ROUND( SUM( A.TAKEAMT ) / 954.80, 2 ) AS TAKEUSAMT
  FROM (SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , B.PARTCODE
                     , B.COLOR                                                                       AS COLOR
                     , SUBSTR( A.DUEDATE, 1, 7 )                                                     AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.QTYSHIPED ELSE B.QTYSHIPED * -1 END ) AS QTY
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.AMT ELSE B.AMT * -1 END )             AS AMT
                  FROM INVOICES A
                     , INVITEMS B
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = B.BRAND
                   AND A.SEASON = B.SEASON
                   AND A.SORDERNUM = B.SORDERNUM
                   AND A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND B.BRAND = D.BRAND
                   AND B.SEASON = D.SEASON
                   AND B.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.DUEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND A.STATUS = 'C'
                   AND A.SEASON <> 'X'
                   AND C.TYPE_CONTRACT <> 'C'
                   AND NVL( D.MLB_CAP_TYPE, '1' ) = '1'
                   AND C.TYPE_EDFM <> 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, B.PARTCODE, B.COLOR, SUBSTR( A.DUEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K'
         UNION ALL
        SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , A.PARTCODE
                     , A.COLOR
                     , SUBSTR( A.SALEDATE, 1, 7 )                                                  AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SALETYPE = '1' THEN A.QTY ELSE A.QTY * -1 END )            AS QTY
                     , SUM( ROUND( DECODE( A.SALETYPE, '1', 1, -1 ) * A.ACTUALAMT * 1 / 1.1, 0 ) ) AS AMT
                  FROM SALEITEMS A
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND A.BRAND = D.BRAND
                   AND A.SEASON = D.SEASON
                   AND A.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.SALEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND C.TYPE_CONTRACT = 'C'
                   AND NVL( D.MLB_CAP_TYPE, '1' ) = '1'
                   AND C.TYPE_EDFM <> 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, A.PARTCODE, A.COLOR, SUBSTR( A.SALEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K') A
     , FNF.PARTS B
     , FNF.SC C
     , (SELECT A.BRAND, A.SEASON, A.PARTCODE, A.RYTY_ATTRIBUTE, B.PRODUCT_NO, B.PRODUCT_TYPE
          FROM FNF.PARTS_TS A
             , FNF.RYTY_ATTRIB B
         WHERE 1 = 1
           AND A.RYTY_ATTRIBUTE = B.RYTY_ATTRIBUTE
           AND A.BRAND = B.BRAND
           AND B.ITEM = 'TS') T
 WHERE A.BRAND = B.BRAND
   AND A.SEASON = B.SEASON
   AND A.PARTCODE = B.PARTCODE
   AND A.BRAND = C.BRAND
   AND A.SEASON = C.SEASON
   AND A.PARTCODE = C.PARTCODE
   AND A.COLOR = C.COLOR
   AND NVL( B.MLB_CAP_TYPE, '1' ) = '1'
   AND NVL( T.RYTY_ATTRIBUTE, B.RYTY_ATTRIB ) = '10072128'
   AND NVL( C.TS_RYTY_ASSET, C.RYTY_ASSET ) = 'STL'
   AND DECODE( B.SOLDVAT, NULL, 'Y', B.SOLDVAT ) IN ('Y', 'R', 'F', 'H')
   AND B.BRAND = T.BRAND (+)
   AND B.SEASON = T.SEASON (+)
   AND B.TS = T.PARTCODE (+)
 GROUP BY A.SEASON, A.SHOPCODE, A.SHORTNAME, NVL( T.PARTCODE, A.PARTCODE ), A.COLOR
HAVING SUM( A.TAKEQTY ) <> 0
    OR SUM( A.TAKEAMT ) <> 0;

-- 3-1) 상설 / O / NON FLAT
SELECT A.SEASON
     , A.SHOPCODE
     , A.SHORTNAME
     , NVL( T.PARTCODE, A.PARTCODE )
     , A.COLOR
     , SUM( A.TAKEQTY )                      AS TAKEQTY
     , ROUND( SUM( A.TAKEAMT ), 0 )          AS TAKEAMT
     , ROUND( SUM( A.TAKEAMT ) / 954.80, 2 ) AS TAKEUSAMT
  FROM (SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , B.PARTCODE
                     , B.COLOR                                                                       AS COLOR
                     , SUBSTR( A.DUEDATE, 1, 7 )                                                     AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.QTYSHIPED ELSE B.QTYSHIPED * -1 END ) AS QTY
                     , SUM( CASE WHEN A.SOTYPE <= '500' THEN B.AMT ELSE B.AMT * -1 END )             AS AMT
                  FROM INVOICES A
                     , INVITEMS B
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = B.BRAND
                   AND A.SEASON = B.SEASON
                   AND A.SORDERNUM = B.SORDERNUM
                   AND A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND B.BRAND = D.BRAND
                   AND B.SEASON = D.SEASON
                   AND B.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.DUEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND A.STATUS = 'C'
                   AND A.SEASON <> 'X'
                   AND C.TYPE_CONTRACT <> 'C'
                   AND NVL( D.MLB_CAP_TYPE, '1' ) = '1'
                   AND C.TYPE_EDFM = 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, B.PARTCODE, B.COLOR, SUBSTR( A.DUEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K'
         UNION ALL
        SELECT A.BRAND
             , A.SEASON
             , A.SHOPCODE
             , C.SHORTNAME
             , A.PARTCODE
             , A.COLOR
             , A.QTY AS TAKEQTY
             , A.AMT AS TAKEAMT
          FROM (SELECT A.BRAND
                     , A.SEASON
                     , A.PARTCODE
                     , A.COLOR
                     , SUBSTR( A.SALEDATE, 1, 7 )                                                  AS YYYYMM
                     , A.SHOPCODE
                     , SUM( CASE WHEN A.SALETYPE = '1' THEN A.QTY ELSE A.QTY * -1 END )            AS QTY
                     , SUM( ROUND( DECODE( A.SALETYPE, '1', 1, -1 ) * A.ACTUALAMT * 1 / 1.1, 0 ) ) AS AMT
                  FROM SALEITEMS A
                     , CUSTOMS C
                     , PARTS D
                 WHERE A.BRAND = C.BRAND
                   AND A.SHOPCODE = C.SHOPCODE
                   AND A.BRAND = D.BRAND
                   AND A.SEASON = D.SEASON
                   AND A.PARTCODE = D.PARTCODE
                   AND A.BRAND = 'M'
                   AND A.SALEDATE BETWEEN '2023-06-01' AND '2023-06-30'
                   AND C.TYPE_CONTRACT = 'C'
                   AND NVL( D.MLB_CAP_TYPE, '1' ) = '1'
                   AND C.TYPE_EDFM = 'D'
                   AND NVL( D.NONM, 'N' ) = 'N'
                 GROUP BY A.BRAND, A.SEASON, A.PARTCODE, A.COLOR, SUBSTR( A.SALEDATE, 1, 7 ), A.SHOPCODE) A
             , FNF.CUSTOMS_YYYYMM B
             , FNF.CUSTOMS C
         WHERE A.BRAND = B.BRAND
           AND A.SHOPCODE = B.SHOPCODE
           AND A.YYYYMM = B.YYYYMM
           AND A.BRAND = C.BRAND
           AND A.SHOPCODE = C.SHOPCODE
           AND B.RYTY_INCLUDE = 'N'
           AND B.RYTY_PARTY = 'K') A
     , FNF.PARTS B
     , FNF.SC C
     , (SELECT A.BRAND, A.SEASON, A.PARTCODE, A.RYTY_ATTRIBUTE, B.PRODUCT_NO, B.PRODUCT_TYPE
          FROM FNF.PARTS_TS A
             , FNF.RYTY_ATTRIB B
         WHERE 1 = 1
           AND A.RYTY_ATTRIBUTE = B.RYTY_ATTRIBUTE
           AND A.BRAND = B.BRAND
           AND B.ITEM = 'TS') T
 WHERE A.BRAND = B.BRAND
   AND A.SEASON = B.SEASON
   AND A.PARTCODE = B.PARTCODE
   AND A.BRAND = C.BRAND
   AND A.SEASON = C.SEASON
   AND A.PARTCODE = C.PARTCODE
   AND A.COLOR = C.COLOR
   AND NVL( B.MLB_CAP_TYPE, '1' ) = '1'
   AND NVL( T.RYTY_ATTRIBUTE, B.RYTY_ATTRIB ) = '10072125'
   AND NVL( C.TS_RYTY_ASSET, C.RYTY_ASSET ) = 'LA'
   AND DECODE( B.SOLDVAT, NULL, 'Y', B.SOLDVAT ) IN ('Y', 'R', 'F', 'H')
   AND B.BRAND = T.BRAND (+)
   AND B.SEASON = T.SEASON (+)
   AND B.TS = T.PARTCODE (+)
 GROUP BY A.SEASON, A.SHOPCODE, A.SHORTNAME, NVL( T.PARTCODE, A.PARTCODE ), A.COLOR
HAVING SUM( A.TAKEQTY ) <> 0
    OR SUM( A.TAKEAMT ) <> 0;


/*

정상 / 상설
    C.TYPE_EDFM <> 'D' (정상)
    C.TYPE_EDFM = 'D' (상설)


NULL / FLAT / NON FLAT
    NULL     -> 없음
    FLAT     -> NVL( D.MLB_CAP_TYPE, '1' ) = '2'
    NON FLAT -> NVL( D.MLB_CAP_TYPE, '1' ) = '1'

*/

