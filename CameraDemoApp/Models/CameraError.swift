//
//  CameraError.swift
//  CameraDemoApp
//
//  Created by Claude on 2026-01-19.
//

import Foundation

/// Represents errors that can occur during camera operations
enum CameraError: Error, Equatable {
    case permissionDenied
    case cameraNotAvailable
    case captureFailure
    case unknown

    var localizedMessage: String {
        switch self {
        case .permissionDenied:
            return "Permiso de cámara denegado. Ve a Ajustes para habilitarlo."
        case .cameraNotAvailable:
            return "Cámara no disponible. Por favor, usa un dispositivo físico."
        case .captureFailure:
            return "Error al capturar la imagen. Intenta nuevamente."
        case .unknown:
            return "Ocurrió un error desconocido."
        }
    }
}
