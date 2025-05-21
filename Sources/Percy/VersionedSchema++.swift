//
//  VersionedSchema++.swift
//  Percy
//
//  Created by Wilson Goode on 5/21/25.
//

import SwiftData

extension VersionedSchema {
    static func versionString() -> String {
        "\(self) v\(versionIdentifier.major).\(versionIdentifier.minor).\(versionIdentifier.patch)"
    }
}
