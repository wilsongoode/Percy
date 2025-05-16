//
//  RollbackMigrationPlan.swift
//  Percy
//
//  Created by Wilson Goode on 5/16/25.
//

import Foundation
import SwiftData

public protocol RollbackMigrationPlan: PercyMigrationPlan {}

public extension RollbackMigrationPlan {
    static var direction: MigrationDirection { .backward }
    
    static func validateMigrationStages() -> Bool {
        stages.allSatisfy { stage in
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
            
            return true
        }
    }
}
