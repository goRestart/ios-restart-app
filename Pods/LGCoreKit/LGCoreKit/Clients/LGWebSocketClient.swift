//
//  LGWebSocketClient.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import SwiftWebSocket


class LGWebSocketClient: WebSocketClient {
    
    private let ws = WebSocket()
    private var authenticated: Bool = false
    private var activeCommands: [String: (Result<Void, WebSocketError> -> Void)] = [:]
    private var activeQueries: [String: (Result<[String: AnyObject], WebSocketError> -> Void)] = [:]
    
    private var openClosure: (() -> ())?
    private var closeClosure: (() -> ())?
    
    // MARK: - WebSocket LifeCycle
    
    func startWebSocket(endpoint: String, completion: (() -> ())?) {
        openClosure = completion
    
        ws.event.open = { [weak self] in
            self?.openClosure?()
            self?.openClosure = nil
            print("opened")
        }
        
        ws.event.close = { [weak self] code, reason, clean in
            print("close")
            self?.closeClosure?()
            self?.closeClosure = nil
            if code != 0 {
                self?.ws.open() //try to reconnect only if it wasn't manually closed
            }
        }
        
        ws.event.error = { error in
            // TODO: Handle websocket errors (network errors)
            print("error \(error)")
        }
        
        ws.event.message = { [weak self] message in
            guard let text = message as? String, let dict = self?.stringToJSON(text) else { return }
            guard let typeString = dict["type"] as? String else { return }
            guard let type = WebSocketResponseType(rawValue: typeString) else { return }
            
            switch type.superType {
            case .ACK:
                self?.handleACK(dict)
            case .Query:
                self?.handleQueryResponse(dict)
            case .Event:
                self?.handleEvent(dict)
            case .Error:
                self?.handleError(dict)
            }
            
            print("recv: \(text)")
        }
        
        ws.open(endpoint) // Open Connection
    }
    
    func closeWebSocket(completion: (() -> ())?) {
        closeClosure = completion
        ws.close(0, reason: "Manual close")
    }
    

    // MARK: - Send
    
    func sendQuery(request: WebSocketQueryRequestConvertible, completion: (Result<[String: AnyObject], WebSocketError> -> Void)?) {
        guard authenticated else {
            completion?(Result<[String: AnyObject], WebSocketError>(error: .NotAuthenticated))
            return
        }
        activeQueries[request.uuid] = completion
        ws.send(request.message)
    }
    
    func sendCommand(request: WebSocketCommandRequestConvertible, completion: (Result<Void, WebSocketError> -> Void)?) {
        guard authenticated else {
            completion?(Result<Void, WebSocketError>(error: .NotAuthenticated))
            return
        }
        activeCommands[request.uuid] = completion
        ws.send(request.message)
    }
    
    func sendEvent(request: WebSocketEventRequestConvertible) {
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
        let completion = activeCommands[ack.ackedId]
        completion?(Result<Void, WebSocketError>(value: ()))
        activeCommands.removeValueForKey(ack.ackedId)
        if ack.ackedType == .Authenticate {
            self.authenticated = true
        }
    }
    
    private func handleQueryResponse(dict: [String: AnyObject]) {
        guard let response = WebSocketResponseQuery(dict: dict) else { return }
        let completion = activeQueries[response.responseToId]
        completion?(Result<[String: AnyObject], WebSocketError>(value: response.data))
        activeQueries.removeValueForKey(response.responseToId)
    }
    
    private func handleEvent(dict: [String: AnyObject]) {
        guard let _ = WebSocketResponseEvent(dict: dict) else { return }
        // TODO: Send Event via Rx Bus
    }
    
    private func handleError(dict: [String: AnyObject]) {
        guard let error = WebSocketResponseError(dict: dict) else { return }
        // TODO: Generate WebSocketErrors
        
        if let completion = activeCommands[error.erroredId] {
            completion(Result<Void, WebSocketError>(error: .Internal))
            activeCommands.removeValueForKey(error.erroredId)
        }
        
        if let completion = activeQueries[error.erroredId] {
            completion(Result<[String: AnyObject], WebSocketError>(error: .Internal))
            activeQueries.removeValueForKey(error.erroredId)
        }
    }
}
