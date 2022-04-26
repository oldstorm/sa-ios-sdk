//
//  FeedbackPresentImageViewController.swift
//  ZhiTing
//
//  Created by iMac on 2022/3/25.
//

import Foundation
import UIKit

class FeedbackPresentImageViewController: BaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    lazy var imageView = ImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .black
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    override func setupViews() {
        view.backgroundColor = .black
        view.addSubview(imageView)
    }
    
    override func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @objc func tap() {
        dismiss(animated: true)
    }
}
