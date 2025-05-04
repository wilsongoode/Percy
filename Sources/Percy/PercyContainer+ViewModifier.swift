import SwiftUI
import SwiftData

public extension View {
    /// Adds Percy persistence to a view hierarchy.
    /// 
    /// Use this modifier to setup Percy and inject the model container:
    /// ```swift
    /// @main
    /// struct YourApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .withPercy(configuration: AppStorage.self)
    ///         }
    ///     }
    /// }
    /// ```
    func withPercy<Config: PercyConfiguration>(
        configuration: Config.Type,
        storeURL: URL? = nil
    ) -> some View {
        modifier(PercyViewModifier(configuration: configuration, storeURL: storeURL))
    }
}

private struct PercyViewModifier: ViewModifier {
    @State private var percy: Percy.Container
    
    init<Config: PercyConfiguration>(configuration: Config.Type, storeURL: URL? = nil) {
        _percy = State(wrappedValue: Percy.Container(configuration: configuration, storeURL: storeURL))
    }
    
    private var activeContainer: ModelContainer {
        if let container = percy.container {
            return container
        }
        // Fallback to a new container if percy.container is nil
        guard let container = try? ModelContainer(for: percy.configuration.schema) else {
            fatalError("Failed to create fallback container")
        }
        return container
    }
    
    func body(content: Content) -> some View {
        content
            .task {
                try? await percy.setup()
            }
            .modelContainer(activeContainer)
    }
}
