//
//  SettingsOpener.swift
//  CameraDemoApp
//
//  Created by Claude on 2026-01-19.
//

import UIKit

/// Utility for opening app settings
final class SettingsOpener {

    /// Opens the app settings page in iOS Settings
    static func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }
}
