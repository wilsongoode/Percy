//
//  PercyMigrationPlan.swift
//  Percy
//
//  Created by Wilson Goode on 5/16/25.
//

import Foundation
import SwiftData
import OSLog

public protocol PercyMigrationPlan: SchemaMigrationPlan {
    static var direction: MigrationDirection { get }
    static func validateMigrationStages(_ configuration: any PercyConfiguration.Type) -> Bool
    static func validateSchemas(_ configuration: any PercyConfiguration.Type) -> Bool
}

public enum MigrationDirection {
    case forward
    case backward
}

public extension PercyMigrationPlan {
    static var logger: Logger {
        Logger(subsystem: Constants.bundleIdentifier, category: "PercyMigrationPlan")
    }
    static func validateSchemas(_ configuration: any PercyConfiguration.Type) -> Bool {
        logger.info("Validating schemas for \(configuration.identifier)")
        
        guard schemas.contains(where: { $0 == configuration.versionedSchema }) else {
            logger.error("Versioned schema \(configuration.versionedSchema.versionString()) not found in migration plan")
            return false
        }
        
        var failureCount = 0
        configuration.migrationPlan.schemas.forEach { schema in
            logger.debug("Validating \(schema.versionString())")
            
            guard configuration.iCloudContainer != nil else {
                logger.debug("Skipping schema validation for \(schema.versionString()) as iCloudContainer is nil")
                return
            }
            
            guard schema.validateForCloudKit(logger) else {
                logger.error("CloudKit Schema validation failed for \(schema.versionString())")
                failureCount += 1
                return
            }
            
            logger.debug("Schema validation passed for \(schema.versionString())")
        }
        
        if failureCount > 0 {
            logger.error("Schema validation failed for \(configuration.identifier)")
            return false
        }
        
        logger.info("Schema validation passed for \(configuration.identifier)")
        return true
    }
}
