# Percy

Percy is a library that makes setting up a SwiftData container more convenient while covering common use cases and boilerplate.

## Setup

Add Percy as a dependency in your `Package.swift`:
```swift
.package(url: "https://github.com/wilsongoode/Percy", from: "0.3.0"),
```
Or go to Xcode menu File -> Add Package Dependencies and search for "https://github.com/wilsongoode/Percy".

In your app's main entry point, import Percy:
```swift
import Percy
```

1. Create a configuration type that conforms to `PercyConfiguration`, for example:
```swift
struct AppStorage: PercyConfiguration {
    static var identifier: String { "com.yourapp.id" }
    static var iCloudContainer: String? { "iCloud.com.yourapp.id" }
    static var name: String { "YourApp" }
    static var versionedSchema: any VersionedSchema.Type { AppVersionedSchema.self }
    static var migrationPlan: any PercyMigrationPlan.Type { AppMigrationPlan.self }
}
```

2. To initialize Percy in your app's main entry point, use the `withPercy(configuration:)` view modifier:
```swift
@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withPercy(configuration: AppStorage.self)
        }
    }
}
```

Percy will take the configuration you provide and try to initialize a SwiftData ModelContainer for you. The provided versionedSchema should be a schema that is also in your provided migrationPlan. If Percy's validation fails, the container will not be initialized. If you provide an iCloudContainer identifier, Percy will attempt to validate your schemas and migration plans for compatibility with CloudKit. This can help to avoid common issues with CloudKit and SwiftData.

## Migration Plans

Percy provides default migration plan protocols, but you can create your own by implementing the `PercyMigrationPlan` protocol. This is just a protocol that conforms to SwiftData's `SchemaMigrationPlan` with a few extras, such as a `MigrationDirection` and a validation function.

### Default Migration Plan Protocols

The `ForwardMigrationPlan` protocol is used to define a migration plan to a newer schema version.
The `BackwardMigrationPlan` protocol is used to define a migration plan to an older schema version.

To create a migration plan, create an enum that conforms to either `ForwardMigrationPlan` or `BackwardMigrationPlan`, for example:
```swift
import SwiftData
import Percy

enum YourAppForwardMigrationPlan: ForwardMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            YourSchemaV1.self,
            YourSchemaV2.self,
            YourSchemaV3.self,
        ]
    }
    
    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
            migrateV2toV3,
        ]
    }
    
    static var migrateV1toV2: MigrationStage {
        .lightweight(
            fromVersion: YourSchemaV1.self,
            toVersion: YourSchemaV2.self
        )
    }
    
    static var migrateV2toV3: MigrationStage {
        .lightweight(
            fromVersion: YourSchemaV2.self,
            toVersion: YourSchemaV3.self
        )
    }
}

// Backward migrations cannot be comingled with forward migrations in a single migration plan
enum YourAppBackwardMigrationPlan: BackwardMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            YourSchemaV1.self,
            YourSchemaV2.self,
            YourSchemaV3.self,
        ]
    }
    
    static var stages: [MigrationStage] {
        [
            rollbackV3toV2,
            rollbackV2toV1,
        ]
    }
    
    // Backward migration stages don't work as MigrationStage.lightweight, so they must be .custom, even if simple
    static var rollbackV2toV1: MigrationStage {
        .custom(
            fromVersion: YourSchemaV2.self,
            toVersion: YourSchemaV1.self,
            willMigrate: nil,
            didMigrate: nil
        )
    }
    
    static var rollbackV3toV2: MigrationStage {
        .custom(
            fromVersion: YourSchemaV3.self,
            toVersion: YourSchemaV2.self,
            willMigrate: nil,
            didMigrate: nil
        )
    }
}
```

## Validation

Percy will automatically attempt to validate your migration plans and schema before initializing the container.
Percy tries to help you avoid common issues with CloudKit and SwiftData, and will warn you when it finds something that may be a problem.

### Validating Forward Migrations

- All migration stages go from a lower schema version to a higher schema version.
- Migration stages are listed in ascending order.
- `MigrationStage.custom` stages are only allowed when an iCloud container is not configured. CloudKit only supports `lightweight` migration stages.

### Validating Backward Migrations

- All migration stages go from a higher schema version to a lower schema version.
- Migration stages are listed in descending order.
- All stages must be `MigrationStage.custom` stages for a backward migration. Even if there is nothing special happening in the stage, you must still use `MigrationStage.custom`.

### Validating Schemas for CloudKit

- No unique constraints are allowed.
- All properties have a default value or are optional.
- All relationships are optional.
- "Deny" delete rules are not allowed.
