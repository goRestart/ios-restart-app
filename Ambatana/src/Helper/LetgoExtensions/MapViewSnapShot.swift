//
//  MapViewSnapShot.swift
//  LetGo
//
//  Created by Facundo Menzella on 30/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    static func snapshotAt(_ region: MKCoordinateRegion, size: CGSize?,
                           with completionHandler: @escaping MapKit.MKMapSnapshotCompletionHandler) {
        let options = MKMapSnapshotOptions()
        options.scale = UIScreen.main.scale
        options.region = region
        if let newSize = size {
            options.size = newSize
        }

        let snapshooter = MKMapSnapshotter(options: options)
        snapshooter.start(completionHandler: completionHandler)
    }
}
