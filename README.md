# Percy

Percy is a library that makes setting up a SwiftData container more convenient while covering common use cases and boilerplate.

## Setup

Add Percy as a dependency in your `Package.swift`:
```swift
.package(url: "https://github.com/wilsongoode/Percy", branch: "main"),
```

In your app's main entry point, import Percy:
```swift
import Percy
```

1. Create a configuration type that conforms to ``PercyConfiguration``:
```swift
struct AppStorage: PercyConfiguration {
    static let identifier = "com.yourapp.id"
    static let iCloudContainer = "iCloud.com.yourapp.id"
    static let name = "YourApp"
    static let versionedSchema = AppVersionedSchema.self
    static let migrationPlan = AppMigrationPlan.self
}
```

2. To initialize Percy in your app's main entry point, use the ``withPercy(configuration:)`` view modifier:
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
