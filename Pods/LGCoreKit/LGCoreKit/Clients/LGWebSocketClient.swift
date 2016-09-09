//
//  LGWebSocketClient.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import SwiftWebSocket
import RxSwift
import ReachabilitySwift

enum WebSocketStatus: Equatable {
    case Closed
    case Open(authenticated: Bool)
    case Opening
    case Closing
}

func ==(a: WebSocketStatus, b: WebSocketStatus) -> Bool {
    switch (a, b) {
    case (.Open(let a),   .Open(let b))   where a == b: return true
    case (.Closed, .Closed): return true
    case (.Opening, .Opening): return true
    case (.Closing, .Closing): return true
    default: return false
    }
}

struct WebSocketClientError {
    static var ManuallyClosed = 1000
    static var AbnormalClosure = 1006
}

class LGWebSocketClient: WebSocketClient {
    
    let ws = WebSocket()
    
    private var activeCommands: [String: (Result<Void, WebSocketError> -> Void)] = [:]
    private var activeQueries: [String: (Result<[String: AnyObject], WebSocketError> -> Void)] = [:]
    private var activeRequests: [String: WebSocketRequestConvertible] = [:]
    private var activeAuthRequests: [String: (Result<Void, WebSocketError> -> Void)] = [:]

    private let reachability: Reachability?
    private var openClosure: (() -> ())?
    private var closeClosure: (() -> ())?
    private var pingTimer: NSTimer?
    
    let requestQueue = NSOperationQueue()
    let eventBus = PublishSubject<ChatEvent>()
    var socketStatus = Variable<WebSocketStatus>(.Closed)

    
    init() {
        requestQueue.maxConcurrentOperationCount = 1
        self.reachability = try? Reachability.reachabilityForInternetConnection()
    }
    
    deinit {
        pingTimer?.invalidate()
    }
    
    
    func configureReachability() {
        reachability?.whenReachable = { reach in
            InternalCore.sessionManager.authenticateWebSocket(nil)
        }
    }
    
    // MARK: - WebSocket LifeCycle
    
    /*
     Send a Ping message to the websocket every 3 minutes. ONLY if the websocket is already opened.
     This will prevent the server to close our websocket.
     */
    dynamic private func ping() {
        switch socketStatus.value {
        case .Open:
            let ping = WebSocketMessageRouter(uuidGenerator: LGUUID()).pingMessage()
            sendQuery(ping, completion: nil)
        default:
            break
        }
    }
    
    func setupTimer() {
        pingTimer = NSTimer.scheduledTimerWithTimeInterval(LGCoreKitConstants.chatPingTimeInterval, target: self,
                                                           selector: #selector(ping), userInfo: nil, repeats: true)
    }
    
    func startWebSocket(endpoint: String, completion: (() -> ())?) {
        
        ws.event.open = { [weak self] in
            self?.socketStatus.value = .Open(authenticated: false)
            self?.openClosure?()
            self?.openClosure = nil
            logMessage(.Debug, type: .WebSockets, message: "Opened")
            self?.setupTimer()
        }
        
        ws.event.close = { [weak self] code, reason, clean in
            logMessage(.Debug, type: .WebSockets, message: "Closed")
            self?.closeClosure?()
            self?.closeClosure = nil

            if let socketStatus = self?.socketStatus.value where socketStatus == .Opening {
                // Close event while opening means websocket is unreachable or connection was refused.
                self?.socketStatus.value = .Closed
                self?.pingTimer?.invalidate()
                return
            }

            switch code {
            case WebSocketClientError.ManuallyClosed, WebSocketClientError.AbnormalClosure:
                self?.socketStatus.value = .Closed
                self?.pingTimer?.invalidate()
            default:
                self?.socketStatus.value = .Opening
                self?.ws.open()
                InternalCore.sessionManager.authenticateWebSocket(nil)
            }
        }
        
        ws.event.error = { error in
            // TODO: Handle websocket errors (network errors)
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Connection Error: \(error)")
        }
        
        ws.event.message = { [weak self] message in
            guard let text = message as? String, let dict = self?.stringToJSON(text) else { return }
            guard let typeString = dict["type"] as? String else { return }
            guard let type = WebSocketResponseType(rawValue: typeString) else { return }
            
            switch type.superType {
            case .ACK:
                logMessage(LogLevel.Debug, type: .WebSockets, message: "Received ACK: \(text)")
                self?.handleACK(dict)
            case .Query:
                logMessage(LogLevel.Debug, type: .WebSockets, message: "Received QueryResponse: \(text)")
                self?.handleQueryResponse(dict)
            case .Event:
                logMessage(LogLevel.Debug, type: .WebSockets, message: "Received Event: \(text)")
                self?.handleEvent(dict)
            case .Error:
                logMessage(LogLevel.Debug, type: .WebSockets, message: "Received Error: \(text)")
                self?.handleError(dict)
            }
        }
        
        openWebSocket(endpoint, completion: completion)
    }
    
    func openWebSocket(endpoint: String, completion: (() -> ())?) {
        switch socketStatus.value {
        case .Open, .Opening:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Chat already connected to: \(endpoint)")
            completion?()
            return
        case .Closed, .Closing:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Trying to connect to: \(endpoint)")
            socketStatus.value = .Opening
            openClosure = completion
            ws.open(endpoint)
        }
    }
    
    func closeWebSocket(completion: (() -> ())?) {
        switch socketStatus.value {
        case .Closed, .Closing:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Chat already closed")
            completion?()
            return
        case .Open, .Opening:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Closing Chat WebSocket")
            socketStatus.value = .Closing
            closeClosure = completion
            ws.close(WebSocketClientError.ManuallyClosed, reason: "Manual close")
        }
    }
    
    func suspendOperations() {
        requestQueue.suspended = true
    }
    
    func resumeOperations() {
        requestQueue.suspended = false
    }
    
    
    // MARK: Send
    
    func sendQuery(request: WebSocketQueryRequestConvertible, completion: (Result<[String: AnyObject], WebSocketError> -> Void)?) {
        activeQueries[request.uuid.lowercaseString] = completion
        send(request)
    }
    
    func sendCommand(request: WebSocketCommandRequestConvertible, completion: (Result<Void, WebSocketError> -> Void)?) {
        if request.type == .Authenticate {
            activeAuthRequests[request.uuid.lowercaseString] = completion
        } else {
            activeCommands[request.uuid.lowercaseString] = completion
        }
        send(request)
    }
    
    func sendEvent(request: WebSocketEventRequestConvertible) {
        send(request)
    }
    
    func send(request: WebSocketRequestConvertible) {
        let sendAction = { [weak self] in
            // Only add the request to the array if its not an Authenticate request, those shouldn't be saved to repeat
            if request.type != .Authenticate { self?.activeRequests[request.uuid.lowercaseString] = request }
            logMessage(LogLevel.Debug, type: .WebSockets, message: "[WS] Send: \(request.message)")
            self?.privateSend(request)
        }
        
        // The authentication request can't enter the queue or they will get blocked
        request.type == .Authenticate ? sendAction() : requestQueue.addOperationWithBlock(sendAction)
    }
    
    func privateSend(request: WebSocketRequestConvertible) {
        ws.send(request.message)
    }
    
    
    // MARK: Response handlers
    
    private func stringToJSON(text: String) -> [String: AnyObject]? {
        guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else { return nil }
        guard let dict = json as? [String: AnyObject] else { return nil }
        return dict
    }
    
    private func handleACK(dict: [String: AnyObject]) {
        guard let ack = WebSocketResponseACK(dict: dict) else { return }
        if ack.ackedType == .Authenticate {
            requestQueue.suspended = false
            socketStatus.value = .Open(authenticated: true)
            activeAuthRequests.values.forEach{ $0(Result<Void, WebSocketError>(value: ()))}
            activeAuthRequests.removeAll()
        } else {
            let completion = activeCommands[ack.ackedId.lowercaseString]
            activeCommands.removeValueForKey(ack.ackedId.lowercaseString)
            activeRequests.removeValueForKey(ack.ackedId.lowercaseString)
            completion?(Result<Void, WebSocketError>(value: ()))
        }
    }
    
    private func handleQueryResponse(dict: [String: AnyObject]) {
        guard let response = WebSocketResponseQuery(dict: dict) else { return }
        let completion = activeQueries[response.responseToId.lowercaseString]
        activeQueries.removeValueForKey(response.responseToId.lowercaseString)
        activeRequests.removeValueForKey(response.responseToId.lowercaseString)
        completion?(Result<[String: AnyObject], WebSocketError>(value: response.data))
    }
    
    private func handleEvent(dict: [String: AnyObject]) {
        guard let response = WebSocketResponseEvent(dict: dict) else { return }
        guard let event = ChatModelsMapper.eventFromDict(dict, type: response.type) else { return }
        switch event.type {
        case .AuthenticationTokenExpired: // -> Don't forward this event to the App
            reauthenticate()
        case .InterlocutorMessageSent, .InterlocutorReadConfirmed, .InterlocutorReceptionConfirmed,
             .InterlocutorTypingStarted, .InterlocutorTypingStopped:
            eventBus.onNext(event)
        }
    }
    
    private func reauthenticate() {
        requestQueue.suspended = true
        socketStatus.value = .Open(authenticated: false)
        InternalCore.sessionManager.renewUserToken(nil)
    }
    
    private func handleError(dict: [String: AnyObject]) {
        guard let error = WebSocketResponseError(dict: dict) else { return }
        
        switch error.errorType {
        case .TokenExpired, .NotAuthenticated:
            reauthenticate()
            if let request = activeRequests[error.erroredId.lowercaseString] {
                send(request)
            }
            return
        case .IsScammer:
            closeWebSocket(nil)
            InternalCore.sessionManager.logout()
        default:
            break
        }
        
        activeRequests.removeValueForKey(error.erroredId.lowercaseString)
        
        if let completion = activeCommands[error.erroredId.lowercaseString] {
            activeCommands.removeValueForKey(error.erroredId.lowercaseString)
            completion(Result<Void, WebSocketError>(error: .Internal))
        }
        
        if let completion = activeQueries[error.erroredId.lowercaseString] {
            activeQueries.removeValueForKey(error.erroredId.lowercaseString)
            completion(Result<[String: AnyObject], WebSocketError>(error: .Internal))
        }
        
        if let completion = activeAuthRequests[error.erroredId.lowercaseString] {
            activeAuthRequests.removeValueForKey(error.erroredId.lowercaseString)
            completion(Result<Void, WebSocketError>(error: .Internal))
        }
    }
}
