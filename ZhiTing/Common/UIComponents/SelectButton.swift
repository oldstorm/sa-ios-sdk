//
//  SelectButton.swift
//  ZhiTing
//
//  Created by iMac on 2021/3/15.
//

import UIKit

class SelectButton: UIButton {
    enum SelectButtonType {
        case square
        case rounded
    }
    var clickedCallback: ((_ isSelected: Bool) -> ())?

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setImage(.assets(.selected_tick), for: .selected)
        setImage(.assets(.unselected_tick), for: .normal)
        addTarget(self, action: #selector(clicked), for: .touchUpInside)
    }
    
    convenience init(frame: CGRect = .zero, type: SelectButtonType) {
        self.init(frame: frame)
        switch type {
        case .rounded:
            setImage(.assets(.selected_tick), for: .selected)
            setImage(.assets(.unselected_tick), for: .normal)
        case .square:
            setImage(.assets(.selected_tick_square), for: .selected)
            setImage(.assets(.unselected_tick_square), for: .normal)
        }
        
        addTarget(self, action: #selector(clicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clicked() {
        self.isSelected = !isSelected
        clickedCallback?(isSelected)
    }

}
