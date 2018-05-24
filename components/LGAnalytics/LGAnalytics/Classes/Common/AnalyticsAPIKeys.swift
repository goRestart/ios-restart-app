//
//  AnalyticsAPIKeys.swift
//  LGAnalytics
//
//  Created by Albert Hernández López on 29/03/2018.
//

public protocol AnalyticsAPIKeys {
    // Amplitude
    var amplitudeAPIKey: String { get }
    // AppsFlyer
    var appsFlyerAPIKey: String { get }
    var appsFlyerAppleAppId: String { get }
    var appsFlyerAppInviteOneLinkID: String { get }
    // Leanplum
    var leanplumAppId: String { get }
    var leanplumEnvKey: String { get }
}
