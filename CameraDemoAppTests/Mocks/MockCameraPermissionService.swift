//
//  MockCameraPermissionService.swift
//  CameraDemoAppTests
//
//  Created by Claude on 2026-01-19.
//

import Foundation
@testable import CameraDemoApp

/// Mock implementation of CameraPermissionService for testing
final class MockCameraPermissionService: CameraPermissionServiceProtocol {

    var currentStatus: PermissionStatus = .notDetermined
    var requestResult: PermissionStatus = .authorized

    func checkPermission() -> PermissionStatus {
        return currentStatus
    }

    func requestPermission() async -> PermissionStatus {
        currentStatus = requestResult
        return requestResult
    }
}
