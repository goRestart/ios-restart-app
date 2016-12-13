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
    case NotAuthenticated // will try to reauthenticate
    case NotVerified // will NOT try to reauthenticate until the user tries to manually verify
    case Authenticated
}

enum WebSocketStatus: Equatable {
    case Closed
    case Open(authenticated: WSAuthenticationStatus)
    case Opening
    case Closing

    var authenticated: Bool {
        switch self {
        case .Closed, .Opening, .Closing:
            return false
        case let .Open(authenticated):
            return authenticated == .Authenticated
        }
    }
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

class LGWebSocketClient: NSObject, WebSocketClient, SRWebSocketDelegate {
    
    var ws: SRWebSocket?
    
    private var activeCommands: [String: (Result<Void, WebSocketError> -> Void)] = [:]
    private var activeQueries: [String: (Result<[String: AnyObject], WebSocketError> -> Void)] = [:]
    private var activeRequests: [String: WebSocketRequestConvertible] = [:]
    private var activeAuthRequests: [String: (Result<Void, WebSocketError> -> Void)] = [:]

    var openCompletion: (() -> ())?
    var closeCompletion: (() -> ())?
    private var pingTimer: NSTimer?

    weak var sessionManager: InternalSessionManager?
    
    let requestQueue = NSOperationQueue()
    let eventBus = PublishSubject<ChatEvent>()
    var socketStatus = Variable<WebSocketStatus>(.Closed)
    var endpointURL: NSURL?
    
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
    
    private func reconnectWebSocket(with endpointURL: NSURL?) {
        ws?.delegate = nil
        ws?.close()
        ws = SRWebSocket(URL: endpointURL)
        ws?.delegate = self
        ws?.open()
    }
    
    func startWebSocket(endpoint: String) {
        switch socketStatus.value {
        case .Open:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Chat already connected to: \(endpoint)")
        case .Opening:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Chat ALREADY connecting to: \(endpoint)")
        case .Closed, .Closing:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Trying to connect to: \(endpoint)")
            socketStatus.value = .Opening
            endpointURL = NSURL(string: endpoint)
            reconnectWebSocket(with: endpointURL)
        }
    }
    
    func closeWebSocket() {
        switch socketStatus.value {
        case .Closed:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Chat already closed")
        case .Closing:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Chat ALREADY closing")
        case .Open, .Opening:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Closing Chat WebSocket")
            socketStatus.value = .Closing
            ws?.closeWithCode(SRStatusCodeNormal.rawValue, reason: "Manual close")
        }
    }
    
    func suspendOperations() {
        requestQueue.suspended = true
    }

    private func resumeOperations() {
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
        ws?.send(request.message)
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
            resumeOperations()
            socketStatus.value = .Open(authenticated: .Authenticated)
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
        suspendOperations()
        socketStatus.value = .Open(authenticated: .NotAuthenticated)
        sessionManager?.renewUserToken(nil)
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
            closeWebSocket()
            sessionManager?.logout()
        case .UserNotVerified:
            socketStatus.value = .Open(authenticated: .NotVerified)
        default:
            break
        }
        
        activeRequests.removeValueForKey(error.erroredId.lowercaseString)
        
        if let completion = activeCommands[error.erroredId.lowercaseString] {
            activeCommands.removeValueForKey(error.erroredId.lowercaseString)
            completion(Result<Void, WebSocketError>(error: WebSocketError(wsErrorType: error.errorType)))
        }
        
        if let completion = activeQueries[error.erroredId.lowercaseString] {
            activeQueries.removeValueForKey(error.erroredId.lowercaseString)
            completion(Result<[String: AnyObject], WebSocketError>(error: WebSocketError(wsErrorType: error.errorType)))
        }
        
        if let completion = activeAuthRequests[error.erroredId.lowercaseString] {
            activeAuthRequests.removeValueForKey(error.erroredId.lowercaseString)
            completion(Result<Void, WebSocketError>(error: WebSocketError(wsErrorType: error.errorType)))
        }
    }
    
    // MARK: - SRWebSocketDelegate
    
    @objc func webSocketDidOpen(webSocket: SRWebSocket!) {
        socketStatus.value = .Open(authenticated: .NotAuthenticated)
        openCompletion?()
        logMessage(.Debug, type: .WebSockets, message: "Opened")
        setupTimer()
    }
    
    @objc func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        logMessage(.Debug, type: .WebSockets, message: "Closed")
        closeCompletion?()

        if socketStatus.value == .Opening {
            // Close event while opening means websocket is unreachable or connection was refused.
            socketStatus.value = .Closed
            pingTimer?.invalidate()
            return
        }
        
        switch code {
        case SRStatusCodeAbnormal.rawValue, SRStatusCodeNormal.rawValue:
            socketStatus.value = .Closed
            pingTimer?.invalidate()
        default:
            socketStatus.value = .Opening
            reconnectWebSocket(with: endpointURL)
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        guard let text = message as? String, let dict = stringToJSON(text) else { return }
        guard let typeString = dict["type"] as? String else { return }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return }
        
        switch type.superType {
        case .ACK:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Received ACK: \(text)")
            handleACK(dict)
        case .Query:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Received QueryResponse: \(text)")
            handleQueryResponse(dict)
        case .Event:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Received Event: \(text)")
            handleEvent(dict)
        case .Error:
            logMessage(LogLevel.Debug, type: .WebSockets, message: "Received Error: \(text)")
            handleError(dict)
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        // TODO: Handle websocket errors (network errors)
        logMessage(LogLevel.Debug, type: .WebSockets, message: "Connection Error: \(error)")
    }
}
