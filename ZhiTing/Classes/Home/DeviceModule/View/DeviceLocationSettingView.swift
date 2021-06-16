//
//  DeviceLocationSettingView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/16.
//

import UIKit

// MARK: - DeviceLocationSettingView
class DeviceLocationSettingView: UIView {
    var locations = [Location]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedIndex: Int = -1
    
    var selected_location_id: Int = -1

    private lazy var flowLayout = UICollectionViewFlowLayout().then {
        let sizeW = (Screen.screenWidth - 60) / 3
        let sizeH: CGFloat = 60
        $0.itemSize = CGSize(width: sizeW, height: sizeH)
        $0.minimumLineSpacing = 15
        $0.minimumInteritemSpacing = 15
        $0.headerReferenceSize = CGSize(width: Screen.screenWidth - 30, height: 15)
        $0.footerReferenceSize = CGSize(width: Screen.screenWidth - 30, height: 15)
        
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.register(DeviceLocationSettingViewCell.self, forCellWithReuseIdentifier: DeviceLocationSettingViewCell.reusableIdentifier)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DeviceLocationSettingView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeviceLocationSettingViewCell.reusableIdentifier, for: indexPath) as! DeviceLocationSettingViewCell
        cell.titleLabel.text = locations[indexPath.row].name
        cell.titleLabel.textColor = locations[indexPath.row].id == selected_location_id ? .custom(.blue_2da3f6) : .custom(.black_555b73)
        cell.layer.borderColor = locations[indexPath.row].id == selected_location_id ? UIColor.custom(.blue_2da3f6).cgColor : UIColor.custom(.gray_dde5eb).cgColor

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selected_location_id = selected_location_id == locations[indexPath.row].id ? -1 : locations[indexPath.row].id
        collectionView.reloadData()
    }
    
}



// MARK: - DeviceLocationSettingViewCell & CellModel
extension DeviceLocationSettingView {
    class DeviceLocationSettingViewCell: UICollectionViewCell, ReusableView {
        lazy var titleLabel = Label().then {
            $0.font = .font(size: 14, type: .bold)
            $0.textColor = .custom(.black_555b73)
            $0.textAlignment = .center
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.cornerRadius = 4
            layer.borderWidth = 0.5
            layer.borderColor = UIColor.custom(.gray_dde5eb).cgColor
            
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(4.5)
                $0.right.equalToSuperview().offset(-4.5)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }

}
