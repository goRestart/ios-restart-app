//
//  WebSocketClient.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

// MARK: > Request Protocol

protocol WebSocketRequestConvertible {
    var message: String { get }
    var uuid: String { get }
    var type: WebSocketRequestType { get }
}

protocol WebSocketCommandRequestConvertible: WebSocketRequestConvertible {}
protocol WebSocketEventRequestConvertible: WebSocketRequestConvertible {}
protocol WebSocketQueryRequestConvertible: WebSocketRequestConvertible {}


// MARK: > WebSocket Error

enum WebSocketError: Error {
    case notAuthenticated
    case internalError
    case userNotVerified

    init(wsErrorType: WebSocketErrorType) {
        switch wsErrorType {
        case .userNotVerified:
            self = .userNotVerified
        default:
            self = .internalError
        }
    }
}

protocol WebSocketClient {
    var eventBus: PublishSubject<ChatEvent> { get }
    var socketStatus: Variable<WebSocketStatus> { get }

    var openCompletion: (() -> ())? { get set }
    var closeCompletion: (() -> ())? { get set }

    func suspendOperations()

    func startWebSocket(_ endpoint: String)
    func closeWebSocket()
    func sendQuery(_ request: WebSocketQueryRequestConvertible, completion: ((Result<[String: Any], WebSocketError>) -> Void)?)
    func sendCommand(_ request: WebSocketCommandRequestConvertible, completion: ((Result<Void, WebSocketError>) -> Void)?)
    func sendEvent(_ request: WebSocketEventRequestConvertible)
}
