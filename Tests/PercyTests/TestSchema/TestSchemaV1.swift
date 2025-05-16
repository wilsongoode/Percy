//
//  TestSchemaV1.swift
//  Percy
//
//  Created by Wilson Goode on 5/14/25.
//

import Foundation
import SwiftData

enum TestSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }
    static var models: [any PersistentModel.Type] {
        [
            TestSchemaV1.Person.self,
            TestSchemaV1.Group.self,
        ]
    }
}

extension TestSchemaV1 {
    @Model
    final class Person {
        var name: String
        var dateOfBirth: Date?
        
        @Relationship var groups: [Group]?
        
        init(name: String, dateOfBirth: Date? = nil) {
            self.name = name
            self.dateOfBirth = dateOfBirth
        }
    }
    
    @Model
    final class Group {
        var name: String
        
        @Relationship(inverse: \Person.groups) var people: [Person]?
        
        init(name: String) {
            self.name = name
        }
    }
}
