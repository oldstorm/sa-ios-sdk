//
//  DeviceLogoViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/2/24.
//

import UIKit


class DeviceLogoViewController: BaseViewController {
    var area: Area?
    var device: Device?
    var deviceLogos = [DeviceLogoModel]()
    var selectedLogo: DeviceLogoModel?

    private lazy var doneBtn = Button().then {
        $0.setTitle("完成".localizedString, for: .normal)
        $0.setTitleColor(.custom(.white_ffffff), for: .normal)
        $0.backgroundColor = .custom(.blue_2da3f6)
        $0.layer.cornerRadius = 10
        $0.clickCallBack = { [weak self] _ in
            guard let self = self else { return }
            self.editDeviceLogo()
        }
    }
    
    private lazy var colllectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = ZTScaleValue(15)
        flowLayout.minimumInteritemSpacing = ZTScaleValue(15)
        flowLayout.sectionInset.left = ZTScaleValue(15)
        flowLayout.sectionInset.right = ZTScaleValue(15)
        let itemW = (Screen.screenWidth - 5 * ZTScaleValue(15)) / 4
        let itemH = itemW * 11 / 8
        flowLayout.itemSize = CGSize(width: itemW, height: itemH)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DeviceLogoCell.self, forCellWithReuseIdentifier: DeviceLogoCell.reusableIdentifier)
        
        let header = ZTGIFRefreshHeader()
        collectionView.mj_header = header
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(requestNetwork))
        
        return collectionView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "更换图标".localizedString
        requestNetwork()
    }
    
    override func setupViews() {
        view.addSubview(doneBtn)
        view.addSubview(colllectionView)
        
        
        

    }
    
    override func setupConstraints() {
        doneBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-15 - Screen.bottomSafeAreaHeight)
        }
        
        colllectionView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(doneBtn.snp.top).offset(-15)
        }

    }
    
}

extension DeviceLogoViewController {
    @objc
    private func requestNetwork() {
        guard let area = area, let device_id = device?.id else { return }
        if deviceLogos.isEmpty {
            showLoadingView()
        }

        ApiServiceManager.shared.deviceLogoList(area: area, device_id: device_id) { [weak self] response in
            guard let self = self else { return }
            self.deviceLogos = response.device_logos
            self.selectedLogo = self.device?.logo
            self.colllectionView.reloadData()
            self.colllectionView.mj_header?.endRefreshing()
            self.hideLoadingView()

        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.showToast(string: err)
            self.colllectionView.mj_header?.endRefreshing()
            self.hideLoadingView()
        }

    }
    
    @objc
    private func editDeviceLogo() {
        guard let selectedLogo = selectedLogo,
              let device_id = device?.id,
              let area = area
        else {
            return
        }
        let location_id = device?.location?.id ?? 0
        let deparment_id = device?.department?.id ?? 0
        showLoadingView()
        ApiServiceManager.shared.editDevice(area: area, device_id: device_id, location_id: location_id, department_id: deparment_id, logo_type: selectedLogo.type) { [weak self] _ in
            guard let self = self else { return }
            self.hideLoadingView()
            self.showToast(string: "修改成功".localizedString)
            self.navigationController?.popViewController(animated: true)
        } failureCallback: { [weak self] code, err in
            guard let self = self else { return }
            self.hideLoadingView()
            self.showToast(string: err)
        }


    }
    
}

extension DeviceLogoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deviceLogos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeviceLogoCell.reusableIdentifier, for: indexPath) as! DeviceLogoCell
        cell.deviceLogo = deviceLogos[indexPath.row]

        if let selected = selectedLogo, selected == deviceLogos[indexPath.row] {
            cell.isChoosed = true
        } else {
            cell.isChoosed = false
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedLogo = deviceLogos[indexPath.row]
        collectionView.reloadData()
    }


}
