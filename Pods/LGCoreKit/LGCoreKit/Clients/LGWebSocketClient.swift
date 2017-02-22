//
//  LGWebSocketClient.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import SocketRocket
import RxSwift

enum WSAuthenticationStatus: Equatable {
    case notAuthenticated // will try to reauthenticate
    case notVerified // will NOT try to reauthenticate until the user tries to manually verify
    case authenticated
}

enum WebSocketStatus: Equatable {
    case closed
    case open(authenticated: WSAuthenticationStatus)
    case opening
    case closing

    var isAuthenticated: Bool {
        return self == .open(authenticated: .authenticated)
    }
    
    var description: String {
        switch self {
        case .closed: return "closed"
        case .open(let status):
            switch status {
            case .authenticated: return "open(.authenticated)"
            case .notAuthenticated: return "open(.notAuthenticated)"
            case .notVerified: return "open(.notVerified)"
            }
        case .opening: return "opening"
        case .closing: return "closing"
        }
    }
}

func ==(a: WebSocketStatus, b: WebSocketStatus) -> Bool {
    switch (a, b) {
    case (.open(let a), .open(let b)) where a == b: return true
    case (.closed, .closed): return true
    case (.opening, .opening): return true
    case (.closing, .closing): return true
    default: return false
    }
}

class LGWebSocketClient: NSObject, WebSocketClient, SRWebSocketDelegate {
    
    var ws: SRWebSocket?
    
    private var activeCommands: [AnyHashable: ((Result<Void, WebSocketError>) -> Void)] = [:]
    private var activeQueries: [AnyHashable: ((Result<[AnyHashable: Any], WebSocketError>) -> Void)] = [:]
    private var activeRequests: [AnyHashable: WebSocketRequestConvertible] = [:]
    private var activeAuthRequests: [AnyHashable: ((Result<Void, WebSocketError>) -> Void)] = [:]

    var openCompletion: (() -> ())?
    var closeCompletion: (() -> ())?
    private var pingTimer: Timer?

    weak var sessionManager: InternalSessionManager?
    
    /** All request except AUTH requests will be queued and executed in order. 
     AUTH requests are executed directly and they are not added to this queue */
    let operationQueue = OperationQueue()
    let eventBus = PublishSubject<ChatEvent>()
    var socketStatus = Variable<WebSocketStatus>(.closed)
    private var endpointURL: URL?
    
    var endpoint: String {
        return endpointURL?.absoluteString ?? ""
    }
    
    // MARK: - WebSocket LifeCycle
    
    required init(withEndpoint endpoint: String) {
        super.init()
        endpointURL = URL(string: endpoint)
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.isSuspended = true
    }
    
    deinit {
        invalidatePingTimer()
        operationQueue.cancelAllOperations()
        ws?.close()
        ws = nil
    }
    
    
    // MARK: - Ping
    
    dynamic private func ping() {
        switch socketStatus.value {
        case .open:
            let ping = WebSocketMessageRouter(uuidGenerator: LGUUID()).pingMessage()
            sendQuery(ping, completion: nil)
        default:
            break
        }
    }
    
    private func schedulePingTimer() {
        logMessage(LogLevel.debug, type: .webSockets, message: "[Ping Timer] scheduled (\(LGCoreKitConstants.websocketPingTimeInterval))s")
        pingTimer = Timer.scheduledTimer(timeInterval: LGCoreKitConstants.websocketPingTimeInterval,
                                         target: self,
                                         selector: #selector(ping),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    private func invalidatePingTimer() {
        logMessage(LogLevel.debug, type: .webSockets, message: "[Ping Timer] invalidated")
        pingTimer?.invalidate()
    }
    
    // MARK: - WebSocket
    
    private func reconnectWebSocket() {
        ws?.delegate = nil
        ws?.close()
        ws = SRWebSocket(url: endpointURL)
        ws?.delegate = self
        ws?.open()
    }
    
    func openWebSocket() {
        switch socketStatus.value {
        case .open:
            logMessage(LogLevel.debug, type: .webSockets, message: "[Opening WebSocket] Chat already connected to: \(endpoint)")
        case .opening:
            logMessage(LogLevel.debug, type: .webSockets, message: "[Opening WebSocket] Chat already connecting to: \(endpoint)")
        case .closed, .closing:
            logMessage(LogLevel.debug, type: .webSockets, message: "[Opening WebSocket] Trying to connect to: \(endpoint)")
            socketStatus.value = .opening
            reconnectWebSocket()
        }
    }
    
    func closeWebSocket() {
        switch socketStatus.value {
        case .closed:
            logMessage(LogLevel.debug, type: .webSockets, message: "[Closing WebSocket] Chat already closed")
        case .closing:
            logMessage(LogLevel.debug, type: .webSockets, message: "[Closing WebSocket] Chat already closing")
        case .open, .opening:
            logMessage(LogLevel.debug, type: .webSockets, message: "[Closing WebSocket] Closing chat WebSocket")
            socketStatus.value = .closing
            ws?.close(withCode: SRStatusCodeNormal.rawValue, reason: "Manual close")
        }
    }
    
    private func webSocketDidClose(withCode code: Int) {
        closeCompletion?()
        logMessage(LogLevel.debug, type: .webSockets, message: "WebSocket closed with code: \(code)")
        invalidatePingTimer()
        switch code {
            // closed by us manually
        case SRStatusCodeNormal.rawValue, SRStatusCodeGoingAway.rawValue:
            socketStatus.value = .closed
            cancelOperations(withCode: code)
            // closed by the ws library
        case SRStatusCodeAbnormal.rawValue:
            socketStatus.value = .closed
            suspendOperations(withCode: code)
            // for any other reason, we perform a temporarily suspend operations and try to reconnect
        default:
            socketStatus.value = .opening
            suspendOperations(withCode: code)
            reconnectWebSocket()
        }
    }
    
    // MARK: - Operations
    
    private func enqueueOperation(withRequestType requestType: WebSocketRequestType, operationBlock: @escaping () -> Void) {
        operationQueue.addOperation(operationBlock)
        logMessage(LogLevel.debug, type: .webSockets, message: "[Operation Queue] Added: \(requestType), \(operationQueue.operationCount) operations")
    }
    
    /** Finish active requests and pause operationQueue until socket becomes open(.authenticated) */
    private func suspendOperations(withCode code: Int) {
        logMessage(LogLevel.debug, type: .webSockets, message: "[Operation Queue] Suspending \(operationQueue.operationCount) operations, with code: (\(code))")
        operationQueue.isSuspended = true
        cancelActiveRequests(withCode: code)
    }
    
    func suspendOperations() {
        suspendOperations(withCode: SRStatusCodeNormal.rawValue)
    }
    
    func resumeOperations() {
        logMessage(LogLevel.debug, type: .webSockets, message: "[Operation Queue] Resuming \(operationQueue.operationCount) operations")
        operationQueue.isSuspended = false
    }
    
    func cancelOperations() {
        cancelOperations(withCode: SRStatusCodeNormal.rawValue)
    }
    
    /** Cancel active requests and cancel all operations in operationQueue */
    func cancelOperations(withCode code: Int) {
        logMessage(LogLevel.debug, type: .webSockets, message: "[Operation Queue] Cancelling \(operationQueue.operationCount) operations")
        operationQueue.cancelAllOperations()
        operationQueue.isSuspended = true
        cancelActiveRequests(withCode: code)
    }
    
    
    // MARK: - Requests
    
    private func cancelActiveRequests(withCode code: Int) {
        logMessage(LogLevel.debug, type: .webSockets, message: "[Active Requests] Cancelling \(activeRequests.count) requests")
        activeRequests.forEach { (request) in
            let requestId = request.value.uuid.lowercased()
            if let completion = activeCommands[requestId] {
                completion(Result<Void, WebSocketError>(error: .suspended(withCode: code)))
            }
            else if let completion = activeQueries[requestId] {
                completion(Result<[AnyHashable: Any], WebSocketError>(error: .suspended(withCode: code)))
            } else if let completion = activeAuthRequests[requestId] {
                completion(Result<Void, WebSocketError>(error: .suspended(withCode: code)))
            }
        }
        activeRequests.removeAll()
        activeCommands.removeAll()
        activeQueries.removeAll()
        activeAuthRequests.removeAll()
    }

    
    // MARK: - Send
    
    func sendQuery(_ request: WebSocketQueryRequestConvertible, completion: ((Result<[AnyHashable: Any], WebSocketError>) -> Void)?) {
        activeQueries[request.uuid.lowercased()] = completion
        enqueueOperation(withRequestType: request.type) {
            self.privateSend(request)
        }
    }
    
    func sendCommand(_ request: WebSocketCommandRequestConvertible, completion: ((Result<Void, WebSocketError>) -> Void)?) {
        if request.type == .authenticate {
            activeAuthRequests[request.uuid.lowercased()] = completion
            privateAuth(request, completion: completion)
        } else {
            activeCommands[request.uuid.lowercased()] = completion
            enqueueOperation(withRequestType: request.type) {
                self.privateSend(request)
            }
        }
    }
    
    func sendEvent(_ request: WebSocketEventRequestConvertible) {
        enqueueOperation(withRequestType: request.type) {
            self.privateSend(request)
        }
    }
    
    func privateAuth(_ request: WebSocketCommandRequestConvertible, completion: ((Result<Void, WebSocketError>) -> Void)?) {
        switch socketStatus.value {
        case .open(let status):
            if status == .authenticated {
                logMessage(LogLevel.debug, type: .webSockets, message: "[Send] AUTH Error: socket is \(socketStatus.value.description)")
            } else {
                logMessage(LogLevel.debug, type: .webSockets, message: "[Send] AUTH: \(request.message)")
                ws?.send(request.message)
            }
        default:
            logMessage(LogLevel.debug, type: .webSockets, message: "[Send] AUTH Error: socket is \(socketStatus.value.description)")
        }
        
    }
    
    func privateSend(_ request: WebSocketRequestConvertible) {
        switch socketStatus.value {
        case .open(let status):
            if status == .authenticated {
                logMessage(LogLevel.debug, type: .webSockets, message: "[Send] Message: \(request.message)")
                activeRequests[request.uuid.lowercased()] = request
                ws?.send(request.message)
            } else {
                logMessage(LogLevel.debug, type: .webSockets, message: "[Send] Error: socket is \(socketStatus.value.description)")
                // enqueue de request again
                enqueueOperation(withRequestType: request.type) {
                    self.privateSend(request)
                }
            }
        default:
            logMessage(LogLevel.debug, type: .webSockets, message: "[Send] Error: socket is \(socketStatus.value.description)")
            // enqueue de request again
            enqueueOperation(withRequestType: request.type) {
                self.privateSend(request)
            }
        }
    }
    
    
    // MARK: - Response handlers
    
    private func stringToJSON(_ text: String) -> [AnyHashable: Any]? {
        guard let data = text.data(using: .utf8) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        guard let dict = json as? [AnyHashable: Any] else { return nil }
        return dict
    }
    
    private func handleACK(_ dict: [AnyHashable: Any]) {
        guard let ack = WebSocketResponseACK(dict: dict) else { return }
        if ack.ackedType == .authenticate {
            socketStatus.value = .open(authenticated: .authenticated)
            activeAuthRequests.values.forEach{ $0(Result<Void, WebSocketError>(value: ()))}
            activeAuthRequests.removeAll()
            resumeOperations()
        } else {
            let completion = activeCommands[ack.ackedId.lowercased()]
            activeCommands.removeValue(forKey: ack.ackedId.lowercased())
            activeRequests.removeValue(forKey: ack.ackedId.lowercased())
            completion?(Result<Void, WebSocketError>(value: ()))
        }
    }
    
    private func handleQueryResponse(_ dict: [AnyHashable: Any]) {
        guard let response = WebSocketResponseQuery(dict: dict) else { return }
        let completion = activeQueries[response.responseToId.lowercased()]
        activeQueries.removeValue(forKey: response.responseToId.lowercased())
        activeRequests.removeValue(forKey: response.responseToId.lowercased())
        completion?(Result<[AnyHashable: Any], WebSocketError>(value: response.data))
    }
    
    private func handleEvent(_ dict: [AnyHashable: Any]) {
        guard let response = WebSocketResponseEvent(dict: dict) else { return }
        guard let event = ChatModelsMapper.eventFromDict(dict, type: response.type) else { return }
        switch event.type {
        case .authenticationTokenExpired: // -> Don't forward this event to the App
            reauthenticate()
        case .interlocutorMessageSent, .interlocutorReadConfirmed, .interlocutorReceptionConfirmed,
             .interlocutorTypingStarted, .interlocutorTypingStopped:
            eventBus.onNext(event)
        }
    }

    private func reauthenticate() {
        suspendOperations()
        if socketStatus.value != .open(authenticated: .notAuthenticated) {
            socketStatus.value = .open(authenticated: .notAuthenticated)
        }
        sessionManager?.renewUserToken(nil)
    }
    
    private func handleError(_ dict: [AnyHashable: Any]) {
        guard let error = WebSocketResponseError(dict: dict) else { return }

        switch error.errorType {
        case .tokenExpired, .notAuthenticated:
            reauthenticate()
            if let request = activeRequests[error.erroredId.lowercased()] {
                privateSend(request)
            }
            return
        case .isScammer:
            sessionManager?.tearDownSession(kicked: true)
        case .userNotVerified:
            socketStatus.value = .open(authenticated: .notVerified)
        default:
            break
        }
        
        let errorID = error.erroredId.lowercased()
        activeRequests.removeValue(forKey: errorID)
        
        if let completion = activeCommands[errorID] {
            activeCommands.removeValue(forKey: errorID)
            completion(Result<Void, WebSocketError>(error: WebSocketError(wsErrorType: error.errorType)))
        } else if let completion = activeQueries[errorID] {
            activeQueries.removeValue(forKey: errorID)
            completion(Result<[AnyHashable: Any], WebSocketError>(error: WebSocketError(wsErrorType: error.errorType)))
        } else if let completion = activeAuthRequests[errorID] {
            activeAuthRequests.removeValue(forKey: errorID)
            completion(Result<Void, WebSocketError>(error: WebSocketError(wsErrorType: error.errorType)))
        }
    }
    
    
    // MARK: - SRWebSocketDelegate
    
    @objc func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        logMessage(.debug, type: .webSockets, message: "[WS] Opened")
        socketStatus.value = .open(authenticated: .notAuthenticated)
        openCompletion?()
        schedulePingTimer()
    }
    
    @objc func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        logMessage(.debug, type: .webSockets, message: "[WS] Closed (code:\(code), reason:\(reason), wasClean:\(wasClean))")
        webSocketDidClose(withCode: code)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        guard let text = message as? String, let dict = stringToJSON(text) else { return }
        guard let typeString = dict["type"] as? String else { return }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return }
        
        switch type.superType {
        case .ack:
            logMessage(LogLevel.debug, type: .webSockets, message: "[WS] Received ACK: \(dict)")
            handleACK(dict)
        case .query:
            logMessage(LogLevel.debug, type: .webSockets, message: "[WS] Received QueryResponse: \(text)")
            handleQueryResponse(dict)
        case .event:
            logMessage(LogLevel.debug, type: .webSockets, message: "[WS] Received Event: \(dict)")
            handleEvent(dict)
        case .error:
            logMessage(LogLevel.debug, type: .webSockets, message: "[WS] Received Error: \(dict)")
            handleError(dict)
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        logMessage(LogLevel.debug, type: .webSockets, message: "[WS] Failed with error: \(error)")
        webSocketDidClose(withCode: SRStatusCodeAbnormal.rawValue)
    }
}
