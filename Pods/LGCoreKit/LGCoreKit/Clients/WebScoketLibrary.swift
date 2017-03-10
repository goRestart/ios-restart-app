//
//  WebScoketLibrary.swift
//  LGCoreKit
//
//  Created by Nestor on 08/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

enum WebSocketStatusCode: Int {
    // 0–999: Reserved and not used.
    case normal = 1000
    case goingAway = 1001
    case protocolError = 1002
    case unhandledType = 1003
    // 1004 reserved.
    case statusReceived = 1005
    case abnormal = 1006
    case invalidUTF8 = 1007
    case policyViolated = 1008
    case messageTooBig = 1009
    case missingExtension = 1010
    case internalError = 1011
    case serviceRestart = 1012
    case tryAgainLater = 1013
    // 1014: Reserved for future use by the WebSocket standard.
    case TLSHandshake = 1015
    // 1016–1999: Reserved for future use by the WebSocket standard.
    // 2000–2999: Reserved for use by WebSocket extensions.
    // 3000–3999: Available for use by libraries and frameworks. May not be used by applications. Available for registration at the IANA via first-come, first-serve.
    // 4000–4999: Available for use by applications.
}

protocol WebSocketLibraryProtocol: class {
    weak var delegate: WebSocketLibraryDelegate? { get set }
    
    func open(withEndpointURL endpointURL: URL)
    func close()
    func close(withCode code: Int, reason: String)
    func send(data: Any)
}

protocol WebSocketLibraryDelegate: class {
    func webSocketDidOpen()
    func webSocketDidClose(withCode code: Int, reason: String, wasClean: Bool)
    func webSocketDidReceive(message: Any)
    func webSocketDidFail(withError error: Error)
}
