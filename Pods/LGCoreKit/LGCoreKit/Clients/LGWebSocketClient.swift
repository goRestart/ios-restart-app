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

    var authenticated: Bool {
        switch self {
        case .closed, .opening, .closing:
            return false
        case let .open(authenticated):
            return authenticated == .authenticated
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
    
    let requestQueue = OperationQueue()
    let eventBus = PublishSubject<ChatEvent>()
    var socketStatus = Variable<WebSocketStatus>(.closed)
    var endpointURL: URL?
    
    override init() {
        super.init()
        requestQueue.maxConcurrentOperationCount = 1
    }
    
    deinit {
        pingTimer?.invalidate()
    }

    // MARK: - WebSocket LifeCycle
    
    /*
     Send a Ping message to the websocket every 3 minutes. ONLY if the websocket is already opened.
     This will prevent the server to close our websocket.
     */
    dynamic private func ping() {
        switch socketStatus.value {
        case .open:
            let ping = WebSocketMessageRouter(uuidGenerator: LGUUID()).pingMessage()
            sendQuery(ping, completion: nil)
        default:
            break
        }
    }
    
    func setupTimer() {
        pingTimer = Timer.scheduledTimer(timeInterval: LGCoreKitConstants.chatPingTimeInterval, target: self,
                                                           selector: #selector(ping), userInfo: nil, repeats: true)
    }
    
    private func reconnectWebSocket(with endpointURL: URL?) {
        ws?.delegate = nil
        ws?.close()
        ws = SRWebSocket(url: endpointURL)
        ws?.delegate = self
        ws?.open()
    }
    
    func openWebSocket(_ endpoint: String) {
        switch socketStatus.value {
        case .open:
            logMessage(LogLevel.debug, type: .webSockets, message: "Chat already connected to: \(endpoint)")
        case .opening:
            logMessage(LogLevel.debug, type: .webSockets, message: "Chat ALREADY connecting to: \(endpoint)")
        case .closed, .closing:
            logMessage(LogLevel.debug, type: .webSockets, message: "Trying to connect to: \(endpoint)")
            socketStatus.value = .opening
            endpointURL = URL(string: endpoint)
            reconnectWebSocket(with: endpointURL)
        }
    }
    
    func closeWebSocket() {
        switch socketStatus.value {
        case .closed:
            logMessage(LogLevel.debug, type: .webSockets, message: "Chat already closed")
        case .closing:
            logMessage(LogLevel.debug, type: .webSockets, message: "Chat ALREADY closing")
        case .open, .opening:
            logMessage(LogLevel.debug, type: .webSockets, message: "Closing Chat WebSocket")
            socketStatus.value = .closing
            ws?.close(withCode: SRStatusCodeNormal.rawValue, reason: "Manual close")
        }
    }
    
    func webSocketDidClose(with errorCode: Int) {
        if socketStatus.value == .opening {
            // Close event while opening means websocket is unreachable or connection was refused.
            socketStatus.value = .closed
            pingTimer?.invalidate()
            return
        }
        
        switch errorCode {
        case SRStatusCodeAbnormal.rawValue, SRStatusCodeNormal.rawValue:
            socketStatus.value = .closed
            pingTimer?.invalidate()
            requestQueue.cancelAllOperations()
            finishActiveRequests(withCode: errorCode)
        default:
            socketStatus.value = .opening
            // Finish active requests and pause requestQueue until socket becomes open(.authenticated)
            suspendOperations()
            reconnectWebSocket(with: endpointURL)
        }
    }
    
    func suspendOperations() {
        requestQueue.isSuspended = true
        finishActiveRequests(withCode: SRStatusCodeGoingAway.rawValue)
    }
    
    func resumeOperations() {
        requestQueue.isSuspended = false
    }
    
    func finishActiveRequests(withCode errorCode: Int) {
        activeRequests.forEach { (request) in
            let requestId = request.value.uuid.lowercased()
            if let completion = activeCommands[requestId] {
                completion(Result<Void, WebSocketError>(error: .suspended(withCode: errorCode)))
            }
            else if let completion = activeQueries[requestId] {
                completion(Result<[AnyHashable: Any], WebSocketError>(error: .suspended(withCode: errorCode)))
            } else if let completion = activeAuthRequests[requestId] {
                completion(Result<Void, WebSocketError>(error: .suspended(withCode: errorCode)))
            }
        }
        activeRequests.removeAll()
        activeCommands.removeAll()
        activeQueries.removeAll()
        activeAuthRequests.removeAll()
    }

    
    // MARK: Send
    
    func sendQuery(_ request: WebSocketQueryRequestConvertible, completion: ((Result<[AnyHashable: Any], WebSocketError>) -> Void)?) {
        activeQueries[request.uuid.lowercased()] = completion
        send(request)
    }
    
    func sendCommand(_ request: WebSocketCommandRequestConvertible, completion: ((Result<Void, WebSocketError>) -> Void)?) {
        if request.type == .authenticate {
            activeAuthRequests[request.uuid.lowercased()] = completion
        } else {
            activeCommands[request.uuid.lowercased()] = completion
        }
        send(request)
    }
    
    func sendEvent(_ request: WebSocketEventRequestConvertible) {
        send(request)
    }
    
    func send(_ request: WebSocketRequestConvertible) {
        
        let sendAction = { [weak self] in
            // Only add the request to the array if its not an Authenticate request, those shouldn't be saved to repeat
            if request.type != .authenticate {
                self?.activeRequests[request.uuid.lowercased()] = request
            }
            self?.privateSend(request)
        }
        
        // The authentication request can't enter the queue or they will get blocked
        request.type == .authenticate ? sendAction() : requestQueue.addOperation(sendAction)
    }
    
    func privateSend(_ request: WebSocketRequestConvertible) {
        logMessage(LogLevel.debug, type: .webSockets, message: "[WS] Send: \(request.message)")
        switch socketStatus.value {
        case .open:
            ws?.send(request.message)
        default:
            break
        }
    }
    
    
    // MARK: Response handlers
    
    private func stringToJSON(_ text: String) -> [AnyHashable: Any]? {
        guard let data = text.data(using: .utf8) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        guard let dict = json as? [AnyHashable: Any] else { return nil }
        return dict
    }
    
    private func handleACK(_ dict: [AnyHashable: Any]) {
        guard let ack = WebSocketResponseACK(dict: dict) else { return }
        if ack.ackedType == .authenticate {
            resumeOperations()
            socketStatus.value = .open(authenticated: .authenticated)
            activeAuthRequests.values.forEach{ $0(Result<Void, WebSocketError>(value: ()))}
            activeAuthRequests.removeAll()
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
                send(request)
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
        logMessage(.debug, type: .webSockets, message: "Opened")
        socketStatus.value = .open(authenticated: .notAuthenticated)
        openCompletion?()
        setupTimer()
    }
    
    @objc func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        logMessage(.debug, type: .webSockets, message: "Closed")
        closeCompletion?()
        webSocketDidClose(with: code)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        guard let text = message as? String, let dict = stringToJSON(text) else { return }
        guard let typeString = dict["type"] as? String else { return }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return }
        
        switch type.superType {
        case .ack:
            logMessage(LogLevel.debug, type: .webSockets, message: "Received ACK: \(text)")
            handleACK(dict)
        case .query:
            logMessage(LogLevel.debug, type: .webSockets, message: "Received QueryResponse: \(text)")
            handleQueryResponse(dict)
        case .event:
            logMessage(LogLevel.debug, type: .webSockets, message: "Received Event: \(text)")
            handleEvent(dict)
        case .error:
            logMessage(LogLevel.debug, type: .webSockets, message: "Received Error: \(text)")
            handleError(dict)
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        logMessage(LogLevel.debug, type: .webSockets, message: "Connection Error: \(error)")
        let code = (error as NSError).code
        webSocketDidClose(with: code)
    }
}
