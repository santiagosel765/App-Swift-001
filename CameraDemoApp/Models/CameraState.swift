//
//  CameraState.swift
//  CameraDemoApp
//
//  Created by Claude on 2026-01-19.
//

import Foundation

/// Represents the current state of the camera functionality
enum CameraState: Equatable {
    case idle
    case requestingPermission
    case permissionDenied
    case capturing
    case captured
    case error(CameraError)

    var isLoading: Bool {
        switch self {
        case .requestingPermission, .capturing:
            return true
        default:
            return false
        }
    }

    static func == (lhs: CameraState, rhs: CameraState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.requestingPermission, .requestingPermission),
             (.permissionDenied, .permissionDenied),
             (.capturing, .capturing),
             (.captured, .captured):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
