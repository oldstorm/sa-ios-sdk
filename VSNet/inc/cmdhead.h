#ifndef __CMD_HEAD_H_
#define __CMD_HEAD_H_

//nvs
#define CGI_BINDNVS 10000
#define CGI_GETNVSSCENE 20
#define CGI_AddParameter 10020
#define CGI_NvsPartsList 10
#define CGI_NvsToPlay 30
#define CGI_NvsDoToPlay 131
#define CGI_NvsSencelistNow 22
#define CGI_NvsControlSence 120
#define CGI_NvsOneDevStatus 110
#define CGI_NvsControlDev 111



//IE CGI CMD
#define CGI_IEGET_STATUS			0x6001
#define CGI_IEGET_PARAM				0x6002
#define CGI_IEGET_CAM_PARAMS		0x6003
#define CGI_IEGET_LOG				0x6004
#define CGI_IEGET_MISC				0x6005
#define CGI_IEGET_RECORD			0x6006
#define CGI_IEGET_RECORD_FILE		0x6007
#define CGI_IEGET_WIFI_SCAN			0x6008
#define CGI_IEGET_FACTORY			0x6009
#define CGI_IESET_IR				0x600a
#define CGI_IESET_UPNP				0x600b
#define CGI_IESET_ALARM				0x600c
#define CGI_IESET_LOG				0x600d
#define CGI_IESET_USER				0x600e
#define CGI_IESET_ALIAS				0x600f
#define CGI_IESET_MAIL				0x6010
#define CGI_IESET_WIFI				0x6011
#define CGI_CAM_CONTROL				0x6012
#define CGI_IESET_DATE				0x6013
#define CGI_IESET_MEDIA				0x6014
#define CGI_IESET_SNAPSHOT			0x6015
#define CGI_IESET_DDNS				0x6016
#define CGI_IESET_MISC				0x6017
#define CGI_IEGET_FTPTEST			0x6018
#define CGI_DECODER_CONTROL			0x6019
#define CGI_IESET_DEFAULT			0x601a
#define CGI_IESET_MOTO				0x601b
#define CGI_IEGET_MAILTEST			0x601c
#define CGI_IESET_MAILTEST			0x601d
#define CGI_IEDEL_FILE				0x601e
#define CGI_IELOGIN                 0x601f
#define CGI_IESET_DEVICE			0x6020
#define CGI_IESET_NETWORK			0x6021
#define CGI_IESET_FTPTEST			0x6022
#define CGI_IESET_DNS				0x6023
#define CGI_IESET_OSD				0x6024
#define CGI_IESET_FACTORY			0x6025
#define CGI_IESET_PPPOE				0x6026
#define CGI_IEREBOOT				0x6027
#define CGI_IEFORMATSD				0x6028
#define CGI_IESET_RECORDSCH			0x6029
#define CGI_IESET_WIFISCAN			0x602a
#define CGI_IERESTORE				0x602b
#define CGI_IESET_FTP				0x602c
#define CGI_IESET_RTSP				0x602d
#define CGI_IEGET_VIDEOSTREAM		0x602e
#define CGI_UPGRADE_APP				0x602f
#define CGI_UPGRADE_SYS				0x6030
#define CGI_CHECK_USER              0x60a0
#define CGI_SENSOR_LIST             0x60b6
#define CGI_SENSOR_ALARM_FILE       0x60b5
#define CGI_SENSOR_STATUS           0x60b2
#define CGI_SENSOR_ALARM            0x6040
#define CGI_SENSOR_OPENCODE         0x60b1
#define CGI_SENSOR_WHITELIST        0x60b8
#define CGI_SENSOR_GETPRESET        0x60b9
#define CGI_GET_CAMERA_LIST         0x60BC
#define CGI_PUSH_ALARMSERVER        0x6009
#define CGI_MUSIC_OPERATION         0x60d1
#define CGI_IEGET_TFSTATUS          0x7a03

#define CGI_FACE_UPLOAD_RETMSG      0x8101
#define CGI_FACE_DNLOAD_RETMSG      0x8102

#define STREAM_CODEC_TYPE   0x6040
#define STREAM_CODEC_TYPE_JPEG 0
#define STREAM_CODEC_TYPE_H264 1
#define STREAM_CODEC_TYPE_H265 2

#define CGI_SET_IIC				0x6031
#define CGI_GET_IIC				0x6032

#define CGI_IEGET_ALARMLOG			0x6033
#define CGI_IESET_ALARMLOGCLR		0X6034

#define CGI_IEGET_SYSWIFI                      	0x6035
#define CGI_IESET_SYSWIFI                   	0X6036

#define CGI_IEGET_LIVESTREAM                    0X6037
 

//视频参数
typedef struct tag_STRU_CAMERA_PARAM
{
    int resolution;
    int bright;
    int contrast;
    int hue;
    int saturation;
    int osdenable;
    int mode;
    int flip;
    int enc_framerate;
    int sub_enc_framerate;
}STRU_CAMERA_PARAM,*PSTRU_CAMERA_PARAM;

/*typedef struct _stBcastParam
{
	char            szIpAddr[16];		//IP地址
	unsigned char            szMask[16];		//子网掩码
	char            szGateway[16];		//网关
	char            szDns1[16];		//dns1
	char            szDns2[16];		//dns2
	char            szMacAddr[6];		//设备MAC地址
	unsigned short          nPort;			//设备端口
	char            dwDeviceID[32]; 		//platform deviceid
	char            szDevName[32];		//设备名称
	char            sysver[16];		//固件版本
	char            appver[16];		//软件版本
	char            szUserName[32];		//修改时会对用户认证
	char            szPassword[32];		//修改时会对用户认证
	char            sysmode;        		//0->baby 1->HDIPCAM
	char            other[3];       		//other
	char            other1[20];     		//other1
	
}BCASTPARAM, *PBCASTPARAM;*/

typedef struct _stBcastParam{
    char szIpAddr[16];      //IP 地址，可以修改
    char szMask[16];        //子网掩码，可以修改
    char szGateway[16];     //网关，可以修改
    char szDns1[16];        //dns1，可以修改
    char szDns2[16];        //dns2，可以修改
    char szMacAddr[6];      //设备MAC 地址
    unsigned short  nPort;  //设备端口
    char dwDeviceID[32];    //platform deviceid
    char szDevName[80];     //设备名称
    char sysver[16];        //固件版本
    char appver[16];        //软件版本
    char szUserName[32];    //修改时会对用户认证
    char szPassword[32];    //修改时会对用户认证 char sysmode; //0->baby 1->HDIPCAM
    char dhcp;              //DHCP
    char other[2];          //other
    char other1[20];        //other1
}BCASTPARAM, *PBCASTPARAM;

//通知消息类型
enum VSNETSTATUE_NOTIFY_TYPE
{
    VSNET_NOTIFY_TYPE_P2PSTATUS =0,            //p2p状态(对应enum P2PSTATUS_NOTIFY_TYPE)
    VSNET_NOTIFY_TYPE_P2PMODE =1,              //p2p连接模式
    VSNET_NOTIFY_TYPE_DUALAUTHENTICATION = 5,  //双重认证消息通知(对应enum DUALAUTHENTICATION_NOTIFY_CONTENT)
    VSNET_NOTIFY_TYPE_VUIDSTATUS =7,           //VUID p2p状态(对应enum VUIDSTATUS_NOTIFY_TYPE
    VSNET_NOTIFY_TYPE_VUIDTIME =8,             //用于VUID 通知的UnixTimestamp
};

//订阅消息类型
enum SUBSCRIBE_NOTIFY_TYPE
{
    VSNET_NOTIFY_TYPE_VIDEOSTATUS        = 6, //实时视频状态消息通知(对应enum VIDEOSTATUS_NOTIFY)
    VSNET_NOTIFY_TYPE_MSTARH265DELAY     = 7,//mstar h265解码不过来通知
};

//p2p状态
enum P2PSTATUS_NOTIFY_TYPE
{
    P2PSTATUS_CONNECTING  = 0,      /* connecting 正在连接中*/
    P2PSTATUS_INITIALING  = 1 ,     /* initialing 正在初始化*/
    P2PSTATUS_ON_LINE  = 2,         /* on line 在线状态*/
    P2PSTATUS_CONNECT_FAILED  = 3,  /* connect failed 连接失败*/
    P2PSTATUS_DISCONNECT  = 4,      /*connect is off 断开连接*/
    P2PSTATUS_INVALID_ID  = 5,      /* invalid id 无效ID*/
    P2PSTATUS_DEVICE_NOT_ON_LINE = 6, /* invalid id 不在线状态*/
    P2PSTATUS_CONNECT_TIMEOUT  = 7, /* connect timeout 连接超时*/
    P2PSTATUS_INVALID_USER_PWD = 8, /*user or pwd is invalid 用户名或者密码错误*/
    
    P2PSTATUS_MAXCONNECTING = 20, /*超过最大连接数*/
};

//VUID p2p状态
enum VUIDSTATUS_NOTIFY_TYPE
{
    VUIDSTATUS_CONNECTING  = 0,      /* connecting 正在连接中*/
    VUIDSTATUS_INITIALING  = 1 ,     /* initialing 正在初始化*/
    VUIDSTATUS_ON_LINE  = 2,         /* on line 在线状态*/
    VUIDSTATUS_CONNECT_FAILED  = 3,  /* connect failed 连接失败*/
    VUIDSTATUS_DISCONNECT  = 4,      /*connect is off 断开连接*/
    VUIDSTATUS_INVALID_ID  = 5,      /* invalid id 无效ID*/
    VUIDSTATUS_DEVICE_NOT_ON_LINE = 6, /* invalid id 不在线状态*/
    VUIDSTATUS_CONNECT_TIMEOUT  = 7, /* connect timeout 连接超时*/
    VUIDSTATUS_INVALID_USER_PWD = 8, /*user or pwd is invalid 用户名或者密码错误*/
    VUIDSTATUS_VUID_VERIFICATION_FAIL = 9,  //VUID校验失败,并向服务器查了几次UID都没有查到.断开P2P
    VUIDSTATUS_VUID_VERIFICATION_UIDCHANGE = 10,  //VUID校验失败,uid变了，断开P2P 需要重新调用StartVUID接口
};

//双重认证消息通知
enum DUALAUTHENTICATION_NOTIFY_CONTENT
{
    //首次绑定时P2P不能时用 p2p连接状态时用
    DUALAUTHENTICATION_P2PCONNECT_INVALID_HANDLE = -2302, //无效会话
    DUALAUTHENTICATION_P2PCONNECT_NOTONLINE = -2301,     //设备不在线
    DUALAUTHENTICATION_P2PCONNECT_TIMEOUT = -2300,       //设备超时
    
    //双重认证授权失败时用
    DUALAUTHENTICATION_AUTHORIZED_FAIL_TOKEN_EXPIRE   = -2102,   //双重认证授权失败  token过期
    DUALAUTHENTICATION_AUTHORIZED_FAIL_PRIVILEG       = -2101,   //双重认证授权失败  没有权限访问该设备
    DUALAUTHENTICATION_AUTHORIZED_FAIL  = -2100,                 //双重认证授权失败
    //双重认证授权成功
    DUALAUTHENTICATION_AUTHORIZED_SUCCESSFUL = -1100,//双重认证授权成功
    
    //开启双重认证或第三方明文密时用
    DUALAUTHENTICATION_WEBPWD_SUCCESSFUL = -2200, //WEB密码设置成功
    DUALAUTHENTICATION_OPEN_FAIL        = -2000,  //开启双重认证失败
    DUALAUTHENTICATION_OPEN_SUCCESSFUL  = -1000,  //开启双重认证成功
    
    //设备出现密码错误或重置
    DUALAUTHENTICATION_TIMEOUT_NOTONLINE  = -10,  //自定义:超时或者设备断开
    DUALAUTHENTICATION_RESET_DEVICE_INIT_GETCOUNT30 = -6,    //设备重置清除还在进行中并且这个设备是支持双重认证 -> 查了30次(只通知一次)
    DUALAUTHENTICATION_RESET_DEVICE_INIT = -5,    //设备重置清除还在进行中并且这个设备是支持双重认证 -> 每秒查一次(每秒会通知1次)
    DUALAUTHENTICATION_SECUSERERROR_PWD = -4,    //有双重认证情况：次用户错误的密码
    DUALAUTHENTICATION_MAINUSERERROR_PWD = -3,   //有双重认证情况：主用户错误的密码
    DUALAUTHENTICATION_ERROR_PWD = -2,           //无双重认证情况：错误的密码
    
    //设备是否支持双重认证 查讯结果
    DUALAUTHENTICATION_NONSUPPORT = -1,         //不支持双重认证
    DUALAUTHENTICATION_SUPPORT_NOTOPEN = 0,     //支持双重认证，但未开启
    DUALAUTHENTICATION_SUPPORT_OPEN = 1,        //已经开启双重认证
    DUALAUTHENTICATION_SUPPORT_OPENANDWEB = 2,  //已经开启双重认证并设置了第三方登录密码
    
    //非首次(绑定设备时)是没有以下状态的。请查看P2PConnet接口bAddDev参数，已经开启双重验证的交给SetDualAuthenticationParam接口后去处理验证Token
    DUALAUTHENTICATION_NOTNET            =99,          //设备无网 连续多次查讯，6秒后还是查到设备没有联网（只通知一次）
    DUALAUTHENTICATION_NOTNET_NONSUPPORT =100,         //设备无网并不支持双重认证（6秒内可能通知多次）提供给搜索设备用，出现这值代表不支持双重认证设备
    DUALAUTHENTICATION_NOTNET_SUPPORT_NOTOPEN = 101,   //设备无网并支持双重认证，但未开启，（6秒内可能通知多次）提供给搜索设备用，出现这值代表支持双重认证设备
};

//实时视频状态消息通知
enum VIDEOSTATUS_NOTIFY
{
    VIDEOSTATUS_NOTIFY_START = 50,  //实时视频解码开始
    VIDEOSTATUS_NOTIFY_DECFIRST = 51,  //实时视频解码出第一张图
    VIDEOSTATUS_NOTIFY_END = 52     //实时视频解码结束
};

//调用低功耗接口返回值
enum EM_LOWPOWER_ERROR
{
    EM_LOWPOWER_ERROR_ENTERBACKGROUND= -200,  //APP置后台 调用用接口无效(使用了EnterBackground接口)
    EM_LOWPOWER_ERROR_PARAMETER      = -100,  //参数是无效值，比如MagLowpowerDeviceConnect接口使用空值
    
    //MagLowpowerDeviceConnect 出现-90至-99错误的说明MagLowpowerDeviceConnect接口连接服务器失败了，需要重新调用
    EM_LOWPOWER_ERROR_MASTER_INIT    = -99,  //连接MASTER服务器创建连接失败（MagLowpowerDeviceConnect接口）
    EM_LOWPOWER_ERROR_MASTER_CONNECT = -98,  //连接不上MASTER服务器（MagLowpowerDeviceConnect接口）
    EM_LOWPOWER_ERROR_MASTER_IP      = -97,  //无效IP地址 (MagLowpowerDeviceConnect传的IP地址是无效的)
    EM_LOWPOWER_ERROR_MASTER_NOTINIT = -96,  //未初化连接器（是不是没调用MagLowpowerDeviceConnect接口）
    EM_LOWPOWER_DEVICECONNECT_APIFAIL= -90,  //MagLowpowerDeviceConnect接口失败了
    
    //MagLowpowerInitDevice 出现-10至-15错误的说明MagLowpowerInitDevice接口连接节点服务器失败了，需要重新调用MagLowpowerInitDevice
    EM_LOWPOWER_ERROR_INITDEVICE_NODEINFOFAIL = -10, //节点信息错误，
    EM_LOWPOWER_ERROR_INITDEVICE_NODEIP   = -11,     //主服务器返回的节点IP错误
    EM_LOWPOWER_ERROR_INITDEVICE_NODEPORT = -12,     //主服务器返回的节点端口错误
    EM_LOWPOWER_ERROR_INITDEVICE_NODE_CONNECTFAIL = -13,  //是连接不上节点服务器
    EM_LOWPOWER_ERROR_INITDEVICE_NODE_NOTREG = -14,      //节点服务器没有注册上
     EM_LOWPOWER_ERROR_INITDEVICE_ING = -15,      //节点服务器连接中，请稍后几秒再来
 
    EM_LOWPOWER_FAIL                 = 0,    //失败
    EM_LOWPOWER_SUCCESS              = 1,    //调用成功
};

//低功耗状态
enum EM_LOWPOWER_NOTIFY_STATUS
{
    //again
    EM_LOWPOWER_NOTIFY_AGAIN_P2PSTART   = -3,//需要重新调用Start p2p接口
    EM_LOWPOWER_NOTIFY_AGAIN_INITDEVICE = -2,//需要重新调用MagLowpowerInitDevice
    
    EM_LOWPOWER_NOTIFY_REGING         = 8,   //正在注册中，由于MagLowpowerGetDeviceStatus接口才能取到
    EM_LOWPOWER_NOTIFY_Unknown        = 9,   //错误无法识别的状态
    
    EM_LOWPOWER_NOTIFY_ONLINE         = 10,  //在线
    EM_LOWPOWER_NOTIFY_OFFLINE        = 11,  //离线
    EM_LOWPOWER_NOTIFY_SUPER_SLEEP    = 13,  //超低功耗休眠
    EM_LOWPOWER_NOTIFY_SLEEP          = 22,  //休眠
    
    EM_LOWPOWER_NOTIFY_SET_ONLINE     = 30,  //P2P已经连接上(p2p在线，对应调用MagLowpowerKeepDeviceActive接口时P2P在线)
    EM_LOWPOWER_NOTIFY_P2PCONNETING   = 40,  //P2P连接中
};

//GetP2PConnetState 获取连接状态
enum EM_GETP2PCONNET_STATE{
    EM_GETP2PCONNET_STATE_INIT_ERROR    = -2,   //连接失败退了连接(要调用start连接或者其它连接接口)
    EM_GETP2PCONNET_STATE_NOTINIT       = -1,   //没用初始化(要调用start连接或者其它连接接口)
    EM_GETP2PCONNET_STATE_CONNECTING    = 0,    //p2p连接中
    EM_GETP2PCONNET_STATE_CONNECTED     = 1,    //p2p连接上
};


enum EM_FACE_NOTIFY_TYPE
{
    EM_FACE_CREATE = 1,
    EM_FACE_DELETE = 2,
    EM_FACE_SAMPLE = 3,
    EM_FACE_UPDATE = 4,
    EM_FACE_GETALL = 6,
    
    EM_FACE_DOWNLOAD_JPG = 1000,
    EM_FACE_UPLOAD_JPG   = 1001,
    EM_FACE_UPLOAD_AUDIO = 1002,
};

typedef enum tag_ENUM_FACE_TYPE{
    FACE_TYPE_JPG    =0,  //头像
    FACE_TYPE_AUDIO  =1,  //自定声音
}VS_FACE_TYPE;


enum EM_FACE_UPLOAD_ERROR_CODE
{
    EM_FACE_UPLOAD_ID_ERROR        = -16, 
    EM_FACE_UPLOAD_NOTFIND_SAMPLE  = -15,
    EM_FACE_UPLOAD_MAX_SAMPLE      = -14,
    EM_FACE_UPLOAD_MAX_FACE        = -13,
    EM_FACE_UPLOAD_JPGFMT_ERROR    = -12,
    EM_FACE_UPLOAD_YUVFMT_ERROR    = -11,
    EM_FACE_UPLOAD_YUVFIL_ERROR    = -10,
    EM_FACE_UPLOAD_MEM_ERROR       = -2,
    EM_FACE_UPLOAD_WRITEFIL_ERROR  = -1,
};

//tcp语音通讯状态
enum VOICESTATUS_NOTIFY_TYPE
{
    VOICESTATUS_NOTIFY_UNKNOW    = -2,    //未知
    VOICESTATUS_NOTIFY_ERROR     = -1,    //语音连接错误
    VOICESTATUS_NOTIFY_INIT      = 0,     //语音连接中
    VOICESTATUS_NOTIFY_SUCCESS   = 1,     //语音连接成功
    VOICESTATUS_NOTIFY_CLOSE     = 2,     //语音连接关闭
    VOICESTATUS_NOTIFY_EXIT     = 3,      //语音连接退出
    
    VOICESTATUS_NOTIFY_P_STRART  = 11,      //留言播放开始
    VOICESTATUS_NOTIFY_P_STOP    = 12,      //留言播放结束
};
#endif

