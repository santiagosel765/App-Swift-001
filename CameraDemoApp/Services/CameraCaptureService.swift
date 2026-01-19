//
//  CameraCaptureService.swift
//  CameraDemoApp
//
//  Created by Claude on 2026-01-19.
//

import UIKit

/// Protocol for camera capture service
protocol CameraCaptureServiceProtocol {
    func isCameraAvailable() -> Bool
}

/// Service responsible for camera capture functionality
final class CameraCaptureService: CameraCaptureServiceProtocol {

    /// Check if camera is available on device
    func isCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}
