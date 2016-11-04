//
//  CGPoint+LG.swift
//  LetGo
//
//  Created by Albert Hernández López on 04/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension CGPoint {
    func distanceTo(point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }

    func nearestPointTo(points: [CGPoint]) -> CGPoint? {
        guard !points.isEmpty else { return nil }

        var nearestPoint: CGPoint = CGPoint.zero
        var distance: CGFloat = CGFloat.max

        for point in points {
            let distanceToPoint = distanceTo(point)
            if distanceToPoint < distance {
                nearestPoint = point
                distance = distanceToPoint
            }
        }
        return nearestPoint
    }
}
