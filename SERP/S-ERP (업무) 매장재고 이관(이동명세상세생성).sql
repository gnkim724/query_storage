/* stockFlow.insertMovSttmtDtlByTrShopWhStk : 매장창고재고 이관 실행 > 이동명세상세 생성 */
         INSERT
           INTO BIM_MOV_STTMT_DTL
                (
                 BRAND_CD
                ,ORD_NO
                ,ORD_SNO
                ,SSN_CD
                ,PROD_CD
                ,COLOR_CD
                ,SIZ_CD
                ,ORD_QTY
                ,SIGN_QTY
                ,DTT_QTY
                ,GI_QTY
                ,INSR_ID
                ,UPDR_ID
                )
         VALUES (
                 'I'
                ,'I202409002273271'
                ,'1'
                ,'24S'
                ,'7AS1V0443'
                ,'50NYS'
                ,'145'
                ,'-1'
                ,'-1'
                ,'-1'
                ,'-1'
                ,'GNKIM724'
                ,'GNKIM724'
                )