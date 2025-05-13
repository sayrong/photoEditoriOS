//
//  FilterType.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

import Foundation

typealias Intensity = CGFloat

enum FilterType: CaseIterable, Hashable {
    case sepia(Intensity)
    
    case noir
    case transfer
    case vintage
    case chrome
    case instant
    
    static var allCases: [FilterType] {
        return [
            .sepia(0.5),
            .noir,
            .transfer,
            .vintage,
            .chrome,
            .instant
        ]
    }
}

extension FilterType {
    var ciFilterName: String {
        switch self {
        case .sepia: return "CISepiaTone"
        case .noir: return "CIPhotoEffectNoir"
        case .transfer: return "CIPhotoEffectTransfer"
        case .vintage: return "CIPhotoEffectInstant"
        case .chrome: return "CIPhotoEffectChrome"
        case .instant: return "CIPhotoEffectProcess"
        }
    }
    
    var displayName: String {
        switch self {
        case .sepia: return "Sepia"
        case .noir: return "Noir"
        case .transfer: return "Transfer"
        case .vintage: return "Vintage"
        case .chrome: return "Chrome"
        case .instant: return "Instant"
        }
    }

    var hasIntensity: Bool {
        switch self {
        case .sepia, .noir, .transfer:
            return true
        case .vintage, .chrome, .instant:
            return false
        }
    }

    var intensityValue: CGFloat? {
        switch self {
        case .sepia(let value): return value
        default: return nil
        }
    }
}
