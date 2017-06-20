//
//  UserAgentBuilder.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 19/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Alamofire
import DeviceGuru

protocol UserAgentBuilder {
    func make(appBundle: Bundle) -> String
}

final class LGUserAgentBuilder: UserAgentBuilder {
    // Makes a User-Agent with the following the format:
    // target:LetGoGodMode; appVersion:1.17.5; bundle:com.letgo.ios; build:250; os:iOS 10.2.0;
    // device:Apple iPhone 6 Plus; httpLibrary:Alamofire/4.2.0
    func make(appBundle: Bundle) -> String {
        return "target:\(makeTarget(appBundle: appBundle)); " +
            "appVersion:\(makeAppVersion(appBundle: appBundle)); " +
            "bundle:\(makeBundle(appBundle: appBundle)); " +
            "build:\(makeBuild(appBundle: appBundle)); " +
            "os:\(makeOS()); " +
            "device:\(makeDevice()); " +
        "httpLibrary:\(makeHTTPLibrary())"
    }
    
    private func makeTarget(appBundle: Bundle) -> String {
        guard let info = appBundle.infoDictionary else { return "Unknown" }
        return info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
    }
    
    private func makeAppVersion(appBundle: Bundle) -> String {
        guard let info = appBundle.infoDictionary else { return "Unknown" }
        return info["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private func makeBundle(appBundle: Bundle) -> String {
        guard let info = appBundle.infoDictionary else { return "Unknown" }
        return info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
    }
    
    private func makeBuild(appBundle: Bundle) -> String {
        guard let info = appBundle.infoDictionary else { return "Unknown" }
        return info[kCFBundleVersionKey as String] as? String ?? "Unknown"
    }
    
    private func makeOS() -> String {
        let operatingSystem: String
        #if os(iOS)
            operatingSystem = "iOS"
        #elseif os(watchOS)
            operatingSystem = "watchOS"
        #elseif os(tvOS)
            operatingSystem = "tvOS"
        #elseif os(macOS)
            operatingSystem = "OS X"
        #elseif os(Linux)
            operatingSystem = "Linux"
        #else
            operatingSystem = "Unknown"
        #endif
        
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        return "\(operatingSystem) \(versionString)"
    }
    
    private func makeDevice() -> String {
        let model = DeviceGuru.hardwareDescription() ?? "Unknown"
        return "Apple \(model)"
    }
    
    private func makeHTTPLibrary() -> String {
        guard let info = Bundle(for: Alamofire.SessionManager.self).infoDictionary else { return "Unknown" }
        let build = info["CFBundleShortVersionString"] as? String ?? "Unknown"
        return "Alamofire/\(build)"
    }
}
