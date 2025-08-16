/* isp.findDueSearchList: 업체실사 조회 화면 목록 */

  SELECT BSS.BRAND_CD
       , BSS.INSTR_DE
       , BSS.STCKT_DE
       , BSS.SHOP_CD
       , SM.MNG_ID
       , BSS.INSTR_NO
       , BSS.STK_INVES_TYP_CD
       , BSS.TERM_YN
       , LISTAGG (DISTINCT BSS.SSN_CD, ',')
             WITHIN GROUP (ORDER BY SSN.SORT ASC)        AS SSN_CD
       , (SELECT MIN (FC_GET_NAME ('USER'
                                 , INSR_ID
                                 , 'FNF'
                                 , 'ko_KR'
                                 , ''
                                 , 'C100'
                                 , ''
                                 , ''
                                 , ''
                                 , ''))
            FROM BIM_STK_STCKT
           WHERE INSTR_NO = BSS.INSTR_NO
             AND INS_DT = (SELECT MIN (INS_DT)
                             FROM BIM_STK_STCKT
                            WHERE INSTR_NO = BSS.INSTR_NO
                              AND USE_YN = 'Y')
             AND USE_YN = 'Y')                           AS INSR_NM
       , CASE
             WHEN BSS.TERM_YN = 'Y' THEN '종결'
             WHEN BSS.RFID_DL_YN = 'Y' THEN '확정'
             ELSE '진행중'
         END                                             AS STK_STS /* 종결여부 */
       , BSS.STCKT_DIV_CD                               /* 실사 구분 코드(업체, 요청) */
       , BSS.INSTR_DEG
       , (SELECT MAX (SHOP_ABBR_NM)
            FROM BIM_SHOP A
           WHERE A.USE_YN = 'Y'
             AND A.SHOP_CD = BSS.SHOP_CD
             AND A.BRAND_CD = BSS.BRAND_CD)              SHOP_NM
       , FC_GET_NAME ('SHOP_ABBR'
                    , BSS.SHOP_CD
                    , ''
                    , ''
                    , ''
                    , ''
                    , BSS.BRAND_CD
                    , ''
                    , ''
                    , '')                                AS SHOP_ABBR_NM
       , (SELECT MAX (SHOP_CTRT_TYP_CD)
            FROM BIM_SHOP A
           WHERE A.USE_YN = 'Y'
             AND A.SHOP_CD = BSS.SHOP_CD
             AND A.BRAND_CD = BSS.BRAND_CD)              SHOP_CTRT_TYP_CD
       , (SELECT MAX (S.CLASS_NM5)
            FROM BIM_SHOP A                                            -- 매장정보
               , (           SELECT REGEXP_SUBSTR (SYS_CONNECT_BY_PATH (SHOP_CLS_CD, '/')
                                                 , '[^/]+'
                                                 , 1
                                                 , 2)    AS CLASS_CD2
                                  , REGEXP_SUBSTR (SYS_CONNECT_BY_PATH (SHOP_CLS_CD, '/')
                                                 , '[^/]+'
                                                 , 1
                                                 , 3)    AS CLASS_CD3
                                  , REGEXP_SUBSTR (SYS_CONNECT_BY_PATH (SHOP_CLS_CD, '/')
                                                 , '[^/]+'
                                                 , 1
                                                 , 4)    AS CLASS_CD4
                                  , REGEXP_SUBSTR (SYS_CONNECT_BY_PATH (SHOP_CLS_CD, '/')
                                                 , '[^/]+'
                                                 , 1
                                                 , 5)    AS CLASS_CD5
                                  , REGEXP_SUBSTR (SYS_CONNECT_BY_PATH (SHOP_CLS_NM, '/')
                                                 , '[^/]+'
                                                 , 1
                                                 , 5)    AS CLASS_NM5
                               FROM BIM_SHOP_CLS
                              WHERE CONNECT_BY_ISLEAF = 1
                                AND USE_YN = 'Y'
                         START WITH SHOP_CLS_CD = '100'
                                AND LV = 1
                         CONNECT BY PRIOR SHOP_CLS_SNO = UPER_SHOP_CLS_SNO
                  ORDER SIBLINGS BY SORT ASC) S
           WHERE A.USE_YN = 'Y'
             AND A.SHOP_TRD_TYP_CD = 'A' -- SHOP_TRD_TYP_CD : A(일반매장) , B(중간관리자)
             AND A.SHOP_TRD_TYP_CD = S.CLASS_CD2
             AND A.SHOP_MGMT_TYP_CD = S.CLASS_CD3
             AND A.PROD_TRD_TYP_CD = S.CLASS_CD4
             AND A.SHOP_CTRT_TYP_CD = S.CLASS_CD5
             AND A.SHOP_CD = BSS.SHOP_CD
             AND A.BRAND_CD = BSS.BRAND_CD)              SHOP_CTRT_TYP_NM
       , (SELECT NVL (
                     SUM (
                           PROD.SALE_PRC
                         * (  A.STD_STK_QTY
                            - (  NVL (
                                       A.STCKT_QTY
                                     + A.RT_TRS_QTY
                                     + A.RPR_QTY
                                     + A.RTN_QTY
                                     + A.GI_QTY
                                     + A.PRI_SALE_QTY
                                   , 0)
                               + A.ADJ_QTY)))
                   , 0)
            FROM BIM_STK_STCKT_DTL A
                 INNER JOIN BIM_STK_STCKT B ON B.STCKT_SNO = A.STCKT_SNO
                 INNER JOIN BIM_PROD PROD
                     ON PROD.BRAND_CD = B.BRAND_CD
                    AND PROD.SSN_CD = B.SSN_CD
                    AND PROD.PROD_CD = A.PROD_CD
           WHERE A.USE_YN = 'Y'
             AND B.USE_YN = 'Y'
             AND PROD.USE_YN = 'Y'
             AND B.INSTR_NO = BSS.INSTR_NO
             AND B.SHOP_CD = BSS.SHOP_CD)                AS SUM_GAP_QTY
       , SUM (SMR.STK_TOT_QTY)                           AS STD_STK_QTY
       , MAX (TO_CHAR (BSS.STD_STK_DT, 'YYYY-MM-DD'))    AS STD_STK_DT
       ,    BSI.STA_DE
         || ' ~ '
         || BSI.END_DE                                   AS EXP_PERIOD
       , BSI.REQR_NM
       , MAX (BSS.STMT_DT)                               AS STMT_DT
       , BSS.APRV_STS_CD
       , CASE
             WHEN (SELECT COUNT (*)
                     FROM BIM_STK_STCKT
                    WHERE INSTR_NO = BSS.INSTR_NO
                      AND SHOP_CD = BSS.SHOP_CD
                      AND USE_YN = 'Y'
                      AND (NVL (STMT_STS_CD, 'N') = 'N'
                        OR NVL (STMT_STS_CD, 'N') = 'E')
                      AND NVL (STMT_DIV_CD, 'XXX') != 'X') > 0
             THEN
                 'N'
             ELSE
                 'Y'
         END                                             AS STMT_STS_CD
       , TO_CHAR (BSS.ADJ_DT, 'YYYY-MM-DD')              AS ADJ_DT
       , (SELECT CASE WHEN COUNT (*) > 0 THEN 'Y' ELSE 'N' END    AS EXIST_ADJ_QTY
            FROM BIM_STK_STCKT_ADJ
           WHERE INSTR_NO = BSS.INSTR_NO
             AND USE_YN = 'Y'
             AND ADJ_STS_CD = 'R')                       AS EXIST_ADJ_QTY
       , BSS.RFID_DL_YN
       , BSS.CFM_YN
       , (SELECT MAX (INTRA_APRV_NO)
            FROM BIM_APRV
           WHERE USE_YN = 'Y'
             AND APRV_SNO = BSS.INSTR_NO)                AS INTRA_APRV_NO
       , (SELECT MAX (ADJ_REQ_STS_CD)
            FROM BIM_STK_STCKT_ADJ
           WHERE USE_YN = 'Y'
             AND INSTR_NO = BSS.INSTR_NO)                AS ADJ_REQ_STS_CD
    FROM BIM_STK_STCKT BSS
         LEFT OUTER JOIN (SELECT A.INSTR_NO
                               , A.STA_DE
                               , A.END_DE
                               , A.REQR_NM
                            FROM BIM_STK_INVES A, BIM_STK_INVES_SHOP B
                           WHERE A.INSTR_NO = B.INSTR_NO
                             AND A.USE_YN = 'Y'
                             AND B.USE_YN = 'Y') BSI
             ON BSI.INSTR_NO = BSS.ORIG_INSTR_NO
         LEFT OUTER JOIN BIM_SSN SSN
             ON SSN.SSN_CD = BSS.SSN_CD
            AND SSN.USE_YN = 'Y'
         LEFT OUTER JOIN BIM_STK_STCKT_SMR SMR
             ON BSS.INSTR_NO = SMR.INSTR_NO
            AND BSS.STCKT_SNO = SMR.STCKT_SNO
         LEFT OUTER JOIN
         (SELECT BRAND_CD
               , SHOP_CD
               , STA_DE
               , USER_ID     AS MNG_ID
            FROM (SELECT BRAND_CD
                       , SHOP_CD
                       , STA_DE
                       , USER_ID
                       , ROW_NUMBER ()
                             OVER (PARTITION BY BRAND_CD, SHOP_CD
                                   ORDER BY STA_DE DESC)    AS RN
                    FROM BIM_SHOP_SALES_PIC
                   WHERE STA_DE <= TO_CHAR (SYSDATE, 'YYYY-MM-DD')
                     AND NVL (USE_YN, 'Y') = 'Y')
           WHERE RN = 1) SM                                        /*매장영업담당자*/
             ON BSS.BRAND_CD = SM.BRAND_CD
            AND BSS.SHOP_CD = SM.SHOP_CD
   WHERE BSS.USE_YN = 'Y'
     AND BSS.STCKT_DIV_CD = '2'
     AND BSS.STK_INVES_TYP_CD IN
             (SELECT CDDT.DTL_CD
                FROM ESACDDT CDDT
                     INNER JOIN ESACDAT CDAT ON CDAT.GRP_CD = CDDT.GRP_CD
                     INNER JOIN ESADTAT DTAT
                         ON DTAT.SYS_ID = CDAT.SYS_ID
                        AND DTAT.GRP_CD = CDAT.GRP_CD
                        AND DTAT.DTL_CD = CDDT.DTL_CD
                        AND DTAT.ATTR_CD = CDAT.ATTR_CD
               WHERE CDDT.GRP_CD = 'STK_INVES_TYP_CD'
                 AND CDDT.STS != 'D'
                 AND CDDT.USE_YN = 'Y'
                 AND DTAT.ATTR_CD = 'DUE'
                 AND DTAT.DTL_CD_ATTR_VAL = 'Y')
     AND BSS.BRAND_CD = 'M'
     AND BSS.SHOP_CD = '021'
     AND BSS.INSTR_DE >= '2024-08-20'
     AND BSS.INSTR_DE <= '2024-09-19'
GROUP BY BSS.BRAND_CD
       , BSS.INSTR_DE
       , BSS.SHOP_CD
       , SM.MNG_ID
       , BSS.INSTR_NO
       , BSS.STK_INVES_TYP_CD
       , BSS.TERM_YN
       , BSS.STCKT_DIV_CD
       , BSS.INSTR_DEG
       , BSS.STCKT_DE
       , BSS.TERM_YN
       , BSI.STA_DE
       , BSI.END_DE
       , BSI.REQR_NM
       , BSS.APRV_STS_CD
       , BSS.ADJ_DT
       , BSS.RFID_DL_YN
       , BSS.CFM_YN
ORDER BY BSS.INSTR_DE DESC