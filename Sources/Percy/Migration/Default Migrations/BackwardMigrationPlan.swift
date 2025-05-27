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
        var seenToVersions: [any VersionedSchema.Type] = []
        var seenFromVersions: [any VersionedSchema.Type] = []
        var previousToVersion: (any VersionedSchema.Type)?
        
//        logger.info("Migrations: \(stages)")
        guard stages == stages.sorted(by: >) else {
            logger.error("Backward migration stages must be sorted in descending order")
            return false
        }
        
        return stages.allSatisfy { stage in
            guard case .custom(let fromVersion, let toVersion, _, _) = stage else {
                logger.error("All stages must be custom for backward migrations")
                return false
            }
            
            logger.debug("Validating backward migration from \(fromVersion.versionString()) to \(toVersion.versionString())")
            
            return validateMigrationStep(
                fromVersion: fromVersion,
                toVersion: toVersion,
                seenFromVersions: &seenFromVersions,
                seenToVersions: &seenToVersions,
                previousToVersion: &previousToVersion
            )
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
        
        // Ensure backward progression
        if fromVersion.versionIdentifier <= toVersion.versionIdentifier {
            logger.error("Invalid version order for backward migration: toVersion \(toVersion.versionString()) should be less than fromVersion \(fromVersion.versionString())")
            return false
        }
        
        seenFromVersions.append(fromVersion)
        seenToVersions.append(toVersion)
        previousToVersion = toVersion
        return true
    }
}
