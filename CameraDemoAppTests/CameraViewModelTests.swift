//
//  CameraViewModelTests.swift
//  CameraDemoAppTests
//
//  Created by Claude on 2026-01-19.
//

import XCTest
import SwiftUI
@testable import CameraDemoApp

@MainActor
final class CameraViewModelTests: XCTestCase {

    var viewModel: CameraViewModel!
    var mockPermissionService: MockCameraPermissionService!
    var mockCaptureService: MockCameraCaptureService!

    override func setUp() {
        super.setUp()
        mockPermissionService = MockCameraPermissionService()
        mockCaptureService = MockCameraCaptureService()
        viewModel = CameraViewModel(
            permissionService: mockPermissionService,
            captureService: mockCaptureService
        )
    }

    override func tearDown() {
        viewModel = nil
        mockPermissionService = nil
        mockCaptureService = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertNil(viewModel.image)
        XCTAssertNil(viewModel.alert)
        XCTAssertFalse(viewModel.showCameraPicker)
    }

    // MARK: - Permission Denied Tests

    func testTakePhotoWhenPermissionDenied() async {
        // Given
        mockPermissionService.currentStatus = .denied
        mockCaptureService.cameraAvailable = true

        // When
        viewModel.takePhotoTapped()

        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s

        // Then
        XCTAssertEqual(viewModel.state, .permissionDenied)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertEqual(viewModel.alert?.title, "Permiso Denegado")
        XCTAssertFalse(viewModel.showCameraPicker)
    }

    func testTakePhotoWhenPermissionRestricted() async {
        // Given
        mockPermissionService.currentStatus = .restricted
        mockCaptureService.cameraAvailable = true

        // When
        viewModel.takePhotoTapped()

        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s

        // Then
        XCTAssertEqual(viewModel.state, .permissionDenied)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertFalse(viewModel.showCameraPicker)
    }

    // MARK: - Permission Authorized Tests

    func testTakePhotoWhenPermissionAuthorized() async {
        // Given
        mockPermissionService.currentStatus = .authorized
        mockCaptureService.cameraAvailable = true

        // When
        viewModel.takePhotoTapped()

        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s

        // Then
        XCTAssertEqual(viewModel.state, .capturing)
        XCTAssertTrue(viewModel.showCameraPicker)
    }

    func testTakePhotoWhenPermissionNotDeterminedAndGranted() async {
        // Given
        mockPermissionService.currentStatus = .notDetermined
        mockPermissionService.requestResult = .authorized
        mockCaptureService.cameraAvailable = true

        // When
        viewModel.takePhotoTapped()

        // Wait for async operations
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s

        // Then
        XCTAssertEqual(viewModel.state, .capturing)
        XCTAssertTrue(viewModel.showCameraPicker)
    }

    func testTakePhotoWhenPermissionNotDeterminedAndDenied() async {
        // Given
        mockPermissionService.currentStatus = .notDetermined
        mockPermissionService.requestResult = .denied
        mockCaptureService.cameraAvailable = true

        // When
        viewModel.takePhotoTapped()

        // Wait for async operations
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s

        // Then
        XCTAssertEqual(viewModel.state, .permissionDenied)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertFalse(viewModel.showCameraPicker)
    }

    // MARK: - Camera Availability Tests

    func testTakePhotoWhenCameraNotAvailable() async {
        // Given
        mockPermissionService.currentStatus = .authorized
        mockCaptureService.cameraAvailable = false

        // When
        viewModel.takePhotoTapped()

        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s

        // Then
        XCTAssertEqual(viewModel.state, .error(.cameraNotAvailable))
        XCTAssertNotNil(viewModel.alert)
        XCTAssertEqual(viewModel.alert?.title, "Cámara No Disponible")
        XCTAssertFalse(viewModel.showCameraPicker)
    }

    // MARK: - Retake Photo Tests

    func testRetakePhoto() {
        // Given
        viewModel.image = UIImage()
        viewModel.state = .captured

        // When
        viewModel.retakePhoto()

        // Then
        XCTAssertNil(viewModel.image)
        XCTAssertEqual(viewModel.state, .idle)
    }

    // MARK: - Camera Picker Dismissed Tests

    func testCameraPickerDismissedWithImage() {
        // Given
        viewModel.image = UIImage()
        viewModel.state = .capturing

        // When
        viewModel.onCameraPickerDismissed()

        // Then
        XCTAssertEqual(viewModel.state, .captured)
    }

    func testCameraPickerDismissedWithoutImage() {
        // Given
        viewModel.image = nil
        viewModel.state = .capturing

        // When
        viewModel.onCameraPickerDismissed()

        // Then
        XCTAssertEqual(viewModel.state, .idle)
    }

    // MARK: - Error Handling Tests

    func testHandleCameraError() {
        // Given
        let error = CameraError.captureFailure

        // When
        viewModel.handleCameraError(error)

        // Then
        XCTAssertEqual(viewModel.state, .error(.captureFailure))
        XCTAssertNotNil(viewModel.alert)
        XCTAssertEqual(viewModel.alert?.title, "Error")
        XCTAssertEqual(viewModel.alert?.message, error.localizedMessage)
    }

    // MARK: - State Loading Tests

    func testStateIsLoadingForRequestingPermission() {
        viewModel.state = .requestingPermission
        XCTAssertTrue(viewModel.state.isLoading)
    }

    func testStateIsLoadingForCapturing() {
        viewModel.state = .capturing
        XCTAssertTrue(viewModel.state.isLoading)
    }

    func testStateIsNotLoadingForIdle() {
        viewModel.state = .idle
        XCTAssertFalse(viewModel.state.isLoading)
    }

    func testStateIsNotLoadingForCaptured() {
        viewModel.state = .captured
        XCTAssertFalse(viewModel.state.isLoading)
    }

    func testStateIsNotLoadingForError() {
        viewModel.state = .error(.unknown)
        XCTAssertFalse(viewModel.state.isLoading)
    }
}
