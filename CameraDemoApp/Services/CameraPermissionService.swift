//
//  CameraPermissionService.swift
//  CameraDemoApp
//
//  Created by Claude on 2026-01-19.
//

import AVFoundation
import Foundation

/// Permission status for camera access
enum PermissionStatus {
    case authorized
    case denied
    case notDetermined
    case restricted
}

/// Protocol for camera permission service
protocol CameraPermissionServiceProtocol {
    func checkPermission() -> PermissionStatus
    func requestPermission() async -> PermissionStatus
}

/// Service responsible for managing camera permissions
final class CameraPermissionService: CameraPermissionServiceProtocol {

    /// Check current camera permission status
    func checkPermission() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }

    /// Request camera permission from user
    func requestPermission() async -> PermissionStatus {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    continuation.resume(returning: .authorized)
                } else {
                    continuation.resume(returning: .denied)
                }
            }
        }
    }
}
