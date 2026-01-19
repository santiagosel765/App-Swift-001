//
//  CameraScreen.swift
//  CameraDemoApp
//
//  Created by Claude on 2026-01-19.
//

import SwiftUI

/// Main camera screen view
struct CameraScreen: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.96, blue: 0.98),
                    Color(red: 0.98, green: 0.98, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Captura de Cámara")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Toma una foto y visualízala")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                Spacer()

                // Image preview or empty state
                if let image = viewModel.image {
                    imagePreview(image)
                } else {
                    emptyState
                }

                Spacer()

                // Action buttons
                actionButtons
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $viewModel.showCameraPicker, onDismiss: {
            viewModel.onCameraPickerDismissed()
        }) {
            CameraPicker(
                image: $viewModel.image,
                onError: { error in
                    viewModel.handleCameraError(error)
                }
            )
        }
        .alert(item: $viewModel.alert) { alertModel in
            createAlert(from: alertModel)
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue.opacity(0.3))

            Text("No hay foto capturada")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)

            Text("Presiona el botón para tomar una foto")
                .font(.system(size: 14))
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .accessibilityLabel("Estado vacío - No hay foto capturada")
    }

    private func imagePreview(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 400)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 8)
            .accessibilityLabel("Foto capturada")
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            PrimaryButton(
                title: viewModel.image == nil ? "Tomar Foto" : "Tomar Nueva Foto",
                isLoading: viewModel.state.isLoading,
                action: {
                    viewModel.takePhotoTapped()
                }
            )

            if viewModel.image != nil {
                SecondaryButton(title: "Limpiar") {
                    viewModel.retakePhoto()
                }
            }
        }
    }

    // MARK: - Alert Helper

    private func createAlert(from alertModel: AlertModel) -> Alert {
        if let primaryAction = alertModel.primaryAction,
           let secondaryAction = alertModel.secondaryAction {
            return Alert(
                title: Text(alertModel.title),
                message: Text(alertModel.message),
                primaryButton: .default(Text(primaryAction.title)) {
                    primaryAction.action()
                },
                secondaryButton: .cancel(Text(secondaryAction.title)) {
                    secondaryAction.action()
                }
            )
        } else if let primaryAction = alertModel.primaryAction {
            return Alert(
                title: Text(alertModel.title),
                message: Text(alertModel.message),
                dismissButton: .default(Text(primaryAction.title)) {
                    primaryAction.action()
                }
            )
        } else {
            return Alert(
                title: Text(alertModel.title),
                message: Text(alertModel.message)
            )
        }
    }
}

#Preview {
    CameraScreen()
}
