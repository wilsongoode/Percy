//
//  PercyError.swift
//  Percy
//
//  Created by Wilson Goode on 5/4/25.
//


public enum PercyError: Error {
    case setupFailed(Error)
    case backupFailed(Error)
    case restoreFailed(Error)
    case migrationFailed(Error)
    case cloudSyncFailed(Error)
    case notImplemented
}
