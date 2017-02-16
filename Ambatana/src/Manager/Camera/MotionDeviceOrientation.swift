//
//  MotionDeviceOrientation.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import CoreMotion

class MotionDeviceOrientation {

    var orientation: UIDeviceOrientation {
        return deviceOrientationFromAccelerometer()
    }

    var matchesDeviceOrientation: Bool {
        return orientation == UIDevice.current.orientation
    }

    private let motionManager: CMMotionManager

    init() {
        self.motionManager = CMMotionManager()
        setup()
    }

    private func setup() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    #if !TARGET_IPHONE_SIMULATOR
        motionManager.accelerometerUpdateInterval = 0.005
        motionManager.startAccelerometerUpdates()
    #endif
    }

    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    #if !TARGET_IPHONE_SIMULATOR
        motionManager.stopAccelerometerUpdates()
    #endif
    }

    private func deviceOrientationFromAccelerometer() -> UIDeviceOrientation {
    #if TARGET_IPHONE_SIMULATOR
        return .portrait
    #else
        guard let acceleration = motionManager.accelerometerData?.acceleration else { return .portrait }
        if acceleration.z < -0.75 { return .faceUp }
        if acceleration.z > 0.75 { return .faceDown }

        let scaling: Double = Double(1) / (abs(acceleration.x) + abs(acceleration.y))
        let x: Double = acceleration.x * scaling
        let y: Double = acceleration.y * scaling

        if x < -0.5 { return .landscapeLeft }
        if x > 0.5 { return .landscapeRight }

        if y > 0.5 { return .portraitUpsideDown }
        
        return .portrait;
    #endif
    }
}
