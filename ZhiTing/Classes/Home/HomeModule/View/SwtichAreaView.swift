//
//  SwitchFamilyView.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/16.
//

import UIKit

// MARK: - SwtichAreaView
class SwtichAreaView: UIView {
    var selectCallback: ((_ area: Area) -> ())?

    var areas = [Area]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedArea = Area()

    private lazy var coverView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }
    
    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.layer.cornerRadius = 10
    }
    
    private lazy var label = Label().then {
        $0.text = "切换家庭".localizedString
        $0.textColor = .custom(.black_3f4663)
        $0.font = .font(size: 16, type: .bold)
    }
    
    private lazy var closeButton = Button().then {
        $0.setImage(.assets(.close_button), for: .normal)
        $0.isEnhanceClick = true
        $0.clickCallBack = { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
    
    private lazy var line = UIView().then {
        $0.backgroundColor = .custom(.gray_eeeeee)
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .custom(.white_ffffff)
        $0.separatorStyle = .none
        $0.register(SwtichAreaViewCell.self, forCellReuseIdentifier: SwtichAreaViewCell.reusableIdentifier)
        $0.rowHeight = UITableView.automaticDimension
        $0.delegate = self
        $0.dataSource = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: Screen.screenWidth, height: Screen.screenHeight))
    }
    
    private func setupViews() {
        addSubview(coverView)
        addSubview(containerView)
        containerView.addSubview(label)
        containerView.addSubview(closeButton)
        containerView.addSubview(line)
        containerView.addSubview(tableView)
        
    }
    
    private func setupConstraints() {
        coverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(10)
            $0.height.equalTo(410)
        }
        
        label.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16.5)
            $0.left.equalToSuperview().offset(18)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(label.snp.centerY)
            $0.right.equalToSuperview().offset(-15)
            $0.height.width.equalTo(14)
        }
        
        line.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.left.right.equalToSuperview()
            $0.top.equalTo(label.snp.bottom).offset(17)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(line.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10 - Screen.bottomSafeAreaHeight)
        }
    }

    @objc private func close() {
        removeFromSuperview()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
        
        
    }
    
    override func removeFromSuperview() {
        self.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: (Screen.screenHeight / 2))
        }) { (finished) in
            if finished {
                super.removeFromSuperview()
            }
        }
        
        
    }
}

extension SwtichAreaView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwtichAreaViewCell.reusableIdentifier, for: indexPath) as! SwtichAreaViewCell
        let area = areas[indexPath.row]
        cell.titleLabel.text = area.name
        if selectedArea.id == area.id && selectedArea.sa_user_token == area.sa_user_token {
            cell.titleLabel.textColor = .custom(.blue_2da3f6)
            cell.tickIcon.image = .assets(.selected_tick)
            cell.icon.image = .assets(.family_sel)
        } else {
            cell.titleLabel.textColor = .custom(.gray_94a5be)
            cell.tickIcon.image = .assets(.unselected_tick)
            cell.icon.image = .assets(.family_unsel)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedArea = areas[indexPath.row]
        tableView.reloadData()
        selectCallback?(areas[indexPath.row])
        removeFromSuperview()
    }
    
}



// MARK: - SwtichAreaViewCell
extension SwtichAreaView {
    class SwtichAreaViewCell: UITableViewCell, ReusableView {
        lazy var line = UIView().then { $0.backgroundColor = .custom(.gray_eeeeee) }
        
        lazy var icon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.family_unsel)
        }
        
        lazy var titleLabel = Label().then {
            $0.font = .font(size: 14, type: .medium)
            $0.textColor = .custom(.gray_94a5be)
            $0.text = "home"
        }

        lazy var tickIcon = ImageView().then {
            $0.contentMode = .scaleAspectFit
            $0.image = .assets(.unselected_tick)
            
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            contentView.addSubview(icon)
            contentView.addSubview(titleLabel)
            contentView.addSubview(tickIcon)
            contentView.addSubview(line)
            
            icon.snp.makeConstraints {
                $0.top.equalToSuperview().offset(21.5)
                $0.left.equalToSuperview().offset(17)
                $0.height.width.equalTo(15)
            }
            
            tickIcon.snp.makeConstraints {
                $0.centerY.equalTo(icon.snp.centerY)
                $0.right.equalToSuperview().offset(-15)
                $0.height.width.equalTo(18)
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(20)
                $0.left.equalTo(icon.snp.right).offset(12.5)
                $0.right.equalTo(tickIcon.snp.left).offset(-4.5)
            }
            
            line.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(23)
                $0.right.equalToSuperview()
                $0.left.equalToSuperview().offset(44)
                $0.height.equalTo(0.5)
                $0.bottom.equalToSuperview()
            }

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
