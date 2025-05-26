//
//  PercyError.swift
//  Percy
//
//  Created by Wilson Goode on 5/4/25.
//

import Foundation

public enum PercyError: LocalizedError, Equatable {
    case setupFailed(String)
    case backupFailed(String)
    case restoreFailed(String)
    case migrationFailed(String)
    case invalidMigrationPlan
    case invalidSchema
    case cloudSyncFailed(String)
    case notImplemented
}
