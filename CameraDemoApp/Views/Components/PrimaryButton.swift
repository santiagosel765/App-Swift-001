//
//  PrimaryButton.swift
//  CameraDemoApp
//
//  Created by Claude on 2026-01-19.
//

import SwiftUI

/// Reusable primary button component with consistent styling
struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    init(
        title: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
        .accessibilityLabel(title)
    }
}

/// Secondary button variant
struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.blue.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.blue.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Tomar Foto", isLoading: false) { }
        PrimaryButton(title: "Cargando...", isLoading: true) { }
        SecondaryButton(title: "Retomar") { }
    }
    .padding()
}
