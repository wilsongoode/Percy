//
//  ForwardMigrationPlan.swift
//  Percy
//
//  Created by Wilson Goode on 5/16/25.
//

import Foundation
import SwiftData
import OSLog

public protocol ForwardMigrationPlan: PercyMigrationPlan {}

public extension ForwardMigrationPlan {
    static var logger: Logger { Logger(subsystem: Constants.bundleIdentifier, category: "ForwardMigrationPlan") }
    
    static var direction: MigrationDirection { .forward }
    
    static func validateMigrationStages(_ configuration: any PercyConfiguration.Type) -> Bool {
        logger.info("Validating forward migration stages for \(configuration.identifier)")
        guard !stages.isEmpty else {
            logger.notice("No migration stages defined for \(configuration.identifier)")
            return true
        }
        return stages.allSatisfy { stage in
            switch stage {
            case .lightweight(let fromVersion, let toVersion):
                print("Lightweight migration from \(fromVersion) to \(toVersion)")
                return true
            case .custom(let fromVersion, let toVersion, let willMigrate, let didMigrate):
                print("Custom migration from \(fromVersion) to \(toVersion)")
                if configuration.iCloudContainer != nil {
                    logger.warning("iCloud container identifier is set, but custom migrations are not supported for CloudKit databases. Migrations may not be performed.")
                    return false
                }
                return true
            @unknown default:
                fatalError()
            }
        }
    }
}
