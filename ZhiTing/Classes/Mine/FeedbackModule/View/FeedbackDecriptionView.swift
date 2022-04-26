//
//  FeedbackDecriptionView.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/22.
//

import Foundation
import UIKit
import Combine
import AVKit

class FeedbackDecriptionView: UIView {
    private lazy var collectionViewItemWH: CGFloat = (Screen.screenWidth - 120) / 5
    
    var viewHeightChange: (() -> ())?
    
    var addItemCallback: (() -> ())?
    
    private lazy var textChangedPublisher = CurrentValueSubject<String, Never>("")
    
    var textChanged: AnyPublisher<String, Never> {
        textChangedPublisher.eraseToAnyPublisher()
    }
    
    var descriptionItems = [FeedbackDescriptionItem]()

    private lazy var typeLabel = Label().then {
        $0.attributed.text = "\("* ", .foreground(.custom(.red_fe0000)), .font(.font(size: 14, type: .bold)))\("描述".localizedString, .foreground(.custom(.black_3f4663)), .font(.font(size: 14, type: .bold)))"
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.layer.cornerRadius = 2
        
    }
    
    private lazy var textViewPlaceHolder = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "请具体描述遇到的问题".localizedString
        $0.numberOfLines = 0
    }

    lazy var textView = UITextView().then {
        $0.font = .font(size: 14, type: .regular)
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.delegate = self
    }
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: collectionViewItemWH,
                                     height: collectionViewItemWH)
        flowLayout.minimumLineSpacing = 15
        flowLayout.minimumInteritemSpacing = 15
        flowLayout.sectionInset.left = 15
        flowLayout.sectionInset.right = 15

        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.register(FeedbackDescriptionItemCell.self, forCellWithReuseIdentifier: FeedbackDescriptionItemCell.reusableIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .custom(.gray_f6f8fd)
        cv.clipsToBounds = false
        return cv
    }()

    
    private lazy var addItemPlaceHolder = Label().then {
        $0.font = .font(size: 10, type: .regular)
        $0.textColor = .custom(.gray_94a5be)
        $0.text = "添加图片或视频(选填)\n最多9张，建议视频不超过1分钟".localizedString
        $0.numberOfLines = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        collectionView.removeObserver(self, forKeyPath: "contentSize")
        textView.removeObserver(self, forKeyPath: "contentSize")
    }

    private func setupViews() {
        addSubview(typeLabel)
        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(textViewPlaceHolder)
        containerView.addSubview(collectionView)
        containerView.addSubview(addItemPlaceHolder)
        
        /// kvo
        collectionView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        textView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    private func setupConstraints() {
        typeLabel.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(typeLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalToSuperview().offset(15)
            $0.right.equalToSuperview().offset(-15)
            $0.height.equalTo(80).priority(.high)
            
        }
        
        textViewPlaceHolder.snp.makeConstraints {
            $0.top.left.equalTo(textView).offset(5.5)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(15)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(80)
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        addItemPlaceHolder.snp.makeConstraints {
            $0.centerY.equalTo(collectionView.snp.centerY)
            $0.left.equalTo(collectionView.snp.left).offset(collectionViewItemWH + 30)
            $0.right.equalToSuperview().offset(-15)
        }

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" && (object as? NSObject == collectionView) {
            guard let height = (change?[.newKey] as? CGSize)?.height else { return }
            collectionView.snp.updateConstraints {
                $0.height.equalTo(height)
            }
            viewHeightChange?()
        }
        
        if keyPath == "contentSize" && (object as? NSObject == textView) {
            guard let height = (change?[.newKey] as? CGSize)?.height else { return }
            if height > 90 {
                textView.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(15)
                    $0.left.equalToSuperview().offset(15)
                    $0.right.equalToSuperview().offset(-15)
                    $0.height.equalTo(height).priority(.high)
                    
                }
                viewHeightChange?()
            } else if height < 90 {
                textView.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(15)
                    $0.left.equalToSuperview().offset(15)
                    $0.right.equalToSuperview().offset(-15)
                    $0.height.equalTo(80).priority(.high)
                    
                }
                viewHeightChange?()
            }

            
        }
    }
    
}

extension FeedbackDecriptionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        addItemPlaceHolder.isHidden = descriptionItems.count > 0
        if descriptionItems.count < 9 {
            return descriptionItems.count + 1
        }
        
        return descriptionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedbackDescriptionItemCell.reusableIdentifier, for: indexPath) as! FeedbackDescriptionItemCell
        cell.isAddCell = indexPath.row > descriptionItems.count - 1
        if indexPath.row <= descriptionItems.count - 1 {
            cell.item = descriptionItems[indexPath.row]
            cell.cancellCallback = { [weak self] in
                guard let self = self else { return }
                self.descriptionItems.remove(at: indexPath.row)
                self.collectionView.reloadData()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > descriptionItems.count - 1 { /// 添加item
            addItemCallback?()
        }
    }
    
    
}

extension FeedbackDecriptionView: UITextViewDelegate {

    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let text = textView.text else { return }
        if text.count > 300 {
            textView.text = String(text.prefix(300))
        }
        
        textChangedPublisher.send(String(text.prefix(300)))
        textViewPlaceHolder.isHidden = String(text.prefix(300)).count > 0
    }
}

// MARK: - Cells
class FeedbackDecriptionViewCell: UITableViewCell, ReusableView {
    lazy var descriptionView = FeedbackDecriptionView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .custom(.white_ffffff)
        contentView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class FeedbackDescriptionItemCell: UICollectionViewCell, ReusableView {
    var item: FeedbackDescriptionItem? {
        didSet {
            guard let item = item else {
                return
            }

            imageView.backgroundColor = .custom(.black_333333)
            imageView.image = item.cover
        }
    }
    
    var file: FileModel? {
        didSet {
            guard let file = file else {
                return
            }
            
            imageView.backgroundColor = .custom(.black_333333)
            playLabel.isHidden = true
            if file.file_type == "image", let urlStr = file.file_url.components(separatedBy: "?").first {
                imageView.setImage(urlString: urlStr, placeHolder: .assets(.default_avatar))
            } else if let urlStr = file.file_url.components(separatedBy: "?").first, let url = URL(string: urlStr), file.file_type == "video" {
                getThumbnailImage(forUrl: url)
                playLabel.isHidden = false
            } else {
                if let urlStr = file.file_url.components(separatedBy: "?").first {
                    imageView.setImage(urlString: urlStr, placeHolder: .assets(.default_avatar))
                }
            }
            
        }
    }
    
    var isAddCell = false {
        didSet {
            imageView.isHidden = isAddCell
            cancelBtn.isHidden = isAddCell
            addIcon.isHidden = !isAddCell
            addLabel.isHidden = !isAddCell
            
            if isAddCell {
                layer.addSublayer(dottedLayer)
            } else {
                dottedLayer.removeFromSuperlayer()
            }
        }
    }

    var cancellCallback: (() -> ())? {
        didSet {
            cancelBtn.clickCallBack = { [weak self] _ in
                self?.cancellCallback?()
            }
        }
    }

    private lazy var imageView = ImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private lazy var playLabel = ImageView().then {
        $0.image = .assets(.btn_play)
        $0.isHidden = true
    }

    
    lazy var cancelBtn = Button().then {
        $0.layer.cornerRadius = 9
        $0.backgroundColor = .custom(.black_3f4663).withAlphaComponent(0.9)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("x", for: .normal)
        $0.titleLabel?.font = .font(size: 10, type: .bold)
        $0.titleLabel?.textAlignment = .center
        $0.isEnhanceClick = true
    }

    private lazy var addIcon = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.icon_add_photo)
    }
    
    private lazy var addLabel = Label().then {
        $0.font = .font(size: 10, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.textAlignment = .center
        $0.text = "添加图片".localizedString
    }
    
    private lazy var dottedLayer: CAShapeLayer = {
        let borderLayer =  CAShapeLayer()
        borderLayer.bounds = self.bounds
        
        borderLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY);
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: 4).cgPath
        borderLayer.lineWidth = 2 / UIScreen.main.scale
        
        //虚线边框---小边框的长度
        borderLayer.lineDashPattern = [5, 2] as? [NSNumber]
        borderLayer.lineDashPhase = 0.1;
        //实线边框
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.custom(.gray_94a5be).cgColor
        
        return borderLayer
    }()

    
    func getThumbnailImage(forUrl url: URL) {
        DispatchQueue.global().async {
            let asset: AVAsset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)

            if let thumbnailImage = try? imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil) {
                let img = UIImage(cgImage: thumbnailImage)
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = img
                }
            }
            
        }
        
       
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        contentView.addSubview(imageView)
        contentView.addSubview(addIcon)
        contentView.addSubview(addLabel)
        contentView.addSubview(cancelBtn)
        
        imageView.addSubview(playLabel)

        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        playLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(22)
        }
        
        addIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ZTScaleValue(19))
            $0.height.equalTo(ZTScaleValue(16))
        }
        
        addLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(addIcon.snp.bottom).offset(4.5)
        }
        
        cancelBtn.snp.makeConstraints {
            $0.right.equalToSuperview().offset(4)
            $0.top.equalToSuperview().offset(-7)
            $0.width.height.equalTo(18)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  
}

struct FeedbackDescriptionItem {
    let file_id: Int
    let cover: UIImage
    let data: Data
}
