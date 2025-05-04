//
//  Analytics.swift
//  Percy
//
//  Created by Wilson Goode on 5/4/25.
//

import OSLog

actor Analytics {
    private let logger: Logger
    private var metrics: [String: Any] = [:]
    
    init(identifier: String) {
        self.logger = Logger(subsystem: identifier, category: "Percy.Analytics")
    }
    
    func trackOperation(_ operation: String) {
        logger.debug("Performing operation: \(operation)")
    }
    
    func recordMetric(_ name: String, value: Any) {
        metrics[name] = value
        logger.debug("Recorded metric \(name): \(String(describing: value))")
    }
}
