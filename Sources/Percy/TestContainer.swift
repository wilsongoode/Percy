//
//  TestContainer.swift
//  Percy
//
//  Created by Wilson Goode on 5/4/25.
//

import SwiftData

public extension Percy {
    static func createTestContainer(
        for schema: Schema
    ) throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
