//
//  UserAgentBuilder.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 19/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Alamofire
import DeviceGuru
import SocketRocket

enum NetworkLibrary {
    case alamofire, socketRocket
    
    func makeHTTPLibraryUserAgentValue() -> String {
        let httpLibName: String
        let bundle: Bundle
        switch self {
        case .alamofire:
            httpLibName = "Alamofire"
            bundle = Bundle(for: Alamofire.SessionManager.self)
        case .socketRocket:
            httpLibName = "SocketRocket"
            bundle = Bundle(for: SocketRocket.SRWebSocket.self)
        }
        guard let info = bundle.infoDictionary else { return LGUserAgentBuilder.unknown }
        let build = info["CFBundleShortVersionString"] as? String ?? LGUserAgentBuilder.unknown
        return "\(httpLibName)/\(build)"
    }
}

protocol UserAgentBuilder {
    func make(appBundle: Bundle, networkLibrary: NetworkLibrary) -> String
}

final class LGUserAgentBuilder: UserAgentBuilder {
    fileprivate static let unknown = "Unknown"
    
    // Makes a User-Agent with the following the format:
    // target:LetGoGodMode; appVersion:1.17.5; bundle:com.letgo.ios; build:250; os:iOS 10.2.0;
    // device:Apple iPhone 6 Plus; httpLibrary:Alamofire/4.2.0
    func make(appBundle: Bundle, networkLibrary: NetworkLibrary) -> String {
        return "target=\(makeTarget(appBundle: appBundle)); " +
            "appVersion=\(makeAppVersion(appBundle: appBundle)); " +
            "bundle=\(makeBundle(appBundle: appBundle)); " +
            "build=\(makeBuild(appBundle: appBundle)); " +
            "os=\(makeOS()); " +
            "device=\(makeDevice()); " +
            "httpLibrary=\(networkLibrary.makeHTTPLibraryUserAgentValue())"
    }
    
    private func makeTarget(appBundle: Bundle) -> String {
        guard let info = appBundle.infoDictionary else { return LGUserAgentBuilder.unknown }
        return info[kCFBundleExecutableKey as String] as? String ?? LGUserAgentBuilder.unknown
    }
    
    private func makeAppVersion(appBundle: Bundle) -> String {
        guard let info = appBundle.infoDictionary else { return LGUserAgentBuilder.unknown }
        return info["CFBundleShortVersionString"] as? String ?? LGUserAgentBuilder.unknown
    }
    
    private func makeBundle(appBundle: Bundle) -> String {
        guard let info = appBundle.infoDictionary else { return LGUserAgentBuilder.unknown }
        return info[kCFBundleIdentifierKey as String] as? String ?? LGUserAgentBuilder.unknown
    }
    
    private func makeBuild(appBundle: Bundle) -> String {
        guard let info = appBundle.infoDictionary else { return LGUserAgentBuilder.unknown }
        return info[kCFBundleVersionKey as String] as? String ?? LGUserAgentBuilder.unknown
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
            operatingSystem = LGUserAgentBuilder.unknown
        #endif
        
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        return "\(operatingSystem) \(versionString)"
    }
    
    private func makeDevice() -> String {
        let model = DeviceGuru.hardwareDescription() ?? LGUserAgentBuilder.unknown
        return "Apple \(model)"
    }
}
