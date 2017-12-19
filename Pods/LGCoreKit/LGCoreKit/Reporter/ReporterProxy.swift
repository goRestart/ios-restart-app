//
//  ReporterProxy.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/03/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public class ReporterProxy: Reporter {
    var reporters: [Reporter] = []

    public func addReporter(_ reporter: Reporter) {
        reporters.append(reporter)
    }

    public func report(_ domain: Domain, code: Int, message: String) {
        reporters.forEach { $0.report(domain, code: code, message: message) }
    }
}

public protocol ReportType {
    var domain: String { get }
    var code: Int { get }
}

public func report(_ reportType: ReportType, message: String) {
    InternalCore.reporter.report(reportType.domain, code: reportType.code, message: message)
}
