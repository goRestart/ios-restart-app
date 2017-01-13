//
//  TouchesTableView.swift
//  LetGo
//
//  Created by Juan Iglesias on 01/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class CustomTouchesTableView: UITableView {

    var isCellHiddenBlock: ((UITableViewCell) -> Bool)?
    private var touchesEnded: Bool = false
    var didSelectRowAtIndexPath: ((IndexPath) -> ())?
    
    private var pressedIndexPath: IndexPath?
    private var lastPressedTimestamp = Date()
    private let maxTimeInTouchDetection: Double = 300
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let isCellHiddenBlock = isCellHiddenBlock else {
            return super.hitTest(point, with: event)
        }
        
        let actualVisibleCells = visibleCells.filter { !isCellHiddenBlock($0) }
        for cell in actualVisibleCells {
            let convertedPoint = cell.convert(point, from: self)
            let insideCell = cell.point(inside: convertedPoint, with: event)
            if insideCell {
                pressedIndexPath = indexPath(for: cell)
                return cell
            }
        }
        return nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let indexPath = pressedIndexPath else { return }
        guard lastPressedTimestamp.timeIntervalSinceNow < maxTimeInTouchDetection else { return }
        
        pressedIndexPath = nil
        didSelectRowAtIndexPath?(indexPath)
        lastPressedTimestamp = Date()
    }
}
