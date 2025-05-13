//
//  EditMode.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

enum EditMode: CaseIterable {
    case move
    case filters
    case markup
    case crop
    
    func iconName() -> String {
        switch self {
        case .move:
            "move.3d"
        case .filters:
            "camera.filters"
        case .markup:
            "pencil.tip"
        case .crop:
            "crop"
        }
    }
}
