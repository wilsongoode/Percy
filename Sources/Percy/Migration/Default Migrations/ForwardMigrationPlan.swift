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
        
        var seenFromVersions: [any VersionedSchema.Type] = []
        var seenToVersions: [any VersionedSchema.Type] = []
        var previousToVersion: (any VersionedSchema.Type)?
        
        guard stages == stages.sorted(by: <) else {
            logger.error("Forward migration stages must be sorted in ascending order")
            return false
        }
        
        return stages.allSatisfy { stage in
            switch stage {
            case .lightweight(let fromVersion, let toVersion):
                logger.debug("Validating lightweight migration from \(fromVersion.versionString()) to \(toVersion.versionString())")
                return validateMigrationStep(
                    fromVersion: fromVersion,
                    toVersion: toVersion,
                    seenFromVersions: &seenFromVersions,
                    seenToVersions: &seenToVersions,
                    previousToVersion: &previousToVersion
                )
                
            case .custom(let fromVersion, let toVersion, _, _):
                logger.debug("Validating custom migration from \(fromVersion.versionString()) to \(toVersion.versionString())")
                
                // Check iCloud compatibility first
                if configuration.iCloudContainer != nil {
                    logger.warning("iCloud container identifier is set, but custom migrations are not supported for CloudKit databases. Migrations may not be performed.")
                    return false
                }
                
                return validateMigrationStep(
                    fromVersion: fromVersion,
                    toVersion: toVersion,
                    seenFromVersions: &seenFromVersions,
                    seenToVersions: &seenToVersions,
                    previousToVersion: &previousToVersion
                )
                
            @unknown default:
                logger.fault("Unknown migration stage type encountered")
                return false
            }
        }
    }
    
    private static func validateMigrationStep(
        fromVersion: any VersionedSchema.Type,
        toVersion: any VersionedSchema.Type,
        seenFromVersions: inout [any VersionedSchema.Type],
        seenToVersions: inout [any VersionedSchema.Type],
        previousToVersion: inout (any VersionedSchema.Type)?
    ) -> Bool {
        // Validate version order
        if let previousVersion = previousToVersion, previousVersion != fromVersion {
            logger.error("Invalid migration chain: previous version \(previousVersion.versionString()) doesn't match current fromVersion \(fromVersion.versionString())")
            return false
        }
        
        // Check for duplicate versions in their respective roles
        if seenFromVersions.contains(where: { $0 == fromVersion }) {
            logger.error("Duplicate fromVersion detected in migration chain: \(fromVersion.versionString())")
            return false
        }
        if seenToVersions.contains(where: { $0 == toVersion }) {
            logger.error("Duplicate toVersion detected in migration chain: \(toVersion.versionString())")
            return false
        }
        
        // Ensure forward progression
        if fromVersion.versionIdentifier >= toVersion.versionIdentifier {
            logger.error("Invalid version order: fromVersion \(fromVersion.versionString()) should be less than toVersion \(toVersion.versionString())")
            return false
        }
        
        seenFromVersions.append(fromVersion)
        seenToVersions.append(toVersion)
        previousToVersion = toVersion
        return true
    }
}
