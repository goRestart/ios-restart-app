//
//  UICollectionView+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 15/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


extension UIScrollView {
    
    enum RubberBandDirection {
        case Top
        case Bottom
        case Right
        case Left
    }
    
    func showRubberBandEffect(direction: RubberBandDirection) {
        let offsetMargin = CGFloat(35.0)
        let originalOffset = contentOffset
        var newOffset = originalOffset
        switch direction {
        case .Top:
            newOffset.y -= offsetMargin
        case .Bottom:
            newOffset.y += offsetMargin
        case .Left:
            newOffset.x -= offsetMargin
        case .Right:
            newOffset.x += offsetMargin
        }
        
        UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseOut, animations: { [weak self] in
            self?.contentOffset = newOffset
            }, completion: { _ in
                UIView.animateWithDuration(0.15, delay: 0.05, options: .CurveEaseIn, animations: {
                    self.contentOffset = originalOffset
                    }, completion: nil)
        })
    }
}