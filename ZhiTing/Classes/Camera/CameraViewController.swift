//
//  CameraViewController.swift
//  ZhiTing
//
//  Created by zy on 2022/4/12.
//

import UIKit
#if !(targetEnvironment(simulator))
class CameraViewController: BaseViewController {
    
    var myUID = ""
     var mypwd = ""
    var displayView: IJKSDLGLView!
    var videoData:NSData!

    private lazy var startBtn = Button().then {
        $0.setTitle("开始视频", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
    }
    
    private lazy var upBtn = Button().then {
        $0.setTitle("上移动", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
        $0.tag = 1
        $0.addTarget(self, action: #selector(btnTouchDownAction(sender:)), for: .touchDown)
        $0.addTarget(self, action: #selector(btnTouchUpInsideAction(sender:)), for: .touchUpInside)
    }

    private lazy var leftBtn = Button().then {
        $0.setTitle("左移动", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
        $0.tag = 2
        $0.addTarget(self, action: #selector(btnTouchDownAction(sender:)), for: .touchDown)
        $0.addTarget(self, action: #selector(btnTouchUpInsideAction(sender:)), for: .touchUpInside)

    }
    private lazy var downBtn = Button().then {
        $0.setTitle("下移动", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
        $0.tag = 3
        $0.addTarget(self, action: #selector(btnTouchDownAction(sender:)), for: .touchDown)
        $0.addTarget(self, action: #selector(btnTouchUpInsideAction(sender:)), for: .touchUpInside)

    }
    private lazy var rightBtn = Button().then {
        $0.setTitle("右移动", for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
        $0.tag = 4
        $0.addTarget(self, action: #selector(btnTouchDownAction(sender:)), for: .touchDown)
        $0.addTarget(self, action: #selector(btnTouchUpInsideAction(sender:)), for: .touchUpInside)
    }

    
    private lazy var audioBtn = Button().then {
        $0.setTitle("开始监听", for: .normal)
        $0.setTitle("停止监听", for: .selected)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
        $0.addTarget(self, action: #selector(audioAction(sender:)), for: .touchUpInside)
    }

    private lazy var talkBtn = Button().then {
        $0.setTitle("开始对讲", for: .normal)
        $0.setTitle("停止对讲", for: .selected)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
        $0.addTarget(self, action: #selector(talkAction(sender:)), for: .touchUpInside)
    }
    
    private lazy var upDownBtn = Button().then {
        $0.setTitle("上下巡航", for: .normal)
        $0.setTitle("停止上下巡航", for: .selected)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
        $0.addTarget(self, action: #selector(updownAction(sender:)), for: .touchUpInside)
    }
    
    private lazy var leftRightBtn = Button().then {
        $0.setTitle("左右巡航", for: .normal)
        $0.setTitle("停止左右巡航", for: .selected)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.titleLabel?.textAlignment = .center
        $0.addTarget(self, action: #selector(leftRightAction(sender:)), for: .touchUpInside)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func setupViews() {
        let getFrame:CGRect =  UIScreen.main.bounds
        displayView = IJKSDLGLView(frame:CGRect(x: 0, y: 0, width: getFrame.width, height: ZTScaleValue(350)))
        displayView.backgroundColor = UIColor.black
        self.view.addSubview(displayView)
        
        view.addSubview(startBtn)
        view.addSubview(upBtn)
        view.addSubview(leftBtn)
        view.addSubview(downBtn)
        view.addSubview(rightBtn)
        
        view.addSubview(audioBtn)
        view.addSubview(talkBtn)
        view.addSubview(upDownBtn)
        view.addSubview(leftRightBtn)
        
        startBtn.clickCallBack = {[weak self] _ in
            self?.startVideo()
        }
        


    }
    
    override func setupConstraints() {
        startBtn.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(400))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        upBtn.snp.makeConstraints {
            $0.top.equalTo(startBtn.snp.bottom).offset(ZTScaleValue(20))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }

        leftBtn.snp.makeConstraints {
            $0.top.equalTo(upBtn.snp.bottom).offset(ZTScaleValue(5))
            $0.centerX.equalToSuperview().offset(-60)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        rightBtn.snp.makeConstraints {
            $0.top.equalTo(upBtn.snp.bottom).offset(ZTScaleValue(5))
            $0.centerX.equalToSuperview().offset(60)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        downBtn.snp.makeConstraints {
            $0.top.equalTo(leftBtn.snp.bottom).offset(ZTScaleValue(20))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        audioBtn.snp.makeConstraints {
            $0.top.equalTo(downBtn.snp.bottom).offset(ZTScaleValue(20))
            $0.centerX.equalToSuperview().offset(-60)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        talkBtn.snp.makeConstraints {
            $0.top.equalTo(downBtn.snp.bottom).offset(ZTScaleValue(20))
            $0.centerX.equalToSuperview().offset(60)
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        
        upDownBtn.snp.makeConstraints {
            $0.top.equalTo(audioBtn.snp.bottom).offset(ZTScaleValue(20))
            $0.centerX.equalToSuperview().offset(-85)
            $0.width.equalTo(150)
            $0.height.equalTo(50)
        }
        
        leftRightBtn.snp.makeConstraints {
            $0.top.equalTo(audioBtn.snp.bottom).offset(ZTScaleValue(20))
            $0.centerX.equalToSuperview().offset(85)
            $0.width.equalTo(150)
            $0.height.equalTo(50)
        }

    }
    
    private func startVideo(){
        //连接设备
        let isVuid = VSNet.shareinstance()?.isVUID(myUID) ?? false
        let p2pString = getPPPPString(strDID: myUID)
        if isVuid {
            VSNet.shareinstance()?.startVUID(myUID, withPassWord: mypwd, initializeStr: p2pString, lanSearch: 1, id: nil, add: false, vuid: myUID, lastonlineTimestamp: 0, withDelegate: self)
            VSNet.shareinstance()?.setStatusDelegate(myUID, withDelegate:self)
            VSNet.shareinstance()?.startLivestream(myUID, withStream: 10, withSubStream: 2);
            //设置视频数据回调代理
            VSNet.shareinstance()?.setDataDelegate(myUID, withDelegate: self);

        }else{
            let nRet = VSNet.shareinstance()?.start(myUID, withUser:"admin", withPassWord:self.mypwd, initializeStr: nil, lanSearch: 1)
            if nRet == false {
               DispatchQueue.main.async {[weak self] in
                   VSNet.shareinstance()?.start(self?.myUID, withUser:"admin", withPassWord:self?.mypwd, initializeStr: nil, lanSearch: 1)
                   //设置连接状态回调代理
                   VSNet.shareinstance()?.setStatusDelegate(self?.myUID, withDelegate: self)
                   
               }
           }else{
               
           }
        }
    }
    

    private func getPPPPString(strDID: String) -> String? {
        if strDID.uppercased().contains("VSTG") {
            return "EEGDFHBOKCIGGFJPECHIFNEBGJNLHOMIHEFJBADPAGJELNKJDKANCBPJGHLAIALAADMDKPDGOENEBECCIK:vstarcam2018"
        } else if strDID.uppercased().contains("VSTH") {
            return "EEGDFHBLKGJIGEJLEKGOFMEDHAMHHJNAGGFABMCOBGJOLHLJDFAFCPPHGILKIKLMANNHKEDKOINIBNCPJOMK:vstarcam2018"
        } else if strDID.uppercased().contains("VSTJ") {
            return "EEGDFHBLKGJIGEJNEOHEFBEIGANCHHMBHIFEAHDEAMJCKCKJDJAFDDPPHLKJIHLMBENHKDCHPHNJBODA:vstarcam2019"
        } else if strDID.uppercased().contains("VSTK") {
            return "EBGDEJBJKGJFGJJBEFHPFCEKHGNMHNNMHMFFBICPAJJNLDLLDHACCNONGLLPJGLKANMJLDDHODMEBOCIJEMA:vstarcam2019"
        } else if strDID.uppercased().contains("VSTM") {
            return "EBGEEOBOKHJNHGJGEAGAEPEPHDMGHINBGIECBBCBBJIKLKLCCDBBCFODHLKLJJKPBOMELECKPNMNAICEJCNNJH:vstarcam2019"
        } else if strDID.uppercased().contains("VSTN") {
            return "EEGDFHBBKBIFGAIAFGHDFLFJGJNIGEMOHFFPAMDMAAIIKBKNCDBDDMOGHLKCJCKFBFMPLMCBPEMG:vstarcam2019"
        } else if strDID.uppercased().contains("VSTL") {
            return "EEGDFHBLKGJIGEJIEIGNFPEEHGNMHPNBGOFIBECEBLJDLMLGDKAPCNPFGOLLJFLJAOMKLBDFOGMAAFCJJPNFJP:vstarcam2019"
        } else if strDID.uppercased().contains("VSTP") {
            return "EEGDFHBLKGJIGEJLEIGJFLENHLNBHCNMGAFGBNCOAIJMLKKODNALCCPKGBLHJLLHAHMBKNDFOGNGBDCIJFMB:vstarcam2019"
        } else if strDID.uppercased().contains("VSTF") {
            return "HZLXEJIALKHYATPCHULNSVLMEELSHWIHPFIBAOHXIDICSQEHENEKPAARSTELERPDLNEPLKEILPHUHXHZEJEEEHEGEM-$$"
        } else if strDID.uppercased().contains("VSTD") {
            return "HZLXSXIALKHYEIEJHUASLMHWEESUEKAUIHPHSWAOSTEMENSQPDLRLNPAPEPGEPERIBLQLKHXELEHHULOEGIAEEHYEIEK-$$"
        } else if strDID.uppercased().contains("VSTA") {
            return "EFGFFBBOKAIEGHJAEDHJFEEOHMNGDCNJCDFKAKHLEBJHKEKMCAFCDLLLHAOCJPPMBHMNOMCJKGJEBGGHJHIOMFBDNPKNFEGCEGCBGCALMFOHBCGMFK"
        } else if strDID.uppercased().contains("VSTB") {
            return "ADCBBFAOPPJAHGJGBBGLFLAGDBJJHNJGGMBFBKHIBBNKOKLDHOBHCBOEHOKJJJKJBPMFLGCPPJMJAPDOIPNL"
        } else if strDID.uppercased().contains("VSTC") {
            return "ADCBBFAOPPJAHGJGBBGLFLAGDBJJHNJGGMBFBKHIBBNKOKLDHOBHCBOEHOKJJJKJBPMFLGCPPJMJAPDOIPNL"
        } else {
            return nil
        }


    }

    @objc private func btnTouchDownAction(sender: Button){
        switch sender.tag {
        case 1://上
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_UP,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        case 2://左
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_LEFT,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        case 3://下
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_DOWN,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        case 4://右
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_RIGHT,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        default:
            break
        }
    }
    
    @objc private func btnTouchUpInsideAction(sender: Button){
        switch sender.tag {
        case 1://上
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_UP_STOP,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        case 2://左
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_LEFT_STOP,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        case 3://下
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_DOWN_STOP,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        case 4://右
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_RIGHT_STOP,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        default:
            break
        }
    }

    @objc private func audioAction(sender: Button){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            VSNet.shareinstance().startAudio(self.myUID, withEchoCancellationVer: false)
        }else{
            VSNet.shareinstance().stopAudio(self.myUID)
        }
    }
    
    @objc private func talkAction(sender: Button){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            VSNet.shareinstance().startTalk(self.myUID, withEchoCancellationVer: false)
        }else{
            VSNet.shareinstance().stopTalk(self.myUID)
        }
    }

    @objc private func updownAction(sender: Button){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_UP_DOWN,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        }else{
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_UP_DOWN_STOP,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        }
    }
    
    @objc private func leftRightAction(sender: Button){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_LEFT_RIGHT,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        }else{
            let onestep = 0
            let cgi = String(format: "GET /decoder_control.cgi?command=%d&onestep=%d&", CMD_PTZ_LEFT_RIGHT_STOP,onestep)
            VSNet.shareinstance().sendCgiCommand(cgi, withIdentity: myUID)
        }
    }

    

}


extension CameraViewController: VSNetStatueProtocol, VSNetDataProtocol {
    //VSNetStatueProtocol 设备状态回调代理
    func vsNetStatus(_ deviceIdentity: String!, statusType: Int, status: Int) {
        if(deviceIdentity != myUID){
            return
        }
        print(deviceIdentity)
    }
    
    
    func vsNetStatus(fromVUID strVUID: String!, uid strUID: String!, statusType: Int, status: Int) {
        print("statusType: \(statusType) status: \(status)")
        if statusType == VSNET_NOTIFY_TYPE_VUIDSTATUS.rawValue {
            if (status == VUIDSTATUS_INVALID_ID.rawValue
                || status == VUIDSTATUS_CONNECT_TIMEOUT.rawValue
                || status == VUIDSTATUS_DEVICE_NOT_ON_LINE.rawValue
                || status == VUIDSTATUS_CONNECT_FAILED.rawValue
                || status == VUIDSTATUS_INVALID_USER_PWD.rawValue) {
                //如果是ID号无效，则停止该设备的P2P
            } else if status == VUIDSTATUS_ON_LINE.rawValue { /// 设备在线
                VSNet.shareinstance()?.startLivestream(myUID, withStream: 10, withSubStream: 2);
            }

            if(VUIDSTATUS_VUID_VERIFICATION_FAIL.rawValue == status || VUIDSTATUS_VUID_VERIFICATION_UIDCHANGE.rawValue == status)
            {
                //延时3秒再去连接
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    VSNet.shareinstance()?.startVUID(self?.myUID, withPassWord:self?.mypwd, initializeStr: nil, lanSearch: 1, id: nil, add: false, vuid: self?.myUID, lastonlineTimestamp: 0, withDelegate: self)

                }
            }
            
            
            return
        } else if statusType == VSNET_NOTIFY_TYPE_VUIDTIME.rawValue {
            //更新已连接的VUID时间
//            [cameraListMgt UpdateVUIDLastConnetTime:strVUID tmpDID:strUID time:status];
        }

    }
        
    //VSNetDataProtocol 视频数据回调代理
    func vsNetYuvData(_ deviceIdentity: String!, data buff: UnsafeMutablePointer<UInt8>!, withLen len: Int, height: Int, width: Int, time timestame: UInt, origenelLen oLen: Int) {
        if(deviceIdentity != myUID){
            return
        }
        
        //buff 是解码出来的视频数据。要及时使用或者保存起来，出了作用域(跳出回调方法)后就会释放掉。
        DispatchQueue.main.sync {
            var overlay : SDL_VoutOverlay = SDL_VoutOverlay(w: Int32(Int(width)), h: Int32(Int(height)), pitches: (UInt16(width),UInt16(width) / 2,UInt16(width) / 2), pixels: (buff, buff + width * height, buff + width * height * 5 / 4))
//            self.displayView.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight/Screen.screenWidth * CGFloat(width))
            self.displayView.display(&overlay)
        }
    }
    
    func vsNetVideoData(_ deviceIdentity: String!, length: Int32) {
        
    }
    
    func vsNetH264Data(_ deviceIdentity: String!, data buff: UnsafeMutablePointer<UInt8>!, withLen len: Int, height: Int, width: Int, time timestame: UInt, withType type: Int) {
        
    }
    

    func vsNetHardH264Data(_ deviceIdentity: String!, data pixeBuffer: CVPixelBuffer!, time timestame: UInt, origenelLen oLen: Int) {
        
    }
    
    func vsNetImageNotify(_ deviceIdentity: String!, withImage imageData: Data!, timestamp: Int) {
        
    }
    
    func vsNetParamNotify(_ paramType: Int32, params: UnsafeMutableRawPointer!) {
        
    }
    
    func vsNetVideoBufState(_ deviceIdentity: String!, state: Int32) {
        
    }
}
#endif
