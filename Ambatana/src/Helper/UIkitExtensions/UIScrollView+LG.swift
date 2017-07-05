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
    
    func showRubberBandEffect(_ direction: RubberBandDirection, offset: CGFloat) {
        let originalOffset = contentOffset
        var newOffset = originalOffset
        switch direction {
        case .top:
            newOffset.y -= offset
        case .bottom:
            newOffset.y += offset
        case .left:
            newOffset.x -= offset
        case .right:
            newOffset.x += offset
        }

        setContentOffset(newOffset, animated: true)
        delay(0.15) { 
            self.setContentOffset(originalOffset, animated: true)
        }
    }
}
