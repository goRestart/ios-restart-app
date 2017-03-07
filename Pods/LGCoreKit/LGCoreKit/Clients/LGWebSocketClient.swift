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
    
    var isOpen: Bool {
        switch self {
        case .open: return true
        case .opening, .closed, .closing: return false
        }
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

/** Letgo WebSocket Client
 ## Features
 - Opens on demand with the first request sent.
 - Asks for a new token if needed.
 - Asks for websocket authentication if needed.
 - Closes on background after a timeout.
 - Opens with delay to prevent back-end saturation (after second try). */
class LGWebSocketClient: NSObject, WebSocketClient, SRWebSocketDelegate {
    
    var websocketPingTimeInterval: TimeInterval = LGCoreKitConstants.websocketPingTimeInterval
    var websocketBackgroundDisconnectTimeout: TimeInterval = LGCoreKitConstants.websocketBackgroundDisconnectTimeout
    var openWebsocketInitialMinTimeInterval: TimeInterval = LGCoreKitConstants.openWebsocketInitialMinTimeInterval
    var openWebsocketInitialMaxTimeInterval: TimeInterval = LGCoreKitConstants.openWebsocketInitialMaxTimeInterval
    var openWebsocketMaximumTimeInterval: TimeInterval = LGCoreKitConstants.openWebsocketMaximumTimeInterval
    var openWebsocketTimeIntervalMultiplier: Double = LGCoreKitConstants.openWebsocketTimeIntervalMultiplier
    var openWebsocketMaximumRetryAttempts: Int = LGCoreKitConstants.openWebsocketMaximumRetryAttempts
    
    var ws: SRWebSocket?
    
    private var openWebSocketRetryAttempts: Int = 0
    private var openWebSocketDelay: TimeInterval = 0
    private var openWebSocketTimer: Timer?
    private var pingTimer: Timer?
    private var backgroundTimeoutTimer: Timer?
    
    /** Completions are stored to be executed once the WS delegate inform us of the ack/error */
    private var pendingCommandCompletions: [String: ((Result<Void, WebSocketError>) -> Void)] = [:]
    private var pendingQueryCompletions: [String: ((Result<[AnyHashable: Any], WebSocketError>) -> Void)] = [:]
    private var pendingAuthCompletions: [String: ((Result<Void, WebSocketError>) -> Void)] = [:]
    
    /** Sent requests to WS are stored here (auth requests are excluded) */
    private var activeRequests: [String: WebSocketRequestConvertible] = [:]
    
    private let reachability: LGReachabilityProtocol
    
    weak var sessionManager: InternalSessionManager?
    
    /** All request except AUTH requests will be queued and executed in order.
     AUTH requests are executed directly and they are not added to this queue */
    let operationQueue = OperationQueue()
    let eventBus = PublishSubject<ChatEvent>()
    var socketStatus = Variable<WebSocketStatus>(.closed)
    
    private let enqueueOperationLock = NSLock()
    
    var endpointURL: URL?
    private var endpoint: String {
        return endpointURL?.absoluteString ?? ""
    }
    
    /** WebSocket client must be enabled to perform any operation (open, send, etc).
     Once enabled, it will open the websocket on demand and authenticate it if needed. */
    private var isEnabled: Bool = false
    
    // MARK: - LifeCycle
    
    required init(reachability: LGReachabilityProtocol) {
        self.reachability = reachability
        super.init()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.isSuspended = true
        self.reachability.reachableBlock = { [weak self] in
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Reachability] Online. \(self?.operationQueue.operationCount ?? 0) operations in queue")
            // Open web socket if we have peding operations, otherwise it will open on demand
            self?.openWebSocketIfPendingOperations()
        }
        self.reachability.unreachableBlock = { [weak self] in
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Reachability] Offline. \(self?.operationQueue.operationCount ?? 0) operations in queue")
            self?.invalidateOpenWebSocketTimer()
        }
    }
    
    deinit {
        stop()
        ws?.delegate = nil
        ws = nil
    }
    
    func applicationDidEnterBackground() {
        guard isEnabled else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Application] applicationDidEnterBackground")
        invalidateOpenWebSocketTimer()
        
        guard socketStatus.value.isOpen else { return }
        
        let aplication = UIApplication.shared
        let identifier = aplication.beginBackgroundTask(withName: "WebSocketTimeout") { [weak self] in
            // code to handle the task running out of time before it is complete
            self?.fireBackgroundTimeout()
        }
        // code to run in background
        scheduleBackgroundTimeoutTimer()
        aplication.endBackgroundTask(identifier)
    }
    
    func applicationWillEnterForeground() {
        guard isEnabled else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Application] applicationWillEnterForeground")
        invalidateBackgroundTimeoutTimer()
    }
    
    // MARK: - Timers
    
    private func scheduleOpenWebSocketTimer(withTimeInterval timeInterval: TimeInterval) {
        setSocketStatus(.opening)
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Timer] OpenWebSocket scheduled (\(timeInterval)s)")
        openWebSocketTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                  target: self,
                                                  selector: #selector(fireOpenWebSocketTimer),
                                                  userInfo: nil,
                                                  repeats: false)
    }
    
    private func invalidateOpenWebSocketTimer() {
        guard let openWebSocketTimer = openWebSocketTimer, openWebSocketTimer.isValid else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Timer] OpenWebSocket invalidated")
        openWebSocketTimer.invalidate()
        setSocketStatus(.closed)
    }
    
    dynamic private func fireOpenWebSocketTimer() {
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Timer] OpenWebSocket fired")
        openWebSocket()
    }
    
    private func schedulePingTimer() {
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Timer] Ping scheduled (\(websocketPingTimeInterval)s)")
        pingTimer = Timer.scheduledTimer(timeInterval: websocketPingTimeInterval,
                                         target: self,
                                         selector: #selector(firePingTimer),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    private func invalidatePingTimer() {
        guard let pingTimer = pingTimer, pingTimer.isValid else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Timer] Ping invalidated")
        pingTimer.invalidate()
    }
    
    dynamic private func firePingTimer() {
        guard socketStatus.value.isOpen else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Timer] Ping fired")
        let ping = WebSocketMessageRouter(uuidGenerator: LGUUID()).pingMessage()
        // ping is not added to the queue, they are being sent as they come
        send(ping)
    }
    
    private func scheduleBackgroundTimeoutTimer() {
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Timer] Background timeout scheduled (\(websocketBackgroundDisconnectTimeout)s)")
        backgroundTimeoutTimer = Timer.scheduledTimer(timeInterval: websocketBackgroundDisconnectTimeout,
                                                      target: self,
                                                      selector: #selector(fireBackgroundTimeout),
                                                      userInfo: nil,
                                                      repeats: false)
    }
    
    private func invalidateBackgroundTimeoutTimer() {
        guard let backgroundTimeoutTimer = backgroundTimeoutTimer, backgroundTimeoutTimer.isValid else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Timer] Background timeout invalidated")
        backgroundTimeoutTimer.invalidate()
    }
    
    dynamic private func fireBackgroundTimeout() {
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Timer] Background timeout fired")
        closeWebSocketIfNeeded()
    }
    
    // MARK: - WebSocket
    
    func start(withEndpoint endpoint: String) {
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "WebSocket enabled with endPoint: \(endpoint)")
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Operation Queue] isSuspended: \(operationQueue.isSuspended)")
        endpointURL = URL(string: endpoint)
        reachability.start()
        isEnabled = true
    }
    
    func stop() {
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "WebSocket disabled")
        reachability.stop()
        invalidateOpenWebSocketTimer()
        invalidatePingTimer()
        invalidateBackgroundTimeoutTimer()
        closeWebSocket()
        
        // in case websocket was already closed
        suspendOperations() // need to suspend before disabling websocket
        cancelOperations()
        cancelAllPendingCompletionsAndActiveRequests(withError: .suspended(withCode: SRStatusCodeNormal.rawValue))
        
        isEnabled = false
    }
    
    private func resetOpenSocketDelayAndAttempts() {
        openWebSocketDelay = 0
        openWebSocketRetryAttempts = 0
    }
    
    private func increaseOpenWebSocketDelayAndRetryAttempts() {
        if openWebSocketDelay == 0 {
            openWebSocketDelay = Double.makeRandom(min: openWebsocketInitialMinTimeInterval,
                                                   max: openWebsocketInitialMaxTimeInterval)
        }
        else if openWebSocketDelay < openWebsocketMaximumTimeInterval {
            openWebSocketDelay = min(openWebSocketDelay * openWebsocketTimeIntervalMultiplier,
                                     openWebsocketMaximumTimeInterval)
        }
        openWebSocketRetryAttempts += 1
    }
    
    private func openWebSocket() {
        setSocketStatus(.opening)
        increaseOpenWebSocketDelayAndRetryAttempts()
        ws?.delegate = nil
        ws?.close()
        ws = SRWebSocket(url: endpointURL)
        ws?.delegate = self
        ws?.open()
    }
    
    private func tryToOpenWebSocket() {
        guard isEnabled else {
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Open] WebSocket client is NOT enabled")
            return
        }
        guard let isReachable = reachability.isReachable, isReachable else {
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Open] WebSocket is not reachable")
            resetOpenSocketDelayAndAttempts()
            return
        }
        guard openWebSocketRetryAttempts < openWebsocketMaximumRetryAttempts else {
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Open] Maximum retry attempts reached: \(openWebsocketMaximumRetryAttempts))")
            resetOpenSocketDelayAndAttempts()
            return
        }
        switch socketStatus.value {
        case .open:
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Open] WS already connected to: \(endpoint)")
        case .opening:
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Open] WS already connecting to: \(endpoint)")
        case .closed, .closing:
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Open] Trying to connect to: \(endpoint), Retry attempts: \(openWebSocketRetryAttempts)")
            if openWebSocketDelay > 0 {
                scheduleOpenWebSocketTimer(withTimeInterval: openWebSocketDelay)
            } else {
                openWebSocket()
            }
        }
    }
    
    private func openWebSocketIfClosed() {
        switch socketStatus.value {
        case .closed, .closing: // TODO: better handle of closing
            tryToOpenWebSocket()
        default:
            break
        }
    }
    
    private func openWebSocketIfPendingOperations() {
        if operationQueue.operationCount > 0 {
            openWebSocketIfClosed()
        }
    }
    
    private func closeWebSocket() {
        switch socketStatus.value {
        case .closed:
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Close] WS already closed")
        case .closing:
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Close] WS already closing")
        case .open, .opening:
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Close] Closing...")
            setSocketStatus(.closing)
            ws?.close(withCode: SRStatusCodeNormal.rawValue, reason: "Manual close")
        }
    }
    
    private func closeWebSocketIfNeeded() {
        switch socketStatus.value {
        case .open, .opening: // TODO: better handle of opening
            closeWebSocket()
        default:
            break
        }
    }
    
    private func webSocketDidClose(withCode code: Int) {
        invalidatePingTimer()
        invalidateBackgroundTimeoutTimer()
        setSocketStatus(.closed)
        // cancel all ongoing operations and pending completions.
        suspendOperations()
        cancelAllPendingCompletionsAndActiveRequests(withError: .suspended(withCode: code))
        
        switch code {
        case SRStatusCodeNormal.rawValue, SRStatusCodeGoingAway.rawValue:
            // closed by us manually ->  WS remains closed
            cancelOperations()
        case SRStatusCodeAbnormal.rawValue: // internet goes off, websocket is down
            // closed by WS library -> open WS if there are pending operations
            openWebSocketIfPendingOperations()
        default:
            cancelOperations()
            tryToOpenWebSocket()
        }
    }
    
    private func setSocketStatus(_ status: WebSocketStatus) {
        if socketStatus.value != status {
            socketStatus.value = status
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Socket Status] \(socketStatus.value.description)")
        }
    }
    
    // MARK: - Operations
    
    private func enqueueOperation(withRequestType requestType: WebSocketRequestType,
                                  operationBlock: @escaping () -> Void) {
        // ensure this method is not executed from different threads at the same time
        enqueueOperationLock.lock()
        defer {
            enqueueOperationLock.unlock()
        }
        
        operationQueue.addOperation(operationBlock)
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Operation Queue] Added: \(requestType), " +
            "count: \(operationQueue.operationCount) operations")
        openWebSocketIfClosed()
        resumeOperationsIfNeeded()
    }
    
    func suspendOperations() {
        guard isEnabled, !operationQueue.isSuspended else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Operation Queue] Suspending \(operationQueue.operationCount) operations")
        operationQueue.isSuspended = true
    }
    
    private func resumeOperationsIfNeeded() {
        // when user is notVerified, the queue is suspended until a new request comes
        if socketStatus.value == .open(authenticated: .notVerified) {
            resumeOperations()
        }
    }
    
    private func resumeOperations() {
        guard operationQueue.isSuspended else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Operation Queue] Resuming \(operationQueue.operationCount) operations")
        operationQueue.isSuspended = false
    }
    
    private func cancelOperations() {
        guard isEnabled, operationQueue.operationCount > 0 else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Operation Queue] Cancelling \(operationQueue.operationCount) operations")
        operationQueue.cancelAllOperations()
        // if the queue is suspended the cancel() method will not go through
        if operationQueue.isSuspended {
            operationQueue.isSuspended = false
            operationQueue.waitUntilAllOperationsAreFinished()
            operationQueue.isSuspended = true
        } else {
            operationQueue.waitUntilAllOperationsAreFinished()
        }
    }
    
    func cancelAllOperations(withError error: WebSocketError) {
        cancelOperations()
        cancelAllPendingCompletionsAndActiveRequests(withError: error)
    }
    
    // MARK: - Requests
    
    private func addPendingCommandCompletion(forRequest request: WebSocketCommandRequestConvertible,
                                             completion: ((Result<Void, WebSocketError>) -> Void)?) {
        guard completion != nil else { return }
        let key = request.uuid.lowercased()
        pendingCommandCompletions[key] = completion
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Command Completion] Added: \(request.type), " +
            "id: \(key), count: \(pendingCommandCompletions.count)")
    }
    
    private func removePendingCommandCompletion(forKey key: String) {
        guard pendingCommandCompletions[key] != nil else { return }
        pendingCommandCompletions.removeValue(forKey: key)
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Command Completion] Removed: \(key), count: \(pendingCommandCompletions.count)")
    }
    
    private func executePendingCommandCompletion(forKey key: String) {
        let keyValue = key.lowercased()
        guard let completion = pendingCommandCompletions[keyValue] else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Command Completion] Executing: \(keyValue)")
        removePendingCommandCompletion(forKey: keyValue)
        completion(Result<Void, WebSocketError>(value: ()))
    }
    
    private func cancelPendingCommandCompletion(forKey key: String, error: WebSocketError) {
        guard let completion = pendingCommandCompletions[key] else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Command Completion] Cancelling: \(key), error: \(error)")
        removePendingCommandCompletion(forKey: key)
        completion(Result<Void, WebSocketError>(error: error))
    }
    
    private func cancelPendingCommandCompletions(withError error: WebSocketError) {
        guard pendingCommandCompletions.count > 0 else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Command Completion] Cancelling \(pendingCommandCompletions.count) " +
            "commands, with error: \(error)")
        pendingCommandCompletions.keys.forEach { (key) in
            cancelPendingCommandCompletion(forKey: key, error: error)
        }
    }
    
    private func addPendingQueryCompletion(forRequest request: WebSocketQueryRequestConvertible,
                                           completion: ((Result<[AnyHashable: Any], WebSocketError>) -> Void)?) {
        guard completion != nil else { return }
        let key = request.uuid.lowercased()
        pendingQueryCompletions[key] = completion
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Query Completion] Added: \(request.type), " +
            "id: \(key), count: \(pendingQueryCompletions.count)")
    }
    
    private func removePendingQueryCompletion(forKey key: String) {
        guard pendingQueryCompletions[key] != nil else { return }
        pendingQueryCompletions.removeValue(forKey: key)
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Query Completion] Removed: \(key), count: \(pendingQueryCompletions.count)")
    }
    
    private func executePendingQueryCompletionCompletion(forKey key: String, responseData: [AnyHashable: Any]) {
        let keyValue = key.lowercased()
        guard let completion = pendingQueryCompletions[keyValue] else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Query Completion] Executing: \(keyValue)")
        removePendingQueryCompletion(forKey: keyValue)
        completion(Result<[AnyHashable: Any], WebSocketError>(value: responseData))
    }
    
    private func cancelPendingQueryCompletion(forKey key: String, error: WebSocketError) {
        guard let completion = pendingQueryCompletions[key] else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Query Completion] Cancelling: \(key), error: \(error)")
        removePendingQueryCompletion(forKey: key)
        completion(Result<[AnyHashable: Any], WebSocketError>(error: error))
    }
    
    private func cancelPendingQueryCompletions(withError error: WebSocketError) {
        guard pendingQueryCompletions.count > 0 else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Query Completion] Cancelling \(pendingQueryCompletions.count) queries, " +
            "with error: \(error)")
        pendingQueryCompletions.keys.forEach { (key) in
            cancelPendingQueryCompletion(forKey: key, error: error)
        }
    }
    
    private func addPendingAuthCompletion(forRequest request: WebSocketCommandRequestConvertible,
                                          completion: ((Result<Void, WebSocketError>) -> Void)?) {
        guard completion != nil else { return }
        let key = request.uuid.lowercased()
        pendingAuthCompletions[key] = completion
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Auth Completion] Added: \(request.type), " +
            "id: \(key), count: \(pendingAuthCompletions.count)")
    }
    
    private func removePendingAuthCompletion(forKey key: String) {
        guard pendingAuthCompletions[key] != nil else { return }
        pendingAuthCompletions.removeValue(forKey: key)
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Auth Completion] Removed: \(key), count: \(pendingAuthCompletions.count)")
    }
    
    private func executePendingAuthCompletion(forKey key: String) {
        let keyValue = key.lowercased()
        guard let completion = pendingAuthCompletions[keyValue] else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Auth Completion] Executing: \(keyValue)")
        removePendingAuthCompletion(forKey: keyValue)
        completion(Result<Void, WebSocketError>(value: ()))
    }
    
    private func executePendingAuthCompletions() {
        pendingAuthCompletions.keys.forEach { (key) in
            executePendingAuthCompletion(forKey: key)
        }
    }
    
    private func cancelPendingAuthCompletionRequest(forKey key: String, error: WebSocketError) {
        guard let completion = pendingAuthCompletions[key] else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Auth Completion] Cancelling: \(key), error: \(error)")
        removePendingAuthCompletion(forKey: key)
        completion(Result<Void, WebSocketError>(error: error))
    }
    
    private func cancelPendingAuthCompletions(withError error: WebSocketError) {
        guard pendingAuthCompletions.count > 0 else { return }
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Pending Auth Completion] Cancelling \(pendingAuthCompletions.count) auths, " +
            "with error: \(error)")
        pendingAuthCompletions.keys.forEach { (key) in
            cancelPendingAuthCompletionRequest(forKey: key, error: error)
        }
    }
    
    private func addActiveRequest(_ request: WebSocketRequestConvertible) {
        let key = request.uuid.lowercased()
        activeRequests[key] = request
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Active Request] Added: \(request.type), id: \(key), count: \(activeRequests.count)")
    }
    
    private func removeActiveRequest(forKey key: String) {
        let keyValue = key.lowercased()
        guard activeRequests[keyValue] != nil else { return }
        activeRequests.removeValue(forKey: keyValue)
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Active Request] Removed: \(keyValue), count: \(activeRequests.count)")
    }
    
    private func cancelPendingCompletionsAndActiveRequests(forKey key: String, withError error: WebSocketError) {
        cancelPendingCommandCompletion(forKey: key, error: error)
        cancelPendingQueryCompletion(forKey: key, error: error)
        cancelPendingAuthCompletionRequest(forKey: key, error: error)
        removeActiveRequest(forKey: key)
    }
    
    private func cancelAllPendingCompletionsAndActiveRequests(withError error: WebSocketError) {
        cancelPendingCommandCompletions(withError: error)
        cancelPendingQueryCompletions(withError: error)
        cancelPendingAuthCompletions(withError: error)
        activeRequests.forEach { (request) in
            removeActiveRequest(forKey: request.key)
        }
    }
    
    private func removePendingCompletionsAndActiveRequests(forKey key: String) {
        removePendingCommandCompletion(forKey: key)
        removePendingQueryCompletion(forKey: key)
        removePendingAuthCompletion(forKey: key)
        removeActiveRequest(forKey: key)
    }
    
    // MARK: - Send
    
    func sendQuery(_ request: WebSocketQueryRequestConvertible,
                   completion: ((Result<[AnyHashable: Any], WebSocketError>) -> Void)?) {
        guard isEnabled else { return }
        addPendingQueryCompletion(forRequest: request, completion: completion)
        enqueueOperation(withRequestType: request.type) {
            self.privateSend(request)
        }
    }
    
    func sendCommand(_ request: WebSocketCommandRequestConvertible,
                     completion: ((Result<Void, WebSocketError>) -> Void)?) {
        guard isEnabled else { return }
        if request.type == .authenticate {
            addPendingAuthCompletion(forRequest: request, completion: completion)
            privateSendAuth(request, completion: completion)
        } else {
            addPendingCommandCompletion(forRequest: request, completion: completion)
            enqueueOperation(withRequestType: request.type) {
                self.privateSend(request)
            }
        }
    }
    
    func sendEvent(_ request: WebSocketEventRequestConvertible) {
        guard isEnabled else { return }
        enqueueOperation(withRequestType: request.type) {
            self.privateSend(request)
        }
    }
    
    private func privateSendAuth(_ request: WebSocketCommandRequestConvertible,
                                 completion: ((Result<Void, WebSocketError>) -> Void)?) {
        if socketStatus.value.isOpen {
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[AUTH] Sending auth...")
            send(request)
        } else {
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[AUTH] Could not send auth: socket is \(socketStatus.value.description)")
        }
    }
    
    private func privateSend(_ request: WebSocketRequestConvertible) {
        switch socketStatus.value {
        case .open(authenticated: .authenticated):
            addActiveRequest(request)
            send(request)
        case .open(authenticated: .notAuthenticated), .open(authenticated: .notVerified):
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Send] Could not send: socket is \(socketStatus.value.description)")
            // enqueue de request again
            enqueueOperation(withRequestType: request.type) {
                self.privateSend(request)
            }
            authenticateWebSocket()
        default:
            logMessage(LogLevel.debug, type: .webSockets,
                       message: "[Send] Could not send: socket is \(socketStatus.value.description)")
            // enqueue de request again
            enqueueOperation(withRequestType: request.type) {
                self.privateSend(request)
            }
        }
    }
    
    func send(_ request: WebSocketRequestConvertible) {
        logMessage(LogLevel.debug, type: .webSockets,
                   message: "[Send] Message: \(request.message)")
        ws?.send(request.message)
    }
    
    // MARK: - Session manager
    
    private func renewUserToken() {
        logMessage(LogLevel.debug, type: .webSockets, message: "[AUTH] Trying to renew user token")
        suspendOperations()
        setSocketStatus(.open(authenticated: .notAuthenticated))
        sessionManager?.renewUserToken(nil)
    }
    
    private func authenticateWebSocket() {
        logMessage(LogLevel.debug, type: .webSockets, message: "[AUTH] Trying to authenticate websocket")
        suspendOperations()
        setSocketStatus(.open(authenticated: .notAuthenticated))
        sessionManager?.authenticateWebSocket()
    }
    
    // MARK: - Response handlers
    
    private func stringToJSON(_ text: String) -> [AnyHashable: Any]? {
        guard let data = text.data(using: .utf8) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        guard let dict = json as? [AnyHashable: Any] else { return nil }
        return dict
    }
    
    private func handleACK(_ dict: [AnyHashable: Any]) {
        guard let ack = WebSocketResponseACK(dict: dict) else {
            logMessage(.debug, type: .webSockets, message: "[Parse] handleACK could not parse dict: \(dict)")
            return
        }
        if ack.ackedType == .authenticate {
            setSocketStatus(.open(authenticated: .authenticated))
            executePendingAuthCompletions()
            resumeOperations()
        } else {
            executePendingCommandCompletion(forKey: ack.ackedId)
        }
        removeActiveRequest(forKey: ack.ackedId)
    }
    
    private func handleQueryResponse(_ dict: [AnyHashable: Any]) {
        guard let response = WebSocketResponseQuery(dict: dict) else {
            logMessage(.debug, type: .webSockets, message: "[Parse] handleQueryResponse could not parse dict: \(dict)")
            return
        }
        executePendingQueryCompletionCompletion(forKey: response.responseToId, responseData: response.data)
        removeActiveRequest(forKey: response.responseToId)
    }
    
    private func handleEvent(_ dict: [AnyHashable: Any]) {
        guard let response = WebSocketResponseEvent(dict: dict),
            let event = ChatModelsMapper.eventFromDict(dict, type: response.type) else {
                logMessage(.debug, type: .webSockets, message: "[Parse] handleEvent could not parse dict: \(dict)")
                return
        }
        switch event.type {
        case .authenticationTokenExpired: // -> Don't forward this event to the App
            renewUserToken()
        case .interlocutorMessageSent, .interlocutorReadConfirmed, .interlocutorReceptionConfirmed,
             .interlocutorTypingStarted, .interlocutorTypingStopped:
            eventBus.onNext(event)
        }
    }
    
    private func handleError(_ dict: [AnyHashable: Any]) {
        guard let error = WebSocketResponseError(dict: dict) else {
            logMessage(.debug, type: .webSockets, message: "[Parse] handleError could not parse dict: \(dict)")
            return
        }
        let key = error.erroredId.lowercased()
        switch error.errorType {
        case .notAuthenticated:
            authenticateWebSocket()
            if let request = activeRequests[key] {
                removeActiveRequest(forKey: key)
                enqueueOperation(withRequestType: request.type) {
                    self.privateSend(request)
                }
            }
        case .tokenExpired:
            renewUserToken()
            if let request = activeRequests[key] {
                removeActiveRequest(forKey: key)
                enqueueOperation(withRequestType: request.type) {
                    self.privateSend(request)
                }
            }
        case .isScammer:
            sessionManager?.tearDownSession(kicked: true)
            cancelOperations()
            cancelAllPendingCompletionsAndActiveRequests(withError: .userBlocked)
            return
        case .userNotVerified:
            setSocketStatus(.open(authenticated: .notVerified))
            cancelOperations()
            cancelAllPendingCompletionsAndActiveRequests(withError: .userNotVerified)
            return
        default:
            cancelOperations()
            cancelAllPendingCompletionsAndActiveRequests(withError: .suspended(withCode: error.errorType.rawValue))
        }
    }
    
    
    // MARK: - SRWebSocketDelegate
    
    @objc func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        logMessage(.debug, type: .webSockets, message: "[WS] didOpen")
        schedulePingTimer()
        authenticateWebSocket()
        resetOpenSocketDelayAndAttempts()
    }
    
    @objc func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        logMessage(.debug, type: .webSockets,
                   message: "[WS] didCloseWithCode: \(code), reason:\(reason), wasClean:\(wasClean))")
        webSocketDidClose(withCode: code)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        guard let text = message as? String,
            let dict = stringToJSON(text),
            let typeString = dict["type"] as? String,
            let type = WebSocketResponseType(rawValue: typeString) else {
                logMessage(.debug, type: .webSockets,
                           message: "[Parse] didReceiveMessage could not parse response: \(message)")
                return
        }
        
        switch type.superType {
        case .ack:
            logMessage(LogLevel.debug, type: .webSockets, message: "[WS] didReceiveMessage ACK: \(dict)")
            handleACK(dict)
        case .query:
            logMessage(LogLevel.debug, type: .webSockets, message: "[WS] didReceiveMessage QueryResponse: \(text)")
            handleQueryResponse(dict)
        case .event:
            logMessage(LogLevel.debug, type: .webSockets, message: "[WS] didReceiveMessage Event: \(dict)")
            handleEvent(dict)
        case .error:
            logMessage(LogLevel.debug, type: .webSockets, message: "[WS] didReceiveMessage Error: \(dict)")
            handleError(dict)
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        logMessage(LogLevel.debug, type: .webSockets, message: "[WS] didFailWithError: \(error)")
        webSocketDidClose(withCode: SRStatusCodeAbnormal.rawValue)
    }
}
