//
//  DiscoverViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/2.
//

import UIKit
import WebKit

class DiscoverViewController: BaseViewController {
    private lazy var header = DiscoverHeader(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth / 2, height: 400)).then { $0.clipsToBounds = false }
    
    private lazy var scanBtn = DiscoverScanButton()
    

    /// sa发现的设备
    private lazy var devices = [DiscoverDeviceModel]()
    
    /// sa
    private lazy var saArray = [DiscoverSAModel]()
    
    /// 发现SA工具类
    private var scanSATool: UDPDeviceTool?
    

    var area = AuthManager.shared.currentArea
    
    // MARK: - espBlufi
    /// espBlufi扫描过滤内容
    private lazy var filterContent = ESPDataConversion.loadBlufiScanFilter()
    /// espBLE设备
    private lazy var bleDevices = [ESPPeripheral]()
    
    let espBleHelper = ESPFBYBLEHelper.share()
    ///
    
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.rowHeight = UITableView.automaticDimension
        $0.dataSource = self
        $0.delegate = self
        $0.separatorStyle = .none
        $0.register(DiscoverDeviceCell.self, forCellReuseIdentifier: DiscoverDeviceCell.reusableIdentifier)
    }

    
    private lazy var discoverBottomView = DiscoverBottomView(frame: .zero)

    //webview
//    var webView: WKWebView!
    var eventHandler:WKEventHandlerSwift!

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "添加设备".localizedString
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: scanBtn)
        beginScan()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanSATool?.stopScan()
        scanSATool = nil
    }

    override func setupViews() {
        view.addSubview(tableView)
        view.addSubview(header)
        view.addSubview(discoverBottomView)
//        setupWebView()

//        view.addSubview(webView)

        scanBtn.callback = { [weak self] in
            guard let self = self else { return }
            self.header.frame.size.height = 350
            self.beginScan()
        }
        
        discoverBottomView.selectCallback = { [weak self] device in
            guard let self = self else { return }
            AuthManager.checkLoginWhenComplete {
                //检测插件包是否需要更新
                self.showLoadingView()
                ApiServiceManager.shared.checkPluginUpdate(id: device.plugin_id) { [weak self] response in
                    guard let self = self else { return }
                    let filepath = ZTZipTool.getDocumentPath() + "/" + device.plugin_id
                    
                    let cachePluginInfo = Plugin.deserialize(from: UserDefaults.standard.value(forKey: device.plugin_id) as? String ?? "")
                    
                    //检测本地是否有文件，以及是否为最新版本
                    if ZTZipTool.fileExists(path: filepath) && cachePluginInfo?.version == response.plugin.version {
                        self.hideLoadingView()
                        //直接打开插件包获取信息
                        let urlPath = "file://" + ZTZipTool.getDocumentPath() + "/" + device.plugin_id + "/" + device.provisioning
                        let vc = WKWebViewController(link: urlPath)
                        vc.device = device
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        //根据路径下载最新插件包，存储在document
//                        let testString = "http://192.168.22.91/zhiting.zip"
                        ZTZipTool.downloadZipToDocument(urlString: response.plugin.download_url ?? "", fileName: device.plugin_id) { [weak self] success in
                            guard let self = self else { return }
                            self.hideLoadingView()
                            if success {
                                //根据相对路径打开本地静态文件
                                let urlPath = "file://" + ZTZipTool.getDocumentPath() + "/" + device.plugin_id + "/" + device.provisioning
                                let vc = WKWebViewController(link: urlPath)
                                vc.device = device
                                self.navigationController?.pushViewController(vc, animated: true)
                                //存储插件信息
                                UserDefaults.standard.setValue(response.plugin.toJSONString(prettyPrint:true), forKey: device.plugin_id)
                            } else {
                                self.showToast(string: "下载插件包失败".localizedString)
                            }
                            
                        }
                        
                    }
                    


                } failureCallback: { [weak self] code, err in
                    self?.hideLoadingView()
                }
            }
            



            
        }
        
    }
    
//    private func setupWebView() {
//        eventHandler = WKEventHandlerSwift(webView, self)
//        let config = WKWebViewConfiguration()
//        config.preferences = WKPreferences()
//        config.preferences.minimumFontSize = 10
//        config.preferences.javaScriptEnabled = true
//        config.preferences.javaScriptCanOpenWindowsAutomatically = true
//        config.processPool = WKProcessPool()
//        config.applicationNameForUserAgent = "zhitingua " + (config.applicationNameForUserAgent ?? "")
//
//        webView = WKWebView(frame: .zero, configuration: config)
//        let usrScript:WKUserScript = WKUserScript.init(source: WKEventHandlerSwift.handleJS(), injectionTime: .atDocumentStart, forMainFrameOnly: true)
//        config.userContentController = WKUserContentController()
//        config.userContentController.addUserScript(usrScript)
//        config.userContentController.add(self.eventHandler, name: WKEventHandlerNameSwift)
//        eventHandler.webView = webView
//
//        let filepath = "file://" + ZTZipTool.getDocumentPath() + "/plugin/index.html"
//
//        if let linkURL = URL(string: filepath) {
//            webView.load(URLRequest(url: linkURL))
//        }
//
//    }


    override func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(header.snp.edges)
        }
        
        header.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(Screen.k_nav_height)
        }
        
        discoverBottomView.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview()
            $0.top.equalTo(header.snp.bottom)
        }
//        webView.snp.makeConstraints {
//            $0.bottom.left.right.equalToSuperview()
//            $0.top.equalTo(header.snp.bottom)
//        }

    }
    
    override func setupSubscriptions() {
        websocket.discoverDevicePublisher
            .sink { [weak self] device in
                guard let self = self else { return }
                self.devices.append(device)
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        
    }

    private func beginScan() {
        bleDevices.removeAll()
        devices.removeAll()
        saArray.removeAll()
        tableView.reloadData()

        header.status = .searching
        if scanBtn.status != .searching {
            scanBtn.status = .searching
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
            guard let self = self else { return }
            self.checkSearching()
        }

        if area.is_bind_sa {
            websocket.executeOperation(operation: .discoverDevice(domain: "plguin"))
        } else {
            scanSAs()
//            addFakeSA()
        }
        
        scanBleDevices()
        
        
    }

    private func checkSearching() {
        if devices.count == 0 && saArray.count == 0 && bleDevices.count == 0 {
            header.status = .failed
            header.frame.size.height = 400
            scanBtn.status = .normal
            espBleHelper.stopScan()
            scanSATool?.stopScan()
        }
    }
    

}

extension DiscoverViewController: WKEventHandlerProtocol {
    func nativeHandle(funcName: inout String!, params: Dictionary<String, Any>?, callback: ((Any?) -> Void)?) {
        
    }
    
}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if devices.count == 0 && saArray.count == 0 && bleDevices.count == 0 {
            header.isHidden = false
        } else {
            header.isHidden = true
        }
    
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // device
            return devices.count
        } else if section == 1 { //sa
            if !area.is_bind_sa {
                return saArray.count
            }
            return 0
        } else { //espBLE
            return bleDevices.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { //device
            let cell = DiscoverDeviceCell()
            let device = devices[indexPath.row]
            cell.device = device
            cell.line0.isHidden = !(indexPath.row == 0)

            cell.addButtonCallback = { [weak self] in
                guard let self = self else { return }
                if !self.authManager.currentRolePermissions.add_device {
                    self.showToast(string: "没有权限".localizedString)
                    return
                }
                
                let vc = ConnectDeviceViewController()
                vc.area = self.area
                vc.device = device
                vc.removeCallback = { [weak self] in
                    guard let self = self else { return }
                    self.devices.removeAll(where: { $0.identity == device.identity })
                    self.tableView.reloadData()
                }
                self.navigationController?.pushViewController(vc, animated: true)
                

                
            }
            return cell
        } else if indexPath.section == 1 { //sa
            let cell = DiscoverDeviceCell()
            let device = saArray[indexPath.row]
            cell.sa_device = device

            if device.is_bind {
                cell.addButtonCallback = { [weak self] in
                    guard let self = self else { return }
                    let vc = ScanQRCodeViewController()
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                cell.addButtonCallback = { [weak self] in
                    guard let self = self else { return }
                    let vc = ConnectDeviceViewController()
                    vc.area = self.area
                    vc.device = device
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            
            return cell
            
            

        } else {
            let cell = DiscoverDeviceCell()
            cell.nameLabel.text = bleDevices[indexPath.row].name
            cell.addButton.setTitle("置网".localizedString, for: .normal)
            cell.addButtonCallback = { [weak self] in
                guard let self = self else { return }
                let vc = BlufiConfigViewController()
                vc.device = self.bleDevices[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        }
        
    }
    
    
}

extension DiscoverViewController {
    
    private func addFakeSA() {

        let device4 = DiscoverSAModel()
        device4.name = "测试服的SA"
        device4.model = "smart_assistant"
        device4.address = "http://192.168.22.123:9020"


        saArray.append(device4)
        tableView.reloadData()
        
        checkSAIsBinded()
    }
    
    private func checkSAIsBinded() {
        saArray.forEach { sa in
            ApiServiceManager.shared.checkSABindState(url: sa.address) { [weak self] (response) in
                guard let self = self else { return }
                sa.is_bind = response.is_bind
                self.tableView.reloadData()
            } failureCallback: { code, err in
                
            }
        }
        
    }
    
}

// MARK: - UDP 搜索发现SA
extension DiscoverViewController {
    private func scanSAs() {
        scanSATool = UDPDeviceTool()
        scanSATool?.saPubliser
            .sink { [weak self] sa in
                guard let self = self else { return }
                
                ApiServiceManager.shared.checkSABindState(url: sa.address) { [weak self] (response) in
                    guard let self = self else { return }
                    sa.is_bind = response.is_bind
                    self.saArray.append(sa)
                    self.tableView.reloadData()
                }
                
            }
            .store(in: &cancellables)
        try? scanSATool?.beginScan()

    }
    
}


// MARK: ESP-BLE 蓝牙搜索
extension DiscoverViewController {
    /// 扫描esp蓝牙设备
    private func scanBleDevices() {
        espBleHelper.startScan { [weak self] bleDevice in
            guard let self = self else { return }
            if self.shouldAddToSource(device: bleDevice) {
                self.bleDevices.append(bleDevice)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    private func shouldAddToSource(device: ESPPeripheral) -> Bool {
        if filterContent.count > 0 {
            if device.name.isEmpty || !device.name.hasPrefix(filterContent) {
                return false
            }
        }
        
        var flag = true
        /// check exist
        bleDevices.forEach {
            if device.uuid == $0.uuid {
                /// the device already exists in dataSource
                flag = false
                return
            }
        }
        
        return flag

    }
}

