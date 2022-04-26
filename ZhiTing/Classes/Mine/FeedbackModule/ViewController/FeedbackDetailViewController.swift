//
//  FeedbackDetailViewController.swift
//  ZhiTing
//
//  Created by zy on 2022/3/23.
//

import UIKit
import SwiftUI
import AVKit


class FeedbackDetailViewController: BaseViewController {
    var feedback_id: Int?

    enum CellType {
        case type
        case category
        case contact
    }

    var cellTypes = [CellType]()
    
    private var feedback: Feedback? {
        didSet {
            guard let feedback = feedback else {
                return
            }

            switch feedback.feedbackType {
            case .problem(let category):
                typeCell.valueLabel.text = "遇到问题".localizedString
                classificationCell.valueLabel.text = category?.title
            case .suggestion(let category):
                typeCell.valueLabel.text = "提建议/意见".localizedString
                classificationCell.valueLabel.text = category?.title
            default:
                break
            }
            var cellTypes: [CellType] = [.type, .category]
            feedbackDetailLabel.text = feedback.description
            contactCell.valueLabel.text = feedback.contact_information
            if feedback.contact_information != "" {
                cellTypes.append(.contact)
            }
            self.cellTypes = cellTypes
            tableView.reloadData()
            agreeLabel.isHidden = !feedback.is_auth
            if !feedback.is_auth {
                agreeLabel.snp.makeConstraints {
                    $0.top.equalTo(line2.snp.bottom).offset(ZTScaleValue(5))
                    $0.left.equalTo(ZTScaleValue(14))
                    $0.right.equalTo(-ZTScaleValue(14))
                }
                
                line2.snp.remakeConstraints {
                    $0.top.equalTo(tableView.snp.bottom)
                    $0.left.right.equalToSuperview()
                    $0.height.equalTo(ZTScaleValue(10))
                    $0.bottom.equalToSuperview()
                }
                
                
                
            } else {
                line2.snp.remakeConstraints {
                    $0.top.equalTo(tableView.snp.bottom)
                    $0.left.right.equalToSuperview()
                    $0.height.equalTo(ZTScaleValue(10))
                }
                
                agreeLabel.snp.remakeConstraints {
                    $0.top.equalTo(line2.snp.bottom).offset(ZTScaleValue(5)).priority(.high)
                    $0.left.equalTo(ZTScaleValue(14))
                    $0.right.equalTo(-ZTScaleValue(14))
                    $0.bottom.equalToSuperview().offset(-ZTScaleValue(5)).priority(.high)
                }
            }
            
            if feedback.files?.count == 0 {
                photoCollectionView.snp.updateConstraints {
                    $0.top.equalTo(feedbackDetailLabel.snp.bottom)
                }
            }

            
            photoCollectionView.reloadData()
        }
    }
    
    private lazy var btnW: CGFloat = (Screen.screenWidth - ZTScaleValue(90)) / 5
    private lazy var btnH: CGFloat = btnW
    
    private lazy var scrollView = UIScrollView(frame: view.bounds).then {
        $0.isHidden = true
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var feedbackDetailLabel = Label().then{
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .medium)
        $0.numberOfLines = 0
       
    }
    
    //相片集
    private lazy var photoCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: btnW, height: btnH)
        //行间距
        flowLayout.minimumLineSpacing = ZTScaleValue(15)
        //列间距
        flowLayout.minimumInteritemSpacing = ZTScaleValue(15)
        flowLayout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(FeedbackDescriptionItemCell.self, forCellWithReuseIdentifier: FeedbackDescriptionItemCell.reusableIdentifier)
        cv.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        return cv
    }()
    
    lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    //类型/分类/联系方式/tableview
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
        $0.rowHeight = ZTScaleValue(50)
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        $0.delegate = self
        $0.dataSource = self
        $0.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
    }
    
    private lazy var typeCell = ValueDetailCell().then {
        $0.noArrowStyle = true
        $0.line.isHidden = true
        $0.title.text = "类型".localizedString
    }
    
    private lazy var classificationCell = ValueDetailCell().then {
        $0.noArrowStyle = true
        $0.line.isHidden = true
        $0.title.text = "分类".localizedString
    }
    
    private lazy var contactCell = ValueDetailCell().then {
        $0.noArrowStyle = true
        $0.line.isHidden = true
        $0.title.text = "联系方式".localizedString
    }
    
    lazy var line2 = UIView().then {
        $0.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    //agreeLabel
    private lazy var agreeLabel = Label().then{
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: ZTScaleValue(14), type: .regular)
        $0.numberOfLines = 0
        $0.text = "已同意工程师查看当前智慧中心、APP、设备的日志信息， 以便准确诊断问题".localizedString
        $0.isHidden = true
    }
    
    
    // MARK: - Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "反馈详情".localizedString
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
        photoCollectionView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .custom(.gray_f6f8fd)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNetwork()
    }
    
    override func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(feedbackDetailLabel)
        containerView.addSubview(photoCollectionView)
        containerView.addSubview(line)
        containerView.addSubview(tableView)
        containerView.addSubview(line2)
        containerView.addSubview(agreeLabel)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth)
        }
        
        feedbackDetailLabel.snp.makeConstraints {
            $0.top.equalTo(ZTScaleValue(20))
            $0.left.equalTo(ZTScaleValue(14))
            $0.right.equalTo(-ZTScaleValue(14))
        }
        
        photoCollectionView.snp.makeConstraints {
            $0.top.equalTo(feedbackDetailLabel.snp.bottom).offset(20)
            $0.left.equalTo(ZTScaleValue(14))
            $0.right.equalTo(-ZTScaleValue(14))
            $0.height.equalTo(ZTScaleValue(80))
        }
        
        line.snp.makeConstraints {
            $0.top.equalTo(photoCollectionView.snp.bottom).offset(25)
            $0.left.equalTo(ZTScaleValue(15))
            $0.right.equalTo(-ZTScaleValue(15))
            $0.height.equalTo(ZTScaleValue(0.5))
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom).offset(ZTScaleValue(5))
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(150))
        }
        
        line2.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(10))
        }
        
        agreeLabel.snp.makeConstraints {
            $0.top.equalTo(line2.snp.bottom).offset(ZTScaleValue(5)).priority(.high)
            $0.left.equalTo(ZTScaleValue(14))
            $0.right.equalTo(-ZTScaleValue(14))
            $0.bottom.equalToSuperview().offset(-ZTScaleValue(5)).priority(.high)
        }
        
    }
    
    private func requestNetwork() {
        guard let feedback_id = feedback_id else { return }
        showLoadingView()
        ApiServiceManager.shared.feedbackDetail(user_id: UserManager.shared.currentUser.user_id, feedback_id: feedback_id) { [weak self] response in
            self?.feedback = response
            self?.hideLoadingView()
            self?.scrollView.isHidden = false
        } failureCallback: { [weak self] code, err in
            self?.hideLoadingView()
            self?.showToast(string: err)
        }

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let height = (change?[.newKey] as? CGSize)?.height else { return }
            if (object as? UICollectionView) == photoCollectionView {
                photoCollectionView.snp.updateConstraints {
                    $0.height.equalTo(height)
                }
            } else if (object as? UITableView) == tableView {
                tableView.snp.updateConstraints {
                    $0.height.equalTo(height)
                }
            }
            
        }
    }
    
    func playVideo(urlStr: String) {
        guard let url = URL(string: urlStr) else { return }

        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: url)

        
        let controller = AVPlayerViewController()
        controller.player = player

        present(controller, animated: true) {
            player.play()
        }
    }
    
    func presentImage(urlStr: String) {
        let vc = FeedbackPresentImageViewController()
        vc.modalPresentationStyle = .popover
        vc.imageView.setImage(urlString: urlStr)
        present(vc, animated: true)
        
    }
    
    
}

extension FeedbackDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cellTypes[indexPath.row] {
        case .type:
            return typeCell
        case .category:
            return classificationCell
        case .contact:
            return contactCell
        }
    }
}


extension FeedbackDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedback?.files?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedbackDescriptionItemCell.reusableIdentifier, for: indexPath) as! FeedbackDescriptionItemCell
        cell.isAddCell = false
        cell.cancelBtn.isHidden = true
        cell.file = feedback?.files?[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let file = feedback?.files?[indexPath.row] {
            if file.file_type == "video" {
                let urlStr = file.file_url.components(separatedBy: "?").first ?? file.file_url
                playVideo(urlStr: urlStr)
            } else if file.file_type == "image" {
                let urlStr = file.file_url.components(separatedBy: "?").first ?? file.file_url
                presentImage(urlStr: urlStr)
            } else {
                let urlStr = file.file_url.components(separatedBy: "?").first ?? file.file_url
                presentImage(urlStr: urlStr)
            }
            
        }
    }
    
    
}
