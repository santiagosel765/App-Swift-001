//
//  MockCameraCaptureService.swift
//  CameraDemoAppTests
//
//  Created by Claude on 2026-01-19.
//

import Foundation
@testable import CameraDemoApp

/// Mock implementation of CameraCaptureService for testing
final class MockCameraCaptureService: CameraCaptureServiceProtocol {

    var cameraAvailable: Bool = true

    func isCameraAvailable() -> Bool {
        return cameraAvailable
    }
}
