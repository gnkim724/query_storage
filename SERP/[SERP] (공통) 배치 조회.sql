/*
 * SERP
 * 스케줄러 관리
 * ESASCHM
 */

-- 스케줄러 관리 (ESASCHM) 조회
    SELECT SYS_ID                                                  /* 시스템 아이디           */
       , SCHE_ID                                                   /* 스케쥴러 아이디         */
       , SCHE_NM                                                   /* 스케쥴러 명             */
       , CRON_EXP                                                  /* 크론 표현식             */
       , TRG_NM                                                    /* 트리거 명               */
       , TRG_GRP                                                   /* 트리거 그룹             */
       , JOB_NM                                                    /* JOB 명                  */
       , JOB_GRP                                                   /* JOB 그룹                */
       , CLSS_NM                                                   /* CLASS 명                */
       , METHOD_NM                                                 /* METHOD 명               */
       , SCHE_DESC                                                 /* 스케쥴러 설명           */
       , USE_YN                                                    /* 사용 여부               */
       , STATEFUL_YN                                               /* stateful 사용여부       */
       , REQUESTRECOVERY                                           /* REQUESTRECOVERY 사용여부*/
    FROM ESASCHM
   WHERE SYS_ID = 'FNF'
ORDER BY SCHE_NM;
;


-- 스케줄러 이력
SELECT *
  FROM (SELECT ROW_.*, ROWNUM AS ROWNUM_
          FROM (
                  /* scheduler.findListSchedulerHist */
                  SELECT SYS_ID                                 /* 시스템 아이디      */
                       , JOB_NM                                 /* JOB 명             */
                       , SCHE_START_DT                          /* 스케쥴러 시작 일시 */
                       , SCHE_END_DT                            /* 스케쥴러 종료 일시 */
                       , RES_MSG                                /* 결과 메시지        */
                       , RES_STS                                /* 결과 상태          */
                       , (CASE
                              WHEN (RES_STS = 1) THEN 'Y'
                              WHEN (RES_STS = 0) THEN 'N'
                              ELSE NULL
                          END)    AS RES_STS_YN                  /* 결과 상태 Y/N     */
                       , EXC_TIME                                /* 수행 시간         */
                       , REG_DT                                  /* 등록 일시         */
                       , EXECUTOR_ID                             /* 즉시실행자        */
                       , IS_MANUAL                               /* 즉시실행 여부     */
                       , (CASE
                              WHEN (IS_MANUAL = 1) THEN 'Y'
                              WHEN (IS_MANUAL = 0) THEN 'N'
                              ELSE NULL
                          END)    AS IS_MANUAL_YN                /* 즉시실행 여부 Y/N  */
                       , ETC                                     /* 기타 정보          */
                    FROM ESASCHL
                   WHERE SYS_ID = 'FNF'
                     AND SCHE_ID = '30f9cae8-9eca-48c4-a898-2f01c8e712e9'
                ORDER BY SCHE_START_DT DESC) ROW_)
 WHERE ROWNUM_ <= 30
   AND ROWNUM_ >= 1;
;