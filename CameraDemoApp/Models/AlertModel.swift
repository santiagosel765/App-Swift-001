//
//  AlertModel.swift
//  CameraDemoApp
//
//  Created by Claude on 2026-01-19.
//

import Foundation

/// Model for presenting alerts to the user
struct AlertModel: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let primaryAction: AlertAction?
    let secondaryAction: AlertAction?

    struct AlertAction {
        let title: String
        let action: () -> Void
    }

    init(title: String, message: String, primaryAction: AlertAction? = nil, secondaryAction: AlertAction? = nil) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}
