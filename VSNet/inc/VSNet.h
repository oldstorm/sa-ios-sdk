


#import <Foundation/Foundation.h>
#import "VSNetProtocol.h"
#import "cmdhead.h"

@interface VSNet : NSObject

+ (VSNet *)shareinstance;
//获取本库版本号
-(NSInteger) GetSDKVersion;
//启用打印Bugly
- (void) EnablePrintgBuglyLog;
//输出日志到文件
- (void) EnablePrintLog:(int) enabel;
- (void) PrintLogToFile:(NSString*) strText;

#pragma mark /**************************初始化接口************************************/
- (void)PPPP_Initialize;

- (void) RussP2P;

- (void) Eye4P2P;

- (void) ELSOP2P;

- (void)PPPP_InitializeOther:(NSString*)initializeStr;

- (void)PPPP_DeInitialize;


- (void) XQP2P_Initialize;

- (void) XQP2P_DeInitialize;

- (int) XQP2P_GetAPIVersion;

- (void) XQP2P_NetworkDetect;

#pragma mark /**************************连接与断开连接设备的接口************************************/
/**
 *  开始链接指定设备
 *  @param deviceIdentity 设备id
 *  @param user           用户名
 *  @param pwd            密码
 *  @param initializeStr  P2P串（此值尽量不要空，“前4个字符决定固定串”都应有固定的串，如果空了首次连接可能会失败）
 *  @param LanSearch      指定服务器
 *  @return true or false
 */
- ( BOOL ) start:(NSString*) deviceIdentity withUser:( NSString*)user withPassWord:(NSString*)pwd initializeStr:(NSString *)initializeStr LanSearch:(int) nEnable ;

/**
 *  开始链接指定设备(带参数代理，这样防止连接过快没有设置代理收不到连接状态)
 *  @param deviceIdentity 设备id
 *  @param user           用户名
 *  @param pwd            密码
 *  @param initializeStr  P2P串（此值尽量不要空，“前4个字符决定固定串”都应有固定的串，如果空了首次连接可能会失败）
 *  @param LanSearch      指定服务器
 *  @param delegate       连接状态通知代理
 *  @return true or false
 */
- ( BOOL ) start2:(NSString*) deviceIdentity withUser:( NSString*)user withPassWord:(NSString*)pwd initializeStr:(NSString *)initializeStr LanSearch:(int) nEnable withDelegate:(id<VSNetStatueProtocol>) delegate;  ;


/**
 *  开始链接指定设备（用于AP模式下的P2P连接）
 *  @param deviceIdentity 设备id
 *  @param user           用户名
 *  @param pwd            密码
 *  @param initializeStr  P2P串（此值尽量不要空，“前4个字符决定固定串”设备都应有固定的串，如果空了首次连接可能会失败）
 *  @param LanSearch      指定服务器
 *  @return true or false
 */
- ( BOOL ) startAPMode:(NSString*) deviceIdentity withUser:( NSString*)user withPassWord:(NSString*)pwd initializeStr:(NSString *)initializeStr LanSearch:(int) nEnable;


/**
 *  开始链接指定设备（用于低功耗设备快速连接）
 *  @param deviceIdentity 设备id
 *  @param user           用户名
 *  @param pwd            密码
 *  @param initializeStr  P2P串（此值尽量不要空，“前4个字符决定固定串”设备都应有固定的串，如果空了首次连接可能会失败）
 *  @param LanSearch      指定服务器
 *  @return true or false
 */
- ( BOOL ) startLiteos:(NSString*) deviceIdentity withUser:( NSString*)user withPassWord:(NSString*)pwd initializeStr:(NSString *)initializeStr LanSearch:(int) nEnable ;

/**
 *  停止链接指定设备
 *  @param deviceIdentity 设备id
 *  @return true or false
 */
- ( BOOL ) stop:(NSString*) deviceIdentity;

/**
 *  断开已经连接上的设备(正在连接的不处理)
 *  @param deviceIdentity 设备id
 *  @return true or false
 */
//- ( BOOL ) disconnect:(NSString*) deviceIdentity;

/**
 *  停止所有设备的链接
 *  @return true or false
 */
- ( void ) stopAll;

#pragma mark /**************************VUID************************************/
/**
 适用于VUID连接
 @param strUID         缓存的UID(没有UID时就传nil)
 @param strPwd         设备密码
 @param initializeStr  P2P串（此值尽量不要空，“前4个字符决定固定串”设备都应有固定的串，如果空了首次连接可能会失败）
 @param LanSearch      指定服务器
 @param strAccount     EYE4 id
 @param bAddDev        YES：首次(绑定设备时)开启双重验证时
 @param strVUID        设备VUID
 @param timestamp      上次在线unix时间戳(取不到就传0)
 @param delegate       代理
 @return true or false
 */
- ( int ) StartVUID:(NSString*) strUID withPassWord:(NSString*)strPwd initializeStr:(NSString *)initializeStr LanSearch:(int) nEnable  ID:(NSString*)strAccount ADD:(BOOL)bAddDev VUID:(NSString*) strVUID LastonlineTimestamp:(NSUInteger)timestamp withDelegate:(id<VSNetStatueProtocol>) delegate;

/**
 中断或停止VUID连接
 @param strVUID         VUID
 @return true or false
 */
- ( int ) StopVUID:(NSString*) strVUID;

/**
 查ID是不是VUID
 @param strID      设备VUID
 @return YES:是  NO:不是
 */
-(BOOL) IsVUID:(NSString*) strID;

/**
 通过VUID查UID(P2P)
 @param strVUID      设备VUID
 @return 设备UID(如果是nil,说明在P2P中校验VUID并没有通过，或者是P2P并没有连接上)
 */
-(NSString*) DeviceUIDFromVUID:(NSString*) strVUID;

#pragma mark /**************************双重认证接口************************************/
/**
 P2P连接(用于双重认证时P2P连接)
 @param deviceIdentity 设备id
 @param strPwd         设备密码
 @param initializeStr  P2P串（此值尽量不要空，“前4个字符决定固定串”设备都应有固定的串，如果空了首次连接可能会失败）
 @param LanSearch      指定服务器
 @param strAccount     EYE4 id
 @param bAddDev        YES：首次(绑定设备时)开启双重验证时
 @return true or false
 */
- (int) P2PConnet:(NSString*) deviceIdentity pwd:(NSString*)strPwd initializeStr:(NSString *)initializeStr LanSearch:(int) nEnable ID:(NSString*)strAccount ADD:(BOOL)bAddDev withDelegate:(id<VSNetStatueProtocol>) delegate;

/**
 设置双重认证的参数
 @param deviceIdentity 设备id
 @param strToken   Token
 @param strPw      设备密码
 @return true or false
 */
- (int) SetDualAuthenticationParam:(NSString*) deviceIdentity Token:(NSString*)strToken DevicePwd:(NSString*)strPw;

/**
 设置双重验证时第三方登录时用的密码
 @param deviceIdentity 设备id
 @param strPwd 新的密码
 @return true or false
 */
- (int) SetWebPassWord:(NSString*) deviceIdentity Pwd:(NSString*)strPwd;

/**
 关闭第三方密码
 @param deviceIdentity 设备id
 @return true or false
 */
- (int) DisableWebPassWord:(NSString*) deviceIdentity;

/**
 开启双重验证
 @param deviceIdentity 设备id
 @param strToken   Token
 @param strPw      设备密码
 @return true or false
 */
-(int) EnableDualAuthentication:(NSString*) deviceIdentity  Token:(NSString*)strToken DevicePwd:(NSString*)strPw;

/**
 忽略双重验证信息，不等待设备清除信息了直接往下走(只有在提示设备重置未完成时使用)
 @param deviceIdentity 设备id
 @return true or false
 */
-(int)IgnoreDualAuthentication:(NSString*) deviceIdentity;

#pragma mark /**************************设置代理接口************************************/
/**
 *  设置状态代理 设备状态通知
 *  @param deviceIdentity 设备id
 *  @param delegate       代理
 *  @return true or false
 */
- ( BOOL ) setStatusDelegate: (NSString*) deviceIdentity  withDelegate: (id<VSNetStatueProtocol>) delegate;

/**
 *  设置参数代理，发送指令后设备回复
 *  @param deviceIdentity 设备id
 *  @param delegate       代理
 *  @return true or false
 */
- ( BOOL ) setControlDelegate: (NSString*) deviceIdentity withDelegate: (id<VSNetControlProtocol>) delegate;

/**
 *  设置对码代理
 *  @param deviceIdentity 设备id
 *  @param delegate       代理
 *  @return true or false
 */
- ( BOOL ) setDuimaDelegate: (NSString*) deviceIdentity withDelegate: (id<VSNetDuimaProtocol>) delegate;

/**
 *  设置报警代理
 *  @param deviceIdentity 设备id
 *  @param delegate       代理
 *  @return true or false
 */
- ( BOOL ) setAlarmDelegate: (NSString*) deviceIdentity withDelegate: (id <VSNetAlarmProtocol>) delegate;

/**
 *  设置视频数据代理,视频数据通过改代理返回
 *  @param deviceIdentity 设备id
 *  @param delegate       代理
 *  @return true or false
 */

- ( BOOL ) setDataDelegate: (NSString*) deviceIdentity withDelegate: (id <VSNetDataProtocol>) delegate;

#pragma mark /**************************实时视频接口************************************/
/**
 *  开始预览视频
 *  @param deviceIdentity 设备id
 *  @param stream         主码流 APP定为10
 *  @param substream      子码流 100 -> 2304*1296
                                0、1、14、15、16、17、18、19、20、21、22 -> 1280*720
                                2、3、7、8、9、10、11、12 -> 640*360
                                5、6 -> 320*180
 *  @return true or false
 */
- ( BOOL ) startLivestream:(NSString*) deviceIdentity withStream: (int) stream withSubStream: (int) substream;

/**
 *  停止预览视频
 *  @param deviceIdentity 设备id
 *  @return true or false
 */
- ( BOOL ) stopLivestream : (NSString*) deviceIdentity ;

/**
 *  录制当前视频
 *  @param strPath 存放路径
 *  @param deviceIdentity 设备id
 *  @param completion  成功与失败
 */
- (void)StartRecord:(NSString*) strPath cameraUid:(NSString *)deviceIdentity completion:(void (^)(BOOL success, int nError)) returnResult;
//停止录制视频
- (void)StopCameraUid:(NSString *)deviceIdentity;
#pragma mark /**************************发送指令到设备接口************************************/
/**
 *  发送cgi指令
 *  @param cgi            cgi 指令
 *  @param deviceIdentity 设备id
 *  @return true or false
 */
- ( BOOL ) sendCgiCommand: (NSString*) cgi withIdentity: (NSString*) deviceIdentity;

- ( BOOL ) sendCgiCommandWithCgi: (NSString*) cgi withIdentity: (NSString*) deviceIdentity;

#pragma mark /**************************对讲与监听接口************************************/
/**
 *  打开监听
 *  @param deviceIdentity 设备id
 *  @param withEchoCancellationVer 是否支持双向对讲
 */
- ( void ) startAudio:(NSString *) deviceIdentity withEchoCancellationVer:(BOOL)echoCancellationVer;

/**
 *  关闭监听
 *  @param deviceIdentity 设备id
 */
- ( void) stopAudio:(NSString *) deviceIdentity;

/**
 *  打开对讲
 *  @param deviceIdentity 设备id
 *  @param withEchoCancellationVer 是否支持双向对讲
 */
- (void) startTalk:(NSString *) deviceIdentity withEchoCancellationVer:(BOOL)echoCancellationVer;

/**
 *  关闭对讲
 *  @param deviceIdentity 设备id
 */
- (void) stopTalk:(NSString *) deviceIdentity;

#pragma mark/**************************TF卡回放接口beg************************************/
/**
 *  播放 SD 卡
 *  @param deviceIdentity 设备id
 *  @param Name           文件名
 *  @param offset         播放偏移
 *  @param size           文件大小
 *  @param SupportHD      设备是否支持1440高清 0不支持，1支持
 *  @param delegate      @protocol TFCardProtocol
 */
- (void) startPlayBack:(NSString *)deviceIdentity fileName:(NSString *)Name withOffset:(NSInteger)offset fileSize:(NSInteger) size delegate:(id) delegate SupportHD:(int) isHD;
/**
 *  录制TF卡
 *  @param deviceIdentity 设备id
 *  @param fileName       录制文件存放路
  * @param width          视频宽
  * @param height         视频高
 */
- (void) startRcrodTF:(NSString *)deviceIdentity fileName:(NSString *)strRecordPath width:(int)videoW height:(int)videoH ;
//停止录制TF卡
- (void) stopRcrodTF:(NSString *)deviceIdentity ;
//拖动回放进度
- (NSInteger) movePlaybackPos:(NSString *)deviceIdentity POS:(float) fos ;
//根据拖动回放进度去设置回放进度
- (void) setPlaybackPos:(NSString *)deviceIdentity time:(NSUInteger) time ;
/**
 *  停止播放 SD 卡
 *
 *  @param deviceIdentity 设备id
 */
- (void) stopPlayBack:(NSString *)deviceIdentity ;

/**
 *  暂停回放
 *  @param deviceIdentity 设备id
 *  @param isPause      0:暂停回放与录制 1:恢复回放与录制 2:暂停回放 3:恢复回放 4:暂停录制 5:恢复录制
 */
- (void) PausePlayback:(NSString *)deviceIdentity pause:(int) isPause;

#pragma mark/**************************TF卡回放接口end************************************/

#pragma mark/**************************低功耗设备端接口beg************************************/
//置前台需要连接服务器
- (int)MagLowpowerDeviceConnect:(NSString*) strIP;
//置后台需要断开服务器
- (void)MagLowpowerDeviceDisconnect;

- (void)setLowpowerDeviceDelegate: (id <LowpowerDeviceProtocol>) delegate;

- (int)GetMagLowpowerServerConnectStatus;

//初化设备
- (int)MagLowpowerInitDevice:(NSString *)deviceIdentity;
//取设备状态
- (int)MagLowpowerGetDeviceStatus:(NSString *)deviceIdentity;
//断开设备
- (int)MagLowpowerDisconnetDevice:(NSString *)deviceIdentity;
//唤醒设备
- (int)MagLowpowerAwakenDevice:(NSString *)deviceIdentity;
//是IPV6的网络
-(void)SetMagLowpowerSocketIPV6;

/**
 *  保持设备激活
 *  @param deviceIdentity 设备id
 *  @param time      设备延时休眠时间不得少5秒
 */
-(int)MagLowpowerKeepDeviceActive:(NSString *)deviceIdentity Time:(int) time;

/**
 *  移除保持设备激活（与MagLowpowerKeepDeviceActive成对的）
 *  @param deviceIdentity 设备id
 */
-(int)MagLowpowerRemoveKeepDeviceActive:(NSString *)deviceIdentity;
/**
 *  指定设备休眠倒计时
 *  @param deviceIdentity 设备id
*  @param time      设备延时休眠时间
 */
-(int)MagLowpowerSleepDevice:(NSString *)deviceIdentity Time:(int) time;


#pragma mark/**************************低功耗设备端接口end************************************/

#pragma mark/**************************4g设备端接口beg************************************/
//置前台需要连接服务器
- (int)MagFlowDeviceConnect:(NSString*) strIP;
//置后台需要断开服务器
- (void)MagFlowDeviceDisconnect;

- (void)setFlowDeviceDelegate: (id <LowpowerDeviceProtocol>) delegate;

- (int)GetFlowServerConnectStatus;

//初化设备
- (int)MagFlowInitDevice:(NSString *)deviceIdentity;
//取设备状态
- (int)MagFlowGetDeviceStatus:(NSString *)deviceIdentity;
//唤醒设备
- (int)MagFlowAwakenDevice:(NSString *)deviceIdentity;
//断开设备
- (int)MagFlowDisconnetDevice:(NSString *)deviceIdentity;

//是IPV6的网络
-(void)SetMagFlowSocketIPV6;

/**
 *  保持设备激活
 *  @param deviceIdentity 设备id
 *  @param time      设备延时休眠时间不得少5秒
 */
-(int)MagFlowKeepDeviceActive:(NSString *)deviceIdentity Time:(int) time;

/**
 *  移除保持设备激活（与MagLowpowerKeepDeviceActive成对的）
 *  @param deviceIdentity 设备id
 */
-(int)MagFlowRemoveKeepDeviceActive:(NSString *)deviceIdentity;
/**
 *  指定设备休眠倒计时
 *  @param deviceIdentity 设备id
 *  @param time      设备延时休眠时间
 */
-(int)MagFlowSleepDevice:(NSString *)deviceIdentity Time:(int) time;

#pragma mark/**************************4g设备端接口end************************************/

#pragma mark/**************************局域网内搜索在线设备接口********************************/
//开始搜索 delegate是代理，回调搜索到的设备
-(void)StartSearchDVS:(id<VSNetSearchCameraResultProtocol>)delegate;
//停止搜索
-(void)StopSearchDVS;


//h265设备接口改变设备编码器，Operation:0切成h264 1切成H265 2查当前使用的编码器
-(int) SwitchDeviceEncoder:(NSString *)deviceIdentity Operation:(int) opt;
//APP是否进入后台，IsBG=YES:是 IsBG=NO:否
-(void) EnterBackground:(BOOL)IsBG;
//特殊设备指定视频解码回调
- (void)setCameraIsPanorama:(BOOL)isPanorama withUid:(NSString *)deviceIdentity;
//重置视频解码器
- (void)ResetH264Init:(NSString *)deviceIdentity;

/**
 * 修改设备密码
 * @param deviceIdentity 设备id
 * @param Restart        是否重启设备
 * @param admimUser      管理员用户名
 * @param adminPWD       管理员新密码
 * @param OperatorUser   操作员用户名(不修改时填空nil)
 * @param OperatorPWD    操作员新密码(不修改时填空nil)
 * @param VisitorUser    访客用户名(不修改时填空nil)
 * @param VisitorPWD     访客新密码(不修改时填空nil)
 * @return 1发送成功，0失败
 */
- (int) ModifyPassword:(NSString *)deviceIdentity Restart:(BOOL)IsRestart
             admimUser:(NSString*) strAdminUser adminPWD:(NSString*) strAdPwd
          OperatorUser:(NSString*) strOpUser  OperatorPWD:(NSString*) strOpPWd
           VisitorUser:(NSString*) strVsUser  VisitorPWD:(NSString*) strVsPWd;

/*服务器加密解密接口*/
//解密 返回nil代表解密失败
-(NSString *)SeverDecryptStr:(NSString *)sValue;
//加密 返回nil代表加密失败
-(NSString *)SeverEncryptStr:(NSString *)sValue;

//生成key
-(NSString*)GetDevEncryptKey:(NSString*)strUser PW:(NSString*)strPW;
//解密 返回nil代表解密失败
//sValue:密文 strKey:key
-(NSString*)DeviceDecryptStr:(NSString*)sValue KEY:(NSString*)strKey;
//加密 返回nil代表加密失败
//sValue:明文 strKey:key
-(NSString*)DeviceEncryptStr:(NSString*)sValue KEY:(NSString*)strKey;

/**
 分享的内容加密
 @param strContent 需要加密的字符串
 @param returnResult strResult返回加密好的串，nil为加密失败 nError:-1->连网失败,-2,-3->网络时间出错 0->加密失败 1->加密成功
 @return           成功与失败
 */
-(int) ShareUIDEncryptStr:(NSString*) strContent completion:(void (^)(NSString* strResult,int nError)) returnResult;

/**
 分享的内容解密
 @param strContent 需要解密的字符串
 @param returnResult strResult返回解密好的串，nil为解密失败 nError:-1->连网失败,-2,-3->网络时间出错 0->解密失败 1->解密成功
 @return           成功与失败
 */
-(int) ShareUIDDecryptStr:(NSString*) strContent completion:(void (^)(NSString* strResult,int nError)) returnResult;

#pragma mark/***********************合并视频文件接口*****************************/
/**
 * 开始合并视频文件 H264
 * @param deviceIdentity 设备id
 * @param strInPath      输入文件(单个文件)
 * @param strOutPath     输出文件
 * @param nCount         输入文件个数(总文件个数)
 * @param delegate       进度回调代理
 * @return 1成功，0失败
 */
-(int) StratMergeMP4File:(NSString*)deviceIdentity InputPath:(NSString*)strInPath OutPath:(NSString*)strOutPath FileCount:(int)nCount Delegate:(id <MergerVideoProtocol>) delegate;

/**
 * 开始合并视频文件 H265
 * @param deviceIdentity 设备id
 * @param strInPath      输入文件(单个文件)
 * @param strOutPath     输出文件
 * @param nCount         输入文件个数(总文件个数)
 * @param delegate       进度回调代理
 * @return 1成功，0失败
 */
-(int) StratMergeH265File:(NSString*)deviceIdentity InputPath:(NSString*)strInPath OutPath:(NSString*)strOutPath FileCount:(int)nCount Delegate:(id <MergerVideoProtocol>) delegate;

/**
 * 往合并视频列表中添加文件
 * @param deviceIdentity 设备id
 * @param strInPath      输入文件(单个文件)
 * @return 1成功，0失败
 */
-(int) PutFile:(NSString*)deviceIdentity InputPath:(NSString*)strInPath;

/**
 * 获取合并文件的合并文件进度
 * @param deviceIdentity 设备id
 * @return 0~1.0进度  -1代表错误
 */
-(float) GetMergeMP4FilePos:(NSString*)deviceIdentity;

/**
 * 中断合并
 * @param deviceIdentity 设备id
 * @return 1成功，0失败
 */
-(int) StopMergeMP4File:(NSString*)deviceIdentity;

#pragma mark/***********************订阅消息*****************************/
/**
 * 订阅回调消息
 * @param deviceIdentity 设备id
 * @param nType           消息类型(参考enum SUBSCRIBE_NOTIFY_TYPE，所有消息类型都要订阅了才有通知，默认是不订阅的)
 * @param nEnable         YES代表订阅 NO:不订阅
 * @return 1成功，0失败
 */
-(int) SubscribeMsgNotify:(NSString*)deviceIdentity Type:(int) nType Enable:(BOOL) nEnable;

/**
 * 设置订阅消息回调代理
 * @param deviceIdentity 设备id
 * @param delegate       代理
 * @return 1成功，0失败
 */
-(int) SetSubscribeMsgNotifyProtocol:(NSString*)deviceIdentity Delegate:(id<SubscribeMsgNotifyProtocol>) delegate;

/**
 * P2P获取连接情况
 * @param deviceIdentity 设备id
 * @return EM_GETP2PCONNET_STATE
 */
-(int) GetP2PConnetState:(NSString*)deviceIdentity;

#pragma mark/***********************人脸相关接口*****************************/

-(int) CreateFaceID:(NSString*)deviceIdentity;


-(int) DeleteFaceID:(NSString*)deviceIdentity FaceID:(NSString*)strFaceID;


-(int) UpdateFaceInfo:(NSString*)deviceIdentity FaceID:(NSString*)strFaceID Name:(NSString*)strName Describe:(NSString*)strDescribe;


-(int) GetAllFaceID:(NSString*)deviceIdentity Index:(NSInteger)nPageIndex;


-(int) DeleteFaceSample:(NSString*)deviceIdentity FaceID:(NSString*)strFaceID Sample:(NSInteger)nSampleID;


-(int) UploadFaceSample:(NSString*)deviceIdentity FaceID:(NSString*)strFaceID Type:(VS_FACE_TYPE) eType Path:(NSString*) strPath;
/**
-(int) DownloadFaceSample:(NSString*)deviceIdentity FaceID:(NSString*)strFaceID Sample:(NSInteger)nSampleID;


-(int) GetAllSampleID:(NSString*)deviceIdentity FaceID:(NSString*)strFaceID;


-(int) SetFaceMsgNotifyProtocol:(NSString*)deviceIdentity Delegate:(id<FaceMsgNotifyProtocol>) delegate;

#pragma mark/***********************WAV文件操作*****************************/

-(int) CreateG711WavFile:(NSString*)strInPutfilePath  OUTPUT:(NSString*)stroutputfilepath;


-(int) MergeWavFile:(NSString*)strInPutfilePath  OUTPUT:(NSString*)stroutputfilepath Duration:(int) duration Count:(int) nCount;


#pragma mark/***********************TCP语音门铃相关接口*****************************/
/**
* 连接语音门铃设备进行对讲
* @param deviceIdentity        设备ID
* @param strIP                       分配给设备的IP地址
* @param nPort                     分配给设备的端口
* @param strRoomID            分配给设备的房间号
* @param strUser                 用户
* @param strToken               token
* @param delegate               通过代理返回通讯状态
* @return 大于0成功，否则失败
*/
-(int) StratVoiceChannel:(NSString*)deviceIdentity  IPAddr:(NSString*)strIP Port:(int)nPort RoomID:(NSString*)strRoomID  User:(NSString*)strUser Tonken:(NSString*)strToken  Delegate:(id<TcpVoiceDeviceProtocol>) delegate;
/**
* 语音门铃 留言文件播放
* @param deviceIdentity        设备ID
* @param strFilePath              文件路径
* @param delegate               通过代理返回通讯状态
* @return 大于0成功，否则失败
*/
-(int) PlayerVoice:(NSString*)deviceIdentity  File:(NSString*)strFilePath Delegate:(id<TcpVoiceDeviceProtocol>) delegate;

/**
* 语音门铃 退出通话或中断退出留言文件播放
* @param deviceIdentity        设备ID
* @return 大于0成功，否则失败
*/
-(int) StopVoiceChannel:(NSString*)deviceIdentity;

@end
