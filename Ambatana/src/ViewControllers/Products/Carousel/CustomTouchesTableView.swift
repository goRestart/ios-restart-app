//
//  TouchesTableView.swift
//  LetGo
//
//  Created by Juan Iglesias on 01/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class CustomTouchesTableView: UITableView {

    var isCellHiddenBlock: (UITableViewCell -> Bool)?
    private var touchesEnded: Bool = false
    var didSelectRowAtIndexPath: (NSIndexPath -> ())?
    
    private var pressedIndexPath: NSIndexPath?
    private var lastPressedTimestamp = NSDate()
    private let maxTimeInTouchDetection: Double = 300
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        guard let isCellHiddenBlock = isCellHiddenBlock else {
            return super.hitTest(point, withEvent: event)
        }
        
        let actualVisibleCells = visibleCells.filter { !isCellHiddenBlock($0) }
        for cell in actualVisibleCells {
            let convertedPoint = cell.convertPoint(point, fromView: self)
            let insideCell = cell.pointInside(convertedPoint, withEvent: event)
            if insideCell {
                pressedIndexPath = indexPathForCell(cell)
                return cell
            }
        }
        return nil
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        guard let indexPath = pressedIndexPath else { return }
        guard lastPressedTimestamp.timeIntervalSinceNow < maxTimeInTouchDetection else { return }
        
        pressedIndexPath = nil
        didSelectRowAtIndexPath?(indexPath)
        lastPressedTimestamp = NSDate()
    }
}
