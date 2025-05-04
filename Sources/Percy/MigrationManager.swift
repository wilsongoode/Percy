//
//  MigrationManager.swift
//  Percy
//
//  Created by Wilson Goode on 5/4/25.
//


actor MigrationManager {
    private let logger: Logger
    
    init(identifier: String) {
        self.logger = Logger(subsystem: identifier, category: "Percy.Migration")
    }
    
    func migrate<T: SchemaMigrationPlan>(
        from oldSchema: Schema,
        to newSchema: Schema,
        using plan: T.Type
    ) async throws {
        logger.info("Starting migration from v\(oldSchema.version) to v\(newSchema.version)")
    }
}
