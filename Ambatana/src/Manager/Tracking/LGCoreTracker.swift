import Foundation
import LGCoreKit
import Alamofire

final class LGCoreTracker: CoreTracker {
    private let tracker: TrackerProxy
    private let reachability: ReachabilityProtocol
    private let featureFlags: FeatureFlaggeable

    convenience init() {
        self.init(tracker: TrackerProxy.sharedInstance, reachability: LGReachability(), featureFlags: FeatureFlags.sharedInstance)
    }

    private init(tracker: TrackerProxy, reachability: ReachabilityProtocol, featureFlags: FeatureFlaggeable) {
        self.tracker = tracker
        self.reachability = reachability
        self.featureFlags = featureFlags

        reachability.reachableBlock = { [weak self] connection in
            if featureFlags.emptyStateErrorResearchActive {
                self?.tracker.trackEvent(TrackerEvent.connectivityChange(connectivity: connection.description))
            }
        }

        reachability.unreachableBlock = { [weak self] connection in
            if featureFlags.emptyStateErrorResearchActive {
                self?.tracker.trackEvent(TrackerEvent.connectivityChange(connectivity: connection.description))
            }
        }
        reachability.start()
    }

    func trackRefreshTokenResponse(origin: EventParameterRefreshTokenOrigin, success: Bool, description: String?) {
        if featureFlags.emptyStateErrorResearchActive {
            tracker.trackEvent(TrackerEvent.refreshTokenResponse(origin: origin,
                                                                 success: success,
                                                                 description: description))
        }
    }

    func trackRefreshToken(origin: EventParameterRefreshTokenOrigin,
                           originDomain: String?,
                           tokenLevel: EventParameterAuthLevel) {
        if featureFlags.emptyStateErrorResearchActive {
            switch origin {
            case .api:
                tracker.trackEvent(TrackerEvent.refreshToken(origin: origin,
                                                             originDomain: originDomain,
                                                             tokenLevel: tokenLevel))
            case .websocket:
                tracker.trackEvent(TrackerEvent.refreshToken(origin: origin,
                                                             originDomain: nil,
                                                             tokenLevel: tokenLevel))
            }
        }
    }

    func trackRequestTimeOut(host: String,
                             endpoint: String,
                             statusCode: Int?,
                             errorCode: Int?,
                             timeline: Timeline) {
        if featureFlags.emptyStateErrorResearchActive {
            tracker.trackEvent(TrackerEvent.requestTimeOut(host: host,
                                                           endpoint: endpoint,
                                                           totalDuration: timeline.totalDuration,
                                                           requestDuration: timeline.requestDuration,
                                                           statusCode: statusCode,
                                                           errorCode: errorCode))
        }

    }
}
