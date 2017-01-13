//
//  UICollectionView+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 15/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


extension UIScrollView {
    
    enum RubberBandDirection {
        case top
        case bottom
        case right
        case left
    }
    
    func showRubberBandEffect(_ direction: RubberBandDirection) {
        let offsetMargin = CGFloat(50.0)
        let originalOffset = contentOffset
        var newOffset = originalOffset
        switch direction {
        case .top:
            newOffset.y -= offsetMargin
        case .bottom:
            newOffset.y += offsetMargin
        case .left:
            newOffset.x -= offsetMargin
        case .right:
            newOffset.x += offsetMargin
        }
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            self.contentOffset = newOffset
            }, completion: nil)
        
        UIView.animate(withDuration: 0.15, delay: 0.15, options: .curveEaseIn, animations: {
            self.contentOffset = originalOffset
            }, completion: nil)
    }
}
