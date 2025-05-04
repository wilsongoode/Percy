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
    
    /// The app's name.
    static var name: String { get }
    
    /// The app's schema.
    static var schema: Schema { get }
    
    /// The app's schema migration plan.
    static var migrationPlan: SchemaMigrationPlan.Type { get }
}
