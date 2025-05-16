//
//  TestSchemaV2.swift
//  Percy
//
//  Created by Wilson Goode on 5/15/25.
//


import Foundation
import SwiftData

enum TestSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }
    static var models: [any PersistentModel.Type] {
        [
            TestSchemaV2.Person.self,
            TestSchemaV2.Group.self,
        ]
    }
}

extension TestSchemaV2 {
    @Model
    final class Person {
        var name: String
        var dateOfBirth: Date?
        
        @Relationship var partner: Person?
        
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
