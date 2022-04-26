//
//  BrandCreationViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/11/4.
//

import UIKit
import Alamofire
import JXSegmentedView

class BrandCreationViewController: BaseViewController {
    private lazy var plugins = [Plugin]()
    private lazy var documentPicker = DocumentPicker(presentationController: self, delegate: self)
    private lazy var emptyView = EmptyStyleView(frame: .zero, style: .noContent)

    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorStyle = .none
        $0.backgroundColor = .custom(.white_ffffff)
        $0.register(BrandCreationCell.self, forCellReuseIdentifier: BrandCreationCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 80
        $0.delegate = self
        $0.dataSource = self
    }


    private lazy var addBtn = Button().then {
        $0.setTitle("添加插件".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = 10
        
        if getCurrentLanguage() == .chinese {
            $0.titleLabel?.font = .font(size: 14, type: .bold)
        } else {
            $0.titleLabel?.font = .font(size: 12, type: .bold)
        }
        
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.uploadClick()
        }
    }
    
    private var uploadAlert: UploadPluginAlertView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "支持品牌".localizedString
        requestNetwork()
        
    }
    
    override func setupViews() {
        view.backgroundColor = .custom(.white_ffffff)

        view.addSubview(tableView)
        view.addSubview(addBtn)

        let header = ZTGIFRefreshHeader()
        tableView.mj_header = header
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
        tableView.addSubview(emptyView)
        emptyView.isHidden = true
        
    }
    
    override func setupConstraints() {

        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(addBtn.snp.top).offset(-15)
        }
        
        emptyView.snp.makeConstraints {
            $0.width.equalTo(tableView)
            $0.height.equalTo(tableView)
            $0.center.equalToSuperview()
        }
        
        addBtn.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-Screen.bottomSafeAreaHeight - 10)
            $0.height.equalTo(50)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }

    }
    
    @objc func requestNetwork() {
        ApiServiceManager.shared.plugins(list_type: 1) { [weak self] (response) in
            guard let self = self else { return }
            self.plugins = response.plugins
            self.emptyView.isHidden = self.plugins.count != 0
            self.tableView.reloadData()
            

            self.tableView.mj_header?.endRefreshing()
            
        } failureCallback: { [weak self] (code, err) in
            guard let self = self else { return }
            self.emptyView.isHidden = self.plugins.count != 0
            self.tableView.mj_header?.endRefreshing()
        }

    }
    
}

extension BrandCreationViewController {
    private func deletePlugin(plugin: Plugin) {
        self.showLoadingView()
        ApiServiceManager.shared.deletePluginById(id: plugin.id) { [weak self] _ in
            guard let self = self else { return }
            self.showToast(string: "删除成功".localizedString)
            self.hideLoadingView()
            self.requestNetwork()
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.hideLoadingView()
            self.showToast(string: err)
        }
    }


}


extension BrandCreationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plugins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BrandCreationCell.reusableIdentifier, for: indexPath) as! BrandCreationCell
        let plugin = plugins[indexPath.row]
        cell.plugin = plugin
        
        cell.deleteCallback = { [weak self] in
            guard let self = self else { return }
            if plugin.build_status == -1 {
                self.deletePlugin(plugin: plugin)
            } else {
                var message = "确定要删除该插件吗？"
                if getCurrentLanguage() == .english {
                    message = "Do you want to uninstall this plugin? "
                }
                
                TipsAlertView.show(message: message) { [weak self] in
                    guard let self = self else { return }
                    self.deletePlugin(plugin: plugin)
                }
            }  
            
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if plugins[indexPath.row].build_status != 1 {
            return
        }

        let vc = PluginDetailViewController()
        vc.isSys = false
        vc.pluginId = plugins[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension BrandCreationViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

extension BrandCreationViewController: DocumentDelegate {
    
    func uploadClick() {
        uploadAlert = UploadPluginAlertView.show { [weak self] in
            guard let self = self else { return }
            self.documentPicker.displayPicker()
        } sureCallback: { [weak self] data, fname in
            guard let self = self, let data = data, let fname = fname else {
                return
            }
            self.uploadPlugin(data: data, fileName: fname)
        }
        

    }

    func didPickDocument(document: Document?) {
        if let pickedDoc = document {
            let fileUrl = pickedDoc.fileURL
            /// do what you want with the file URL
            guard let data = try? Data(contentsOf: fileUrl) else { return }
            guard
                let fileName = fileUrl.absoluteString.components(separatedBy: "/").last,
                fileName.contains(".zip")
            else {
                showToast(string: "只能上传zip格式文件")
                return
            }

            uploadAlert?.status = .selected(data: data, fileName: fileName)
            

        }
    }
    
    
}

extension BrandCreationViewController {
    
    /// 上传插件
    /// - Parameters:
    ///   - data: 插件zip包
    ///   - fileName: 文件名
    func uploadPlugin(data: Data, fileName: String) {
        let saToken = AuthManager.shared.currentArea.sa_user_token
        guard
            let uploadUrl = URL(string: "\(AuthManager.shared.currentArea.requestURL)/api/plugins")
        else {
            print("SA地址不正确")
            return
        }

        uploadAlert?.status = .uploading
        AF.upload(multipartFormData: { formData in
            formData.append(InputStream(data: data), withLength: UInt64(data.count), name: "file", fileName: fileName, mimeType: "application/octet-stream")
            
            
        }, to: uploadUrl, headers: ["Content-Type": "multipart/form-data", "smart-assistant-token": saToken])
        .uploadProgress { progress in
            /// 上传进度
            print(progress.fractionCompleted)
        }
        .responseJSON { [weak self] resp in
            /// 上传结果
            guard let self = self else { return }
            guard let data = resp.data else {
                self.uploadAlert?.status = .failure(err: nil)
                return
            }

            let json = String(data: data, encoding: .utf8)
            print(json ?? "")
            let result = ApiServiceResponseModel<BaseModel>.deserialize(from: json)
            if result?.status == 0 { // 上传成功
                self.uploadAlert?.removeFromSuperview()
                self.requestNetwork()
            } else { // 上传失败
                self.uploadAlert?.status = .failure(err: result?.reason)
            }

        }

    }
    
}
