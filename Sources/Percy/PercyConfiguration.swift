//
//  PercyConfiguration.swift
//  Percy
//
//  Created by Wilson Goode on 5/4/25.
//

import SwiftData

public protocol PercyConfiguration {
    static var identifier: String { get }
    static var name: String { get }
    static var schema: Schema { get }
    static var migrationPlan: SchemaMigrationPlan.Type { get }
}
