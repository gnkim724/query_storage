--stockFlow.findListCtbBrk: 수금내역서(대리점) 목록 조회
  SELECT C.BRAND_CD                                                     -- 브랜드
       , C.SHOP_CD                                                      -- 매장코드
       , S.SHOP_ABBR_NM     AS SHOP_NM                                  -- 매장명
       , L.SO_NM                                                        -- 점주
       , C.STD_YYMM                                                     -- 기준년월
       , C.DEG                                                          -- 차수
       , '조회'           AS DTL                                        -- 상세내역
       , '조회'           AS DEP                                        -- 입금내역
       , C.GI_AMT                                                       -- 출고금액
       , C.RTN_AMT                                                      -- 반품금액
       , C.SPLS_AMT                                                     -- 저장품금액
       , C.RPR_AMT                                                      -- 수선금액
       , C.O2O_CMS                                                      -- O2O수수료
       , C.RFID_EQ_LEASE_AMT                                            -- RFID장비임대금액
       , C.DPST_AMT                                                     -- 입금금액
       , C.PMT_EXPT_AMT                                                 -- 지불예정금액
       , C.NOT_CTB_BAL                                                  -- 미수금잔액
    FROM BIM_CTB_BRK C
         INNER JOIN BIM_SHOP S
             ON S.BRAND_CD = C.BRAND_CD
            AND S.SHOP_CD = C.SHOP_CD
         LEFT OUTER JOIN BIM_SHOP_SO L
             ON L.SO_ID = S.SO_ID
            AND L.USE_YN = 'Y'
   WHERE C.BRAND_CD = 'M'
     -- AND C.SHOP_CD IN (SELECT '20004' FROM DUAL)  -- 매장코드 선택 시
     AND C.SHOP_CD IN (SELECT '20004' FROM DUAL)
     AND S.SHOP_TRD_TYP_CD = 'A'
     AND S.SHOP_MGMT_TYP_CD = 'R'
     AND S.PROD_TRD_TYP_CD = 'A'
     AND S.SHOP_CTRT_TYP_CD = 'B'
     AND C.STD_YYMM = '2024-04'
     -- AND C.DEG = '1' -- 차수 선택 시
     AND C.DEG = '1'
     AND C.USE_YN = 'Y'
     AND S.USE_YN = 'Y'
ORDER BY C.SHOP_CD, C.STD_YYMM DESC, C.DEG DESC;


SELECT * FROM SERP_IF.IF_SAP_CTB_BRK_RCV;

SELECT * FROM SERP.BIM_CTB_BRK;