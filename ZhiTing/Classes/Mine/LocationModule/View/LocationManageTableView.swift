//
//  LocationManageTableView.swift
//  ZhiTing
//
//  Created by iMac on 2021/4/29.
//

import UIKit

class LocationManageTableView: UITableView {
    typealias ExchangeCallback = ((_ dataArray: [Location]) -> ())
    /// snapshot触碰到底部或顶部枚举类型
    enum SnapshotMeetsEdge {
        case top
        case bottom
    }
    
    var dataArray = [Location]()

    /// 需要移动的indexPath
    var indexPath: IndexPath?
    /// 需要移动的cell
    var moveCell: UITableViewCell?
    /// 需要移动的cell的snapshot
    var snapView: UIView?
    /// 自动滚动方向
    var autoScrollDirection: SnapshotMeetsEdge = .bottom
    
    /// 自动滚动计时器
    var autoScrollTimer: CADisplayLink?
    
    /// 交换后回调
    var exchaneCallback: ExchangeCallback?

    
    func setDataWithArray(locations: [Location], callback: @escaping ExchangeCallback) {
        self.dataArray = locations
        self.exchaneCallback = callback
        let longpressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.addGestureRecognizer(longpressGes)
    }

}

extension LocationManageTableView {
    @objc private func longPress(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            self.reloadData()
            let point = longPress.location(ofTouch: 0, in: longPress.view)
            self.indexPath = self.indexPathForRow(at: point)
            
            if let indexPath = indexPath {
                DispatchQueue.main.async {
                    self.moveCell = self.cellForRow(at: indexPath)
                    self.snapView = self.moveCell?.snapshotView(afterScreenUpdates: false)
                    if let snapView = self.snapView {
                        snapView.frame = self.moveCell?.frame ?? .zero
                        self.addSubview(snapView)
                        self.moveCell?.isHidden = true
                        
                        UIView.animate(withDuration: 0.1) {
                            snapView.transform = CGAffineTransform(scaleX: 1.03, y: 1.05)
                            snapView.alpha = 0.8
                        }
                    }
                    
                }
            }


        case .changed:
            let point = longPress.location(ofTouch: 0, in: longPress.view)
            var center = self.snapView?.center ?? .zero
            center.y = point.y
            self.snapView?.center = center
            
            if checkIfSnapshotMeetsEdge() {
                startAutoScrollTimer()
            } else {
                stopAutoScrollTimer()
            }
            
            if let exchangeIndexPath = indexPathForRow(at: point), let indexPath = indexPath {
                updateDataWithIndexPath(moveIndexPath: exchangeIndexPath)
                moveRow(at: indexPath, to: exchangeIndexPath)
                self.indexPath = exchangeIndexPath
            }
            

        break

        case .ended:
            DispatchQueue.main.async {
                guard let indexPath = self.indexPath else { return }
                self.moveCell = self.cellForRow(at: indexPath)
                UIView.animate(withDuration: 0.2) {
                    self.snapView?.center = self.moveCell?.center ?? .zero
                    self.snapView?.transform = .identity
                    self.snapView?.alpha = 1.0
                } completion: { finish in
                    self.moveCell?.isHidden = false
                    self.snapView?.removeFromSuperview()
                    self.stopAutoScrollTimer()
                }


            }
            


        default:
            break
        }
        
        
    }
    
    /// 检测snapview是否触碰到顶部或底部
    private func checkIfSnapshotMeetsEdge() -> Bool {
        guard let snapView = snapView else { return false }
        let minY = snapView.frame.minY
        let maxY = snapView.frame.maxY
        
        if minY < contentOffset.y {
            autoScrollDirection = .top
            return true
        }
        
        if maxY > bounds.size.height + contentOffset.y {
            autoScrollDirection = .bottom
            return true
        }
        
        return false


    }
    

}

extension LocationManageTableView {
    private func startAutoScrollTimer() {
        autoScrollTimer = CADisplayLink(target: self, selector: #selector(startAutoScroll))
        autoScrollTimer?.add(to: RunLoop.main, forMode: .common)

    }
    
    
    private func stopAutoScrollTimer() {
        autoScrollTimer?.invalidate()
    }
    
    @objc private func startAutoScroll() {
        let pixelSpeed: CGFloat = 4
        guard let snapView = snapView else { return }
        switch autoScrollDirection {
        case .top: // 向上滚动
            if contentOffset.y > 0 {
                setContentOffset(CGPoint(x: 0, y: self.contentOffset.y - pixelSpeed), animated: true)
                self.snapView?.center = CGPoint(x: snapView.center.x, y: snapView.center.y + pixelSpeed)
            }
        case .bottom: // 向下滚动
            if contentOffset.y + bounds.size.height < contentSize.height {
                setContentOffset(CGPoint(x: 0, y: contentOffset.y + pixelSpeed), animated: true)
                self.snapView?.center = CGPoint(x: snapView.center.x, y: snapView.center.y + pixelSpeed)
            }
            
        }
        
        if let exchangeIndexPath = indexPathForRow(at: snapView.center), let indexPath = indexPath {
            updateDataWithIndexPath(moveIndexPath: exchangeIndexPath)
            moveRow(at: indexPath, to: exchangeIndexPath)
            self.indexPath = exchangeIndexPath
        }

    }
    
    

}

extension LocationManageTableView {
    private func updateDataWithIndexPath(moveIndexPath: IndexPath) {
        guard let idx = indexPath?.row else { return }
        let exchangeIdx = moveIndexPath.row
        swap(&dataArray[idx], &dataArray[exchangeIdx])
        exchaneCallback?(dataArray)
    }
    
    
}

