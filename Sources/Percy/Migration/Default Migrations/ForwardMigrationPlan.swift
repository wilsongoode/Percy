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
        
        // Track versions to detect duplicates and validate order
        var seenVersions: [any VersionedSchema.Type] = []
        var previousToVersion: (any VersionedSchema.Type)?
        return stages.allSatisfy { stage in
            switch stage {
            case .lightweight(let fromVersion, let toVersion):
                logger.debug("Validating lightweight migration from \(fromVersion.versionString()) to \(toVersion.versionString())")
                
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
                
                // Ensure forward progression
                if fromVersion.versionIdentifier >= toVersion.versionIdentifier {
                    logger.error("Invalid version order: fromVersion \(fromVersion.versionString()) should be less than toVersion \(toVersion.versionString())")
                    return false
                }
                
                seenVersions.append(fromVersion)
                seenVersions.append(toVersion)
                previousToVersion = toVersion
                return true
                
            case .custom(let fromVersion, let toVersion, _, _):
                logger.debug("Validating custom migration from \(fromVersion.versionString()) to \(toVersion.versionString())")
                
                // Check iCloud compatibility
                if configuration.iCloudContainer != nil {
                    logger.warning("iCloud container identifier is set, but custom migrations are not supported for CloudKit databases. Migrations may not be performed.")
                    return false
                }
                
                // Validate version order
                if let previousVersion = previousToVersion, previousVersion != fromVersion {
                    logger.error("Invalid migration chain: previous version \(previousVersion.versionString()) doesn't match current fromVersion \(fromVersion)")
                    return false
                }
                
                // Check for duplicate versions
                if seenVersions.contains(where: { $0 == fromVersion }) || seenVersions.contains(where: { $0 == toVersion }) {
                    logger.error("Duplicate version detected in migration chain: from \(fromVersion.versionString()) to \(toVersion.versionString())")
                    return false
                }
                
                // Ensure forward progression
                if fromVersion.versionIdentifier >= toVersion.versionIdentifier {
                    logger.error("Invalid version order: fromVersion \(fromVersion.versionString()) should be less than toVersion \(toVersion.versionString())")
                    return false
                }
                
                seenVersions.append(fromVersion)
                seenVersions.append(toVersion)
                previousToVersion = toVersion
                return true
                
            @unknown default:
                logger.fault("Unknown migration stage type encountered")
                return false
            }
        }
    }
}
