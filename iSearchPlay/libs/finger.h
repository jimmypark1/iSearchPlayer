//
//  finger.h
//  finger
//
//  Created by wondriver on 2014. 3. 12..
//  Copyright (c) 2014년 KISSOFT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
/**
 *
 *  이 클래스는 핑거푸시 api 연동을 위한 클래스 입니다.
 *  핑거푸시 서버와 연동하려면 앱아이디, 앱 스크리트 키, 토큰값을 서버에 전달해 주어야 한다.
 *
 *     support : www.fingerpush.com
 */

@interface finger : NSObject {
    
    NSString* appKey_;       //app_key
    NSString* appSecrete_;  //secrete
    
    NSString* deviceToken_;
    
    
    //  NSString* stats_time_;   //앱통계 오픈시간 체크
    
}

//@property(strong, nonatomic)    NSString* appId_;


/**
 *  싱글톤 객체 생성 매서드
 *
 *  @return finger
 */
+ (finger *)sharedData;



/**
 *  SDK 버젼
 *
 *  @return SDK 버젼
 */
+ (NSString*)getSdkVer;




/**
 *  앱아이디 저장
 *
 *  @param appId 앱아이디(핑거푸시 홉페이지 페이지에서 가져온 아이디
 */
-(void)setAppKey:(NSString*)appId;


/**
 *  앱 시크리트 키 저장
 *
 *  @param appKey 앱아이디(핑거푸시 홉페이지 페이지에서 가져온 아이디
 */
-(void)setAppScrete:(NSString*)appKey;



/**
 *  앱 키값 가져오기
 *
 *  @return 앱 키값
 */
-(NSString*)getAppKey;

/**
 *  시크리트키 가져오기
 *
 *  @return 시크리트 키
 */
-(NSString*)getSecrete;

/**
 *  토큰값 가져오기
 *
 *  @return 토큰값
 */
-(NSString*)getToken;


/**
 *  토큰idx값 가져오기
 *
 *  @return
 */
-(NSString*)getDeviceIdx;

//////////////////////////////////////////////

#pragma mark -

/**
 *  서버에 기기등록(서버통신)
 *
 *  @param token 토큰값
 *
 *  - *param1* posts 결과 코드값
 *  - *param2* error An error identifier.
 *
 */
- (void)registerUserWithBlock:(NSData *)token :(void (^)(NSString *posts, NSError *error))block;



/**
 *  푸시 활성화 on-off 가능
 *
 *  @param is_ YES - 활성화 , NO – 비활성화
 *
 *        - post : 결과 코드값
 */
-(void)setEnable:(BOOL)is_ :(void (^)(NSString *posts, NSError *error))block;




/**
 *  광고 푸시 수신 여부 처리
 *
 *  @param is_ YES - 활성화 , NO – 비활성화
 *
 *        - post : 결과 코드값
 */
-(void)requestSetAdPushEnable:(BOOL)is_ :(void (^)(NSString *posts, NSError *error))block;


/**
 *   서버에서 보내진 푸시리스트 요청 (최근100개 && 최근6개월)
 *
 *      @param block 서버와 통신 결과
 *        - post : 보낸메세지(NSDictionary)의 내역(NSArray) 리스트
 */
- (void)requestPushListWithBlock:(void (^)(NSArray *posts, NSError *error))block __deprecated_msg("This method should be removed");




/**
 *  서버에서 보내진 페이지 푸시리스트 요청 (최근6개월)
 
 @param page  요청할 페이지 페이지 번호
 @param cnt   요청할 갯수
 @param block 서버와 통신 결과
 - *post*: 보낸메세지(NSDictionary)의 내역(NSArray) 리스트
 - *error*: 에러코드와 메세지
 */
- (void)requestPushListPageWithBlock:(int)page Cnt:(int)cnt :(void (^)(NSDictionary *posts, NSError *error))block __deprecated_msg("This method should be removed");



/**
 *  핑거푸시서버에서 보내진 푸시내용 요청 (서버에 통신)
 *
 *  @param param  요청 할 메세지 정보 (메세지 리스트에서 선택)
 *  @param block 서버와 통신 결과
 *           - post 보낸메세지(NSDictionary) 내용
 */
- (void)requestPushContentWithBlock:(NSDictionary*)param :(void (^)(NSDictionary *posts, NSError *error))block;



/**
 *  핑거푸시서버에서 보내진 푸시내용 요청 (서버에 통신)
 *
 *  @param strMsgTag  메세지 tag
 *  @param strMsgMode 메세지 mode
 *  @param block 서버와 통신 결과
 *           - post 보낸메세지(NSDictionary) 내용
 */
- (void)requestPushContentWithBlock:(NSString*)strMsgTag :(NSString*)strMsgMode :(void (^)(NSDictionary *posts, NSError *error))block ;





/**
 *  목록에서 img 가져오기 (deprecated)
 *
 *  @param msg   msg : 보내진 푸시의 정보 (NSDictionary)
 *  @param block 서버와 통신 결과
 *            - posts :이미지 데이타 (NSData)
 */
- (void)requestRecevieImgWithBlock:(NSDictionary*)msg :(void (^)(NSData *posts, NSError *error))block __deprecated_msg("This method should be removed");




/**
 *  기기 설정정보 요청
 *
 *  @param block 서버와 통신 결과
 *  @param block 서버와 통신 결과
 *          - post : 앱아디, 푸시 설정, 토큰값, identity(식별자)을 (NSDictionary)로 받는다
 */
- (void)requestPushInfoWithBlock:(void (^)(NSDictionary *posts, NSError *error))block;





/**
 *  기기 태그 등록
 *
 *  @param param   저장될 태그 정보
 *  @param block 서버와 통신 결과
 *          - post : 결과 코드값
 *
 */

- (void)requestRegTagWithBlock:(NSArray*)param :(void (^)(NSString *posts, NSError *error))block;


/**
 *  기기 태그 삭제
 *
 *  @param param   삭제될 태그 정보
 *  @param block 서버와 통신 결과
 *          - post : 결과 코드값
 */

- (void)requestRemoveTagWithBlock:(NSArray*)param :(void (^)(NSString *posts, NSError *error))block;




/**
 *  모든 내 태그 삭제
 *
 *  @param block 서버와 통신 결과
 *          - post : 결과 코드값
 */

- (void)requestRemoveAllTagWithBlock:(void (^)(NSString *posts, NSError *error))block;





/**
 *  기기가 등록된 태그 리스트조회
 *
 *  @param block 서버와 통신 결과
 *          - post : 기기의 등록된 태그명/등록일자 리스트
 */
- (void)requestGetDeviceTagListWithBlock:(void (^)(NSArray *posts, NSError *error))block;



/**
 *  앱의 모든 태그 리스트조회
 *
 *  @param block 서버와 통신 결과
 *          - post : 앱의 등록된 모든 태그명/등록일자 리스트
 */
- (void)requestGetAllTagListWithBlock:(void (^)(NSArray *posts, NSError *error))block;




/**
 *  기기 identity 등록
 *
 *  @param param   저장될 아이디 정보
 *  @param block 서버와 통신 결과
 *          - code : 결과 코드값
 *                  결과 코드 (200 : 정상처리/403 : 권한없음/404 : 조회 대상 없음/ 500 : 에러)
 */
- (void)requestRegIdWithBlock:(NSString*)param :(void (^)(NSString *posts, NSError *error))block;


/**
 *  기기 identity 삭제
 *
 *  @param block 서버와 통신 결과
 *      - post : 결과 코드값(200 : 정상처리, 403 : 권한 없음, 404 : 해당 디바이스에 등록된 식별자 없음, 500 : 처리중 에러, 503 : 필수값없음)
 */
- (void)requestRemoveIdWithBlock:(void (^)(NSString *posts, NSError *error))block;



/**
 *  앱 정보 요청(deprecated : requestGetAppReportWithBlock::으로 대체)
 *
 *  @param block 서버와 통신 결과
 *  -posts
 *              code : 결과코드(200 : 정상처리, 403 : 권한 없음, 404 : 해당 디바이스에 등록된 식별자 없음, 500 : 처리중 에러, 503 : 필수값없음)
 *              appid	 앱 아이디
 *              app_name	 디바이스 타입 : I(IOS), A(Android)
 *              user_id	 앱 등록자 아이디
 *              icon	 앱 아이콘
 *              category	 앱 카테고리명
 *              environments	 앱 구동 환경 : Development/Production
 *              beios  	 IOS 기기 지원여부 : Y/N
 *              beandroid	 Android 기기 지원 여부 : Y/N
 *              version	 버전
 *              ios_upd_link	 IOS 업데이트 링크
 *              android_upd_link	 Android 업데이트 링크
 *              beupdalert	강제 업데이트 여부 Y/N
 *              ver_update_date	 버전 업데이트 일
 */

- (void)requestGetAppInfoWithBlock:(void (^)(NSDictionary *posts, NSError *error))block __deprecated_msg("use method requestGetAppReportWithBlock instead");


/**
 *  앱 정보 요청(new)
 *
 *  @param block 서버와 통신 결과
 *      -posts :
 *              code : 결과코드(200 : 정상처리, 403 : 권한 없음, 404 : 해당 디바이스에 등록된 식별자 없음, 500 : 처리중 에러, 503 : 필수값없음)
 *              message : 결과 메세지
 *              info : 결과 내용
 *               user_id	 앱 등록자 아이디
 *               icon	 앱 아이콘
 *               category	 앱 카테고리명
 *               environments	 앱 구동 환경 : Development/Production
 *               beios  	 IOS 기기 지원여부 : Y/N
 *               beandroid	 Android 기기 지원 여부 : Y/N
 *               ios_version	 IOS 버전
 *               android_version	 Android 버전
 *               ios_upd_link	 IOS 업데이트 링크
 *               android_upd_link	 Android 업데이트 링크
 *               beupdalert_i	IOS 버전 강제 업데이트 여부 Y/N
 *               beupdalert_a	Android 버전 강제 업데이트 여부 Y/N
 *               ver_update_date_i	IOS 버전 업데이트 일
 *               ver_update_date_a	 Android 버전 업데이트 일
 */
- (void)requestGetAppReportWithBlock:(void (^)(NSDictionary *posts, NSError *error))block;



#pragma mark -



/**
 *  메세지 수신 확인 메세지 서버에 전달
 *
 *  @param param   메세지 정보
 *  @param block 서버와 통신 결과
 *          - post : 결과 코드값
 */
- (void)requestPushCheckWithBlock:(NSDictionary*)param :(void (^)(NSString *posts, NSError *error))block;








#pragma mark -

/**
 *  AppDelegate(didReceiveRemoteNotification)에서 받은 메세지내용을 가져온다.
 *
 *  @param msg msg : 보내진 푸시의 정보 (userInfo)
 *
 *  @return 메시지 문구
 */
+(NSString*)recevieMessage:(NSDictionary*)msg;

/**
 *  AppDelegate(didReceiveRemoteNotification)에서 받은 메세지 제목을 가져온다.
 *
 *  @param msg msg : 보내진 푸시의 정보 (userInfo)
 *
 *  @return 메시지 타이틀
 */
+(NSString*)recevieMessageTitle:(NSDictionary*)msg;

/**
 *     AppDelegate(didReceiveRemoteNotification)에서 받은 메세지에서 메세지태그값을 가져온다.
 *
 *  @param msg 보내진 푸시의 정보 (NSDictionary)
 *
 *  @return 메세지의 태그
 */
+(NSString*)receviveMessageTag:(NSDictionary*)msg;

/**
 *  AppDelegate(didReceiveRemoteNotification)에서 받은 메세지에서 뱃지값을 가져온다.
 *
 *  @param msg 보내진 푸시의 정보 (NSDictionary)
 *
 *  @return 뱃지 수
 */
+(NSInteger)receviveBadge:(NSDictionary*)msg;


/**
 *   AppDelegate(didReceiveRemoteNotification)에서 받은 메세지에서 코드값을 가져온다.
 *
 *  @param msg 보내진 푸시의 정보 (NSDictionary)
 *
 *  @return 코드값
 */
+(NSDictionary*)receviveCode:(NSDictionary*)msg;



////////////////////////////////////////////////////////
- (void)requestGetBeaconMessageWithBlock:(NSString*)uuid majorId:(NSString*)major minorId:(NSString*)minor :(void (^)(NSArray *posts, NSError *error))block;

- (void)requestGetBeaconMessageWithBlock:(NSString*)uuid majorId:(NSString*)major minorId:(NSString*)minor cordi:(CLLocationCoordinate2D)location :(void (^)(NSArray *posts, NSError *error))block;



- (void)requestSetBeaconWithBlock:(NSString*)uuid majorId:(NSString*)major minorId:(NSString*)minor beaconName:(NSString*)name :(void (^)(NSString *posts, NSError *error))block;

- (void)requestGetBeaconListWithBlock:(void (^)(NSArray *posts, NSError *error))block;




#pragma mark -delete
/**
 *   키체인값에 저장된 값 삭제
 *
 *  @param
 *
 *  @return
 */
+(void)resetKeyChain;




@end

