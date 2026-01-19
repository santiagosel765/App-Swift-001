//
//  CameraViewModel.swift
//  CameraDemoApp
//
//  Created by Claude on 2026-01-19.
//

import SwiftUI
import Combine

/// ViewModel for camera functionality, following MVVM pattern
@MainActor
final class CameraViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var state: CameraState = .idle
    @Published var image: UIImage?
    @Published var alert: AlertModel?
    @Published var showCameraPicker = false

    // MARK: - Dependencies

    private let permissionService: CameraPermissionServiceProtocol
    private let captureService: CameraCaptureServiceProtocol

    // MARK: - Initialization

    init(
        permissionService: CameraPermissionServiceProtocol = CameraPermissionService(),
        captureService: CameraCaptureServiceProtocol = CameraCaptureService()
    ) {
        self.permissionService = permissionService
        self.captureService = captureService
    }

    // MARK: - Public Methods

    /// Called when user taps the "Tomar foto" button
    func takePhotoTapped() {
        Task {
            await handleCameraRequest()
        }
    }

    /// Called when user taps the "Retomar" button
    func retakePhoto() {
        image = nil
        state = .idle
    }

    /// Handle error from camera picker
    func handleCameraError(_ error: CameraError) {
        state = .error(error)
        showAlert(
            title: "Error",
            message: error.localizedMessage
        )
    }

    // MARK: - Private Methods

    private func handleCameraRequest() async {
        // Check if camera is available (e.g., not simulator)
        guard captureService.isCameraAvailable() else {
            state = .error(.cameraNotAvailable)
            showAlert(
                title: "Cámara No Disponible",
                message: CameraError.cameraNotAvailable.localizedMessage
            )
            return
        }

        // Check and request permission
        let permissionStatus = await checkAndRequestPermission()

        switch permissionStatus {
        case .authorized:
            state = .capturing
            showCameraPicker = true

        case .denied, .restricted:
            state = .permissionDenied
            showPermissionDeniedAlert()

        case .notDetermined:
            // Should not happen as we just requested
            break
        }
    }

    private func checkAndRequestPermission() async -> PermissionStatus {
        let currentStatus = permissionService.checkPermission()

        switch currentStatus {
        case .authorized:
            return .authorized

        case .notDetermined:
            state = .requestingPermission
            return await permissionService.requestPermission()

        case .denied, .restricted:
            return currentStatus
        }
    }

    private func showPermissionDeniedAlert() {
        alert = AlertModel(
            title: "Permiso Denegado",
            message: "La cámara necesita permiso para funcionar. Por favor, habilítalo en Ajustes.",
            primaryAction: AlertModel.AlertAction(
                title: "Abrir Ajustes",
                action: {
                    SettingsOpener.openSettings()
                }
            ),
            secondaryAction: AlertModel.AlertAction(
                title: "Cancelar",
                action: { }
            )
        )
    }

    private func showAlert(title: String, message: String) {
        alert = AlertModel(
            title: title,
            message: message,
            primaryAction: AlertModel.AlertAction(
                title: "OK",
                action: { }
            )
        )
    }

    /// Called when camera picker is dismissed
    func onCameraPickerDismissed() {
        if image != nil {
            state = .captured
        } else {
            state = .idle
        }
    }
}
