//
//  ForwardMigrationPlan.swift
//  Percy
//
//  Created by Wilson Goode on 5/16/25.
//

import Foundation
import SwiftData

public protocol ForwardMigrationPlan: PercyMigrationPlan {}

public extension ForwardMigrationPlan {
    static var direction: MigrationDirection { .forward }
    
    static func validateMigrationStages() -> Bool {
        stages.allSatisfy { stage in
            switch stage {
            case .lightweight(let fromVersion, let toVersion):
                print("Lightweight migration from \(fromVersion) to \(toVersion)")
                return true
            case .custom(let fromVersion, let toVersion, let willMigrate, let didMigrate):
                print("Custom migration from \(fromVersion) to \(toVersion)")
                return true
            @unknown default:
                fatalError()
            }
//            guard case .custom(let from, let to, _, _) = stage else {
//                assertionFailure("All stages must be custom for forward migrations")
//                return false
//            }
//            
//            guard let fromIndex = schemas.firstIndex(where: { $0 == from }),
//                  let toIndex = schemas.firstIndex(where: { $0 == to }),
//                  fromIndex < toIndex else {
//                assertionFailure("Forward migration must go from an earlier version to a later version")
//                return false
//            }
            
//            return true
        }
    }
}
