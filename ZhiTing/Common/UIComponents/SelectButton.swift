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
    
    /// if enhance the click scope
    lazy var isEnhanceClick = true
    /// enhance offset
    lazy var enhanceOffset: CGFloat = -20
    
    var clickedCallback: ((_ isSelected: Bool) -> ())?

    var type: SelectButtonType? {
        didSet {
            guard let type = type else {
                return
            }

            switch type {
            case .rounded:
                setImage(.assets(.selected_tick), for: .selected)
                setImage(.assets(.unselected_tick), for: .normal)
            case .square:
                setImage(.assets(.selected_tick_square), for: .selected)
                setImage(.assets(.unselected_tick_square), for: .normal)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setImage(.assets(.selected_tick), for: .selected)
        setImage(.assets(.unselected_tick), for: .normal)
        addTarget(self, action: #selector(clicked), for: .touchUpInside)
    }
    
    
    convenience init(frame: CGRect = .zero, type: SelectButtonType) {
        self.init(frame: frame)
        self.type = type
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
    
    @objc func clicked() {
        self.isSelected = !isSelected
        clickedCallback?(isSelected)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isEnhanceClick {
            let biggerFrame = self.bounds.inset(by: UIEdgeInsets.init(top: enhanceOffset, left: enhanceOffset, bottom: enhanceOffset, right: enhanceOffset))
            return biggerFrame.contains(point)
        } else {
            return super.point(inside: point, with: event)
        }
        
    }
}
