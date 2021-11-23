//
//  DiscoverBottomView.swift
//  ZhiTing
//
//  Created by iMac on 2021/7/12.
//

import UIKit

class DiscoverBottomView: UIView {
//    /// 设备类型列表
//    var deviceTypes = [CommonDeviceType]()
//    /// 设备列表
//    var commonDevices = [CommonDeviceDetail]()

    var selectedIndex = 0
    var selectCallback: ((CommonDevice) -> ())?
    
    var deviceListData = CommonDeviceTypeListResponse()

    private lazy var divider = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }

    private lazy var typeTableView = UITableView(frame: .zero, style: .plain).then {
        $0.delegate = self
        $0.dataSource = self
//        $0.separatorStyle = .none
        $0.separatorColor = .clear
        $0.alwaysBounceVertical = false
        $0.separatorInset.bottom = ZTScaleValue(10)
        $0.register(TypeCell.self, forCellReuseIdentifier: TypeCell.reusableIdentifier)
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var deviceCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        let itemW = (Screen.screenWidth - ZTScaleValue(115) - 4 * 15) / 3
        let itemH = ZTScaleValue(80)
        
        layout.itemSize = CGSize(width: itemW, height: itemH)
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DeviceCell.self, forCellWithReuseIdentifier: DeviceCell.reusableIdentifier)
        collectionView.backgroundColor = .custom(.white_ffffff)
        
        return collectionView
    }()
    
    private lazy var collectionViewHeader = CollectionViewHeader()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(divider)
        addSubview(typeTableView)
        addSubview(deviceCollectionView)
        addSubview(collectionViewHeader)
        
//        deviceCollectionView.mj_footer = MJRefreshBackNormalFooter()
//        deviceCollectionView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(getCommonDeviceList))

        getCommonDeviceList()
    }

    private func setupConstraints() {
        divider.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(10)
        }

        typeTableView.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.left.equalToSuperview()
            $0.top.equalTo(divider.snp.bottom)
            $0.width.equalTo(ZTScaleValue(115))
        }
        
        deviceCollectionView.snp.makeConstraints {
            $0.top.equalTo(collectionViewHeader.snp.bottom)
            $0.right.bottom.equalToSuperview()
            $0.left.equalTo(typeTableView.snp.right)
        }
        
        collectionViewHeader.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
            $0.right.equalToSuperview()
            $0.left.equalTo(typeTableView.snp.right)
        }

    }

}

extension DiscoverBottomView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if deviceListData.types.count == 0 {
            return 0
        }
        return deviceListData.types[selectedIndex].devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: DeviceCell.reusableIdentifier, for: indexPath) as! DeviceCell
        if deviceListData.types[selectedIndex].devices.count == 0 {
            return cell
        }
        cell.titleLabel.text = deviceListData.types[selectedIndex].devices[indexPath.item].name

        cell.icon.setImage(urlString: deviceListData.types[selectedIndex].devices[indexPath.item].logo, placeHolder: .assets(.default_device))

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCallback?(deviceListData.types[selectedIndex].devices[indexPath.item])
    }
    
}

extension DiscoverBottomView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceListData.types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TypeCell.reusableIdentifier, for: indexPath) as! TypeCell
        cell.titleLabel.text = deviceListData.types[indexPath.row].name
        cell.isChoosen = selectedIndex == indexPath.row

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex != indexPath.row {
            selectedIndex = indexPath.row
            collectionViewHeader.titleLabel.text = deviceListData.types[indexPath.row].name
            typeTableView.reloadData()
            deviceCollectionView.reloadData()
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ZTScaleValue(55)
    }
    
}

extension DiscoverBottomView {
    
    private func getCommonDeviceList() {
        ApiServiceManager.shared.commonDeviceList {[weak self] response in
            guard let self = self else { return }
            response.types.forEach { type in
                type.devices.forEach { device in
                    device.type = type.type
                }
            }
            self.deviceListData = response
            self.typeTableView.reloadData()
            self.collectionViewHeader.titleLabel.text = response.types.first?.name
            self.deviceCollectionView.reloadData()
        } failureCallback: { code, err in
            print(err)
        }

    }


}



extension DiscoverBottomView {
    private class TypeCell: UITableViewCell, ReusableView {
        var isChoosen: Bool? {
            didSet {
                guard let isChoosen = isChoosen else {
                    return
                }
                
                selectedBg.isHidden = !isChoosen
                titleLabel.textColor = isChoosen ? .custom(.white_ffffff) : .custom(.black_3f4663)
            }
        }

        lazy var selectedBg = UIView().then {
            $0.backgroundColor = .custom(.blue_2da3f6)
            $0.layer.cornerRadius = ZTScaleValue(17.5)
        }
        
        lazy var titleLabel = Label().then {
            $0.textColor = .custom(.white_ffffff)
            $0.font = .font(size: 12, type: .regular)
            $0.textAlignment = .center
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            contentView.backgroundColor = .custom(.white_ffffff)
            contentView.addSubview(selectedBg)
            contentView.addSubview(titleLabel)
            

            selectedBg.snp.makeConstraints {
                $0.top.equalToSuperview().offset(ZTScaleValue(10))
                $0.bottom.equalToSuperview().offset(ZTScaleValue(-10))
                $0.left.equalToSuperview().offset(ZTScaleValue(12))
                $0.right.equalToSuperview().offset(ZTScaleValue(-30))
            }
            
            titleLabel.snp.makeConstraints {
                $0.center.equalTo(selectedBg)
                $0.left.equalTo(selectedBg.snp.left).offset(12)
                $0.right.equalTo(selectedBg.snp.right).offset(-12)
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    
    private class DeviceCell: UICollectionViewCell, ReusableView {
        lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.default_device)
        }
        
        lazy var titleLabel = Label().then {
            $0.font = .font(size: ZTScaleValue(10), type: .medium)
            $0.textAlignment = .center
            $0.textColor = .custom(.black_3f4663)
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.backgroundColor = .custom(.white_ffffff)
            contentView.addSubview(icon)
            contentView.addSubview(titleLabel)
            
            icon.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.height.width.equalTo(ZTScaleValue(50))
            }
            
            titleLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(icon.snp.bottom).offset(5)
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    private class CollectionViewHeader: UIView {
        private lazy var line0 = UIView().then {
            $0.backgroundColor = .custom(.gray_eeeeee)
        }
        
        private lazy var line1 = UIView().then {
            $0.backgroundColor = .custom(.gray_eeeeee)
        }
        
        lazy var titleLabel = Label().then {
            $0.numberOfLines = 0
            $0.textColor = .custom(.black_3f4663)
            $0.font = .font(size: ZTScaleValue(12), type: .bold)
            $0.text = "设备"
            $0.textAlignment = .center
        }

        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .custom(.white_ffffff)
            addSubview(line0)
            addSubview(line1)
            addSubview(titleLabel)
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(10)
                $0.bottom.equalToSuperview().offset(-10)
                $0.centerX.equalToSuperview()
            }
            
            line0.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel.snp.centerY)
                $0.left.equalToSuperview()
                $0.right.equalTo(titleLabel.snp.left).offset(-15)
                $0.height.equalTo(0.5)
            }
            
            line1.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel.snp.centerY)
                $0.right.equalToSuperview().offset(-15)
                $0.left.equalTo(titleLabel.snp.right).offset(15)
                $0.height.equalTo(0.5)
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
