//
//  PercyConfiguration.swift
//  Percy
//
//  Created by Wilson Goode on 5/4/25.
//

import SwiftData

/// A protocol that defines your app's storage settings.
public protocol PercyConfiguration {
    /// The app's identifier.
    static var identifier: String { get }
    
    /// The app's iCloud container identifier.
    static var iCloudContainer: String? { get }
    
    /// The app's name.
    static var name: String { get }
    
    /// The app's versioned schema.
    static var versionedSchema: any VersionedSchema.Type { get }
    
    /// The app's schema migration plan.
    static var migrationPlan: any PercyMigrationPlan.Type { get }
}

public extension PercyConfiguration {
    static var schema: Schema {
        Schema(versionedSchema: versionedSchema)
    }
    
    static func validate() throws {
        guard migrationPlan.validateMigrationStages() else {
            throw PercyError.invalidMigrationPlan
        }
    }
}
