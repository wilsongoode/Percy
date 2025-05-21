//
//  RollbackMigrationPlan.swift
//  Percy
//
//  Created by Wilson Goode on 5/16/25.
//

import Foundation
import SwiftData
import OSLog

public protocol RollbackMigrationPlan: PercyMigrationPlan {}

public extension RollbackMigrationPlan {
    static var logger: Logger { Logger(subsystem: Constants.bundleIdentifier, category: "RollbackMigrationPlan") }
    
    static var direction: MigrationDirection { .backward }
    
    static func validateMigrationStages(_ configuration: any PercyConfiguration.Type) -> Bool {
        logger.info("Validating rollback migration stages for \(configuration.identifier)")
        return stages.allSatisfy { stage in
            guard case .custom(let from, let to, _, _) = stage else {
                assertionFailure("All stages must be custom for rollback migrations")
                return false
            }
            
            guard let fromIndex = schemas.firstIndex(where: { $0 == from }),
                  let toIndex = schemas.firstIndex(where: { $0 == to }),
                  fromIndex > toIndex else {
                assertionFailure("Rollback migration must go from a later version to an earlier version")
                return false
            }
            print("Rollback custom migration from \(from) to \(to)")
            
            return true
        }
    }
}
