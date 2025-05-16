//
//  TestMigrationPlan.swift
//  Percy
//
//  Created by Wilson Goode on 5/14/25.
//

import SwiftData
import Percy

enum TestMigrationPlan: ForwardMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            TestSchemaV1.self,
            TestSchemaV2.self,
        ]
    }
    
    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
        ]
    }
    
    static var migrateV1toV2: MigrationStage {
        .lightweight(
            fromVersion: TestSchemaV1.self,
            toVersion: TestSchemaV2.self
        )
    }
}

// Rollback migrations cannot be comingled with forward migrations in a single migration plan
enum TestRollbackMigrationPlan: RollbackMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            TestSchemaV1.self,
            TestSchemaV2.self,
        ]
    }
    
    static var stages: [MigrationStage] {
        [
            rollbackV2toV1,
        ]
    }
    
    // Rollback stages don't work as MigrationStage.lightweight, so they must be .custom, even if simple
    static var rollbackV2toV1: MigrationStage {
        .custom(
            fromVersion: TestSchemaV2.self,
            toVersion: TestSchemaV1.self,
            willMigrate: nil,
            didMigrate: nil
        )
    }
}
