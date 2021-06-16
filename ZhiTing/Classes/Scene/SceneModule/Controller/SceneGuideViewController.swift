//
//  SceneGuideViewController.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/19.
//

import UIKit

class SceneGuideViewController: BaseViewController {
    private lazy var scrollView = UIScrollView(frame: view.bounds)

    private lazy var containerView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
 
    private lazy var titleLabel0 = Label().then {
        $0.font = .font(size: 18, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "创建步骤".localizedString
        $0.numberOfLines = 0
    }
    
    
    
    private lazy var createStepLabel1 = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "1.添加设备".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var createStepLabel2 = Label().then {
        $0.font = .font(size: 14, type: .bold)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "2.创建场景".localizedString
        $0.numberOfLines = 0
    }
    
    
    private lazy var createStepDetailLabel0 = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "创建智能场景前请确保您的家庭已添加设备".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var createStepDetailLabel1 = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "① 点击智汀APP下方导航栏“场景”→点击“+”，进入场景编排".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var createStepDetailLabel2 = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "② 填写场景名称。比如：看电影".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var createStepDetailLabel3 = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "③ 点击“添加触发条件”，选择触发类型，设置触发条件。\n比如：“设备状态变化时”→“卧室台灯”→“开关打开”→“下一步”，完成触发条件的添加。".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var createStepDetailLabel4 = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "④ 点击“添加执行任务”，选择任务类型，设置执行事件。\n比如：“智能设备”→“卧室台灯”→“亮度”→“下一步”，完成执行任务的添加。".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var createStepDetailLabel5 = Label().then {
        $0.font = .font(size: 14, type: .regular)
        $0.textColor = .custom(.black_3f4663)
        $0.text = "⑤ 点击右上角的“完成”，完成场景创建".localizedString
        $0.numberOfLines = 0
    }
    
    private lazy var guideImg1 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_img1)
    }

    private lazy var guideImg2 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_img2)
    }
    
    private lazy var guideImg3 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_img3)
    }
    
    private lazy var guideImg4 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_img4)
    }
    
    private lazy var guideImg5 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_img5)
    }
    
    private lazy var guideImg6 = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .assets(.guide_img6)
    }
    

    private lazy var bottomView = UIView().then {
        $0.backgroundColor = .custom(.white_ffffff)
    }
    
    private lazy var createSceneBtn = ImageTitleButton(frame: .zero, icon: nil, title: "去创建场景".localizedString, titleColor: .custom(.white_ffffff), backgroundColor: .custom(.blue_2da3f6))
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "如何创建场景".localizedString
        bottomView.isHidden = !authManager.currentRolePermissions.add_scene
        
    }

    override func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)

        containerView.addSubview(guideImg1)
        containerView.addSubview(guideImg2)
        containerView.addSubview(guideImg3)
        containerView.addSubview(guideImg4)
        containerView.addSubview(guideImg5)
        containerView.addSubview(guideImg6)
        
        
        containerView.addSubview(titleLabel0)
        
        
        containerView.addSubview(createStepLabel1)
        containerView.addSubview(createStepLabel2)
        
        containerView.addSubview(createStepDetailLabel0)
        containerView.addSubview(createStepDetailLabel1)
        containerView.addSubview(createStepDetailLabel2)
        containerView.addSubview(createStepDetailLabel3)
        containerView.addSubview(createStepDetailLabel4)
        containerView.addSubview(createStepDetailLabel5)
        
        view.addSubview(bottomView)
        bottomView.addSubview(createSceneBtn)
        
        createSceneBtn.clickCallBack = { [weak self] in
            guard let self = self else { return }

            let vc = EditSceneViewController(type: .create)
            self.navigationController?.pushViewController(vc, animated: true)
            
            if let count = self.navigationController?.viewControllers.count, count - 2 > 0 {
                self.navigationController?.viewControllers.remove(at: count - 2)
            }
        }
        
    }
    
    override func setupConstraints() {
        bottomView.snp.makeConstraints {
            $0.height.equalTo(70 + Screen.bottomSafeAreaHeight)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        createSceneBtn.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-10) - Screen.bottomSafeAreaHeight)
        }
        
        containerView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
            $0.width.equalTo(Screen.screenWidth)
        }
        
        guideImg1.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(ZTScaleValue(230))
        }
        
        titleLabel0.snp.makeConstraints {
            $0.top.equalTo(guideImg1.snp.bottom).offset(ZTScaleValue(26))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
        }
        
        createStepLabel1.snp.makeConstraints {
            $0.top.equalTo(titleLabel0.snp.bottom).offset(ZTScaleValue(15))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
        }
        
        createStepDetailLabel0.snp.makeConstraints {
            $0.top.equalTo(createStepLabel1.snp.bottom).offset(ZTScaleValue(15))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }

        createStepLabel2.snp.makeConstraints {
            $0.top.equalTo(createStepDetailLabel0.snp.bottom).offset(ZTScaleValue(42))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
        }
        
        createStepDetailLabel1.snp.makeConstraints {
            $0.top.equalTo(createStepLabel2.snp.bottom).offset(ZTScaleValue(15))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        guideImg2.snp.makeConstraints {
            $0.top.equalTo(createStepDetailLabel1.snp.bottom).offset(ZTScaleValue(20))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(ZTScaleValue(243))
        }
        
        createStepDetailLabel2.snp.makeConstraints {
            $0.top.equalTo(guideImg2.snp.bottom).offset(ZTScaleValue(30))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        guideImg3.snp.makeConstraints {
            $0.top.equalTo(createStepDetailLabel2.snp.bottom).offset(ZTScaleValue(20))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(ZTScaleValue(475))
        }
        
        createStepDetailLabel3.snp.makeConstraints {
            $0.top.equalTo(guideImg3.snp.bottom).offset(ZTScaleValue(30))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        guideImg4.snp.makeConstraints {
            $0.top.equalTo(createStepDetailLabel3.snp.bottom).offset(ZTScaleValue(20))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(ZTScaleValue(280))
        }
        
        createStepDetailLabel4.snp.makeConstraints {
            $0.top.equalTo(guideImg4.snp.bottom).offset(ZTScaleValue(30))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }

        guideImg5.snp.makeConstraints {
            $0.top.equalTo(createStepDetailLabel4.snp.bottom).offset(ZTScaleValue(20))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(ZTScaleValue(202))
        }
        
        createStepDetailLabel5.snp.makeConstraints {
            $0.top.equalTo(guideImg5.snp.bottom).offset(ZTScaleValue(30))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
        }
        
        guideImg6.snp.makeConstraints {
            $0.top.equalTo(createStepDetailLabel5.snp.bottom).offset(ZTScaleValue(20))
            $0.left.equalToSuperview().offset(ZTScaleValue(15))
            $0.right.equalToSuperview().offset(ZTScaleValue(-15))
            $0.height.equalTo(ZTScaleValue(570))
            $0.bottom.equalToSuperview().offset(ZTScaleValue(-180))
        }
        
        
        
    }
    
    
}
 
