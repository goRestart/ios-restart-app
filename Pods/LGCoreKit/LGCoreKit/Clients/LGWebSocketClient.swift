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

enum WebSocketStatus {
    case Closed
    case Open
    case Opening
    case Closing
}

class LGWebSocketClient: WebSocketClient {
    
    let ws = WebSocket()
    private var authenticated: Bool = false
    private var activeCommands: [String: (Result<Void, WebSocketError> -> Void)] = [:]
    private var activeQueries: [String: (Result<[String: AnyObject], WebSocketError> -> Void)] = [:]
    let eventBus = PublishSubject<ChatEvent>()
    
    var openClosure: (() -> ())?
    var closeClosure: (() -> ())?
    var socketStatus: WebSocketStatus = .Closed
    
    
    // MARK: - WebSocket LifeCycle
    
    func startWebSocket(endpoint: String, completion: (() -> ())?) {
    
        ws.event.open = { [weak self] in
            self?.socketStatus = .Open
            self?.openClosure?()
            self?.openClosure = nil
            logMessage(.Debug, type: .WebSockets, message: "Opened")
        }
        
        ws.event.close = { [weak self] code, reason, clean in
            logMessage(.Debug, type: .WebSockets, message: "Closed")
            self?.closeClosure?()
            self?.closeClosure = nil
            if code != 1000 && self?.socketStatus != .Opening {
                self?.socketStatus = .Opening
                self?.ws.open()
                InternalCore.sessionManager.authenticateWebSocket(nil)
                //try to reconnect only if it wasn't manually closed
//                Core.sessionManager.authenticateWebSocket(nil)
            } else {
                self?.socketStatus = .Closed
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
        logMessage(LogLevel.Debug, type: .WebSockets, message: "Trying to connect to: \(endpoint)")
        socketStatus = .Opening
        openClosure = completion
        ws.open(endpoint)
    }
    
    func closeWebSocket(completion: (() -> ())?) {
        socketStatus = .Closing
        closeClosure = completion
        ws.close(1000, reason: "Manual close")
    }
    

    // MARK: - Send
    
    func sendQuery(request: WebSocketQueryRequestConvertible, completion: (Result<[String: AnyObject], WebSocketError> -> Void)?) {
        guard authenticated else {
            completion?(Result<[String: AnyObject], WebSocketError>(error: .NotAuthenticated))
            return
        }
        
        activeQueries[request.uuid.lowercaseString] = completion
        send(request)
    }
    
    func sendCommand(request: WebSocketCommandRequestConvertible, completion: (Result<Void, WebSocketError> -> Void)?) {
        guard authenticated || request.type == .Authenticate else {
            completion?(Result<Void, WebSocketError>(error: .NotAuthenticated))
            return
        }
        
        activeCommands[request.uuid.lowercaseString] = completion
        send(request)
    }
    
    func sendEvent(request: WebSocketEventRequestConvertible) {
        send(request)
    }
    
    
    func send(request: WebSocketRequestConvertible) {
        logMessage(LogLevel.Debug, type: .WebSockets, message: "[WS] Send: \(request.message)")
        ws.send(request.message)
    }
    
    
    // MARK: - Handle Response Helpers
    
    private func stringToJSON(text: String) -> [String: AnyObject]? {
        guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else { return nil }
        guard let dict = json as? [String: AnyObject] else { return nil }
        return dict
    }
    
    private func handleACK(dict: [String: AnyObject]) {
        guard let ack = WebSocketResponseACK(dict: dict) else { return }
        if ack.ackedType == .Authenticate {
            self.authenticated = true
        }
        let completion = activeCommands[ack.ackedId.lowercaseString]
        activeCommands.removeValueForKey(ack.ackedId.lowercaseString)
        completion?(Result<Void, WebSocketError>(value: ()))
    }
    
    private func handleQueryResponse(dict: [String: AnyObject]) {
        guard let response = WebSocketResponseQuery(dict: dict) else { return }
        let completion = activeQueries[response.responseToId.lowercaseString]
        activeQueries.removeValueForKey(response.responseToId.lowercaseString)
        completion?(Result<[String: AnyObject], WebSocketError>(value: response.data))
    }
    
    private func handleEvent(dict: [String: AnyObject]) {
        guard let response = WebSocketResponseEvent(dict: dict) else { return }
        guard let event = ChatModelsMapper.eventFromDict(dict, type: response.type) else { return }
        eventBus.onNext(event)
    }
    
    private func handleError(dict: [String: AnyObject]) {
        guard let error = WebSocketResponseError(dict: dict) else { return }
        // TODO: Generate WebSocketErrors
        
        if let completion = activeCommands[error.erroredId.lowercaseString] {
            activeCommands.removeValueForKey(error.erroredId.lowercaseString)
            completion(Result<Void, WebSocketError>(error: .Internal))
        }
        
        if let completion = activeQueries[error.erroredId.lowercaseString] {
            activeQueries.removeValueForKey(error.erroredId.lowercaseString)
            completion(Result<[String: AnyObject], WebSocketError>(error: .Internal))
        }
    }
}
