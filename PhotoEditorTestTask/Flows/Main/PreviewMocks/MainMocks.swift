//
//  Mocks.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 14.05.2025.
//

import UIKit

extension PhotoEditorViewModel {
    static func preview() -> PhotoEditorViewModel {
        PhotoEditorViewModel(originalImage: UIImage(named: "gotta.JPG")!,
                             delegate: nil,
                             stateManager: PhotoEditStateManager(),
                             imageService: ImageEditingService(),
                             exportService: ImageExportService(),
                             authService: PMockAuthService())
    }
}
