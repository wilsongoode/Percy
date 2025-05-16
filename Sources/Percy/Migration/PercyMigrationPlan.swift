//
//  PercyMigrationPlan.swift
//  Percy
//
//  Created by Wilson Goode on 5/16/25.
//

import Foundation
import SwiftData

public protocol PercyMigrationPlan: SchemaMigrationPlan {
    static var direction: MigrationDirection { get }
    static func validateMigrationStages() -> Bool
}

public enum MigrationDirection {
    case forward
    case backward
}
