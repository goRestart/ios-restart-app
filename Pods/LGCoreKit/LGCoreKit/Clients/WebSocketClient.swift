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

enum WebSocketError: ErrorType {
    case NotAuthenticated
    case Internal
}

protocol WebSocketClient {
    var eventBus: PublishSubject<ChatEvent> { get }
    var socketStatus: Variable<WebSocketStatus> { get }
    
    func suspendOperations()
    func resumeOperations()

    func startWebSocket(endpoint: String, completion: (() -> ())?)
    func closeWebSocket(completion: (() -> ())?)
    func sendQuery(request: WebSocketQueryRequestConvertible, completion: (Result<[String: AnyObject], WebSocketError> -> Void)?)
    func sendCommand(request: WebSocketCommandRequestConvertible, completion: (Result<Void, WebSocketError> -> Void)?)
    func sendEvent(request: WebSocketEventRequestConvertible)
}
