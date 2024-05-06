/* SERP 프로시저 정리 */

/*
 * 브랜드 공통배포 I/F 테이블 insert
 * SERP에서 브랜드 신규 등록 할 때
 * BRAND_CD : 브랜드 코드
 * DATA_TYPE_CD : I / U (insert, update 표시)
 */
CALL SERP.PRC_COM_BRAND_SND('M','I');

/*
 * brand.callPrcComSsnSnd : 시즌 공통배포 I/F 테이블 insert
 * SSN_CD : 시즌코드
 * DATA_TYPE_CD : I / U (insert, update 표시)
 */
 CALL SERP.PRC_COM_SSN_SND('','');


