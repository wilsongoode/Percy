//
//  BackwardMigrationPlan.swift
//  Percy
//
//  Created by Wilson Goode on 5/16/25.
//

import Foundation
import SwiftData
import OSLog

public protocol BackwardMigrationPlan: PercyMigrationPlan {}

public extension BackwardMigrationPlan {
    static var logger: Logger { Logger(subsystem: Constants.bundleIdentifier, category: "BackwardMigrationPlan") }
    
    static var direction: MigrationDirection { .backward }
    
    static func validateMigrationStages(_ configuration: any PercyConfiguration.Type) -> Bool {
        logger.info("Validating backward migration stages for \(configuration.identifier)")
        
        guard !stages.isEmpty else {
            logger.notice("No backward migration stages defined for \(configuration.identifier)")
            return true
        }
        
        // Track versions to detect duplicates and validate order
        var seenVersions: [any VersionedSchema.Type] = []
        var previousToVersion: (any VersionedSchema.Type)?
        
        return stages.allSatisfy { stage in
            guard case .custom(let fromVersion, let toVersion, _, _) = stage else {
                logger.error("All stages must be custom for backward migrations")
                return false
            }
            
            logger.debug("Validating backward migration from \(fromVersion.versionString()) to \(toVersion.versionString())")
            
            // Validate version order
            if let previousVersion = previousToVersion, previousVersion != fromVersion {
                logger.error("Invalid migration chain: previous version \(previousVersion.versionString()) doesn't match current fromVersion \(fromVersion.versionString())")
                return false
            }
            
            // Check for duplicate versions
            if seenVersions.contains(where: { $0 == fromVersion }) || seenVersions.contains(where: { $0 == toVersion }) {
                logger.error("Duplicate version detected in migration chain: from \(fromVersion.versionString()) to \(toVersion.versionString())")
                return false
            }
            
            // Ensure backward progression using array indices
            guard let fromIndex = schemas.firstIndex(where: { $0 == fromVersion }),
                  let toIndex = schemas.firstIndex(where: { $0 == toVersion }),
                  fromIndex > toIndex else {
                logger.error("Backward migration must go from a later version to an earlier version")
                return false
            }
            
            seenVersions.append(fromVersion)
            seenVersions.append(toVersion)
            previousToVersion = toVersion
            return true
        }
    }
}
