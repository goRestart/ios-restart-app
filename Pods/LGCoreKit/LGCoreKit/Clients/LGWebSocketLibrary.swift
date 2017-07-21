//
//  LGWebSocketLibrary.swift
//  LGCoreKit
//
//  Created by Nestor on 08/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import SocketRocket

class LGWebSocketLibrary: NSObject, WebSocketLibraryProtocol, SRWebSocketDelegate {
    private var ws: SRWebSocket?
    private let userAgentBuilder: UserAgentBuilder
    
    
    // MARK: - WebSocketLibraryProtocol
    
    weak var delegate: WebSocketLibraryDelegate?
    
    override convenience init() {
        self.init(userAgentBuilder: LGUserAgentBuilder())
    }
    
    init(userAgentBuilder: UserAgentBuilder) {
        self.userAgentBuilder = userAgentBuilder
        super.init()
    }
    
    deinit {
        ws?.delegate = nil
        ws?.close()
        ws = nil
    }
    
    func open(withEndpointURL endpointURL: URL) {
        ws?.delegate = nil
        ws?.close()
        var urlRequest = URLRequest(url: endpointURL)
        urlRequest.setValue(userAgentBuilder.make(appBundle: Bundle.main, networkLibrary: .socketRocket),
                            forHTTPHeaderField: "User-Agent")
        ws = SRWebSocket(urlRequest: urlRequest)
        ws?.delegate = self
        ws?.open()
    }
    
    func close() {
        ws?.close()
    }
    
    func close(withCode code: Int, reason: String) {
        ws?.close(withCode: code, reason: reason)
    }
    
    func send(data: Any) {
        ws?.send(data)
    }
    
    // MARK: - SRWebSocketDelegate
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        delegate?.webSocketDidReceive(message: message)
    }
    
    @objc func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        delegate?.webSocketDidOpen()
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        delegate?.webSocketDidFail(withError: error)
    }
    
    @objc func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        let reasonInfo = reason ?? "emptyReason"
        delegate?.webSocketDidClose(withCode: code, reason: reasonInfo, wasClean: wasClean)
    }
}

