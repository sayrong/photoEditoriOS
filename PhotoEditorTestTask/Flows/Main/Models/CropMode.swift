//
//  CropMode.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 12.05.2025.
//

import SwiftUI

enum CropMode: CaseIterable {

    case circle
    case square
    case landscape
    case portrait
    
    func iconName() -> String {
        switch self {
        case .circle:
            "circle"
        case .square:
            "square"
        case .landscape:
            "rectangle"
        case .portrait:
            "rectangle.portrait"
        }
    }
    
    func size() -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let baseSize = screenWidth * 0.7
        
        let landscapeAspectRatio: CGFloat = 4/3
        let portraitAspectRatio: CGFloat = 2/3

        switch self {
        case .circle, .square:
            return CGSize(width: baseSize, height: baseSize)
        case .landscape:
            let height = baseSize / landscapeAspectRatio
            return CGSize(width: baseSize, height: height)
        case .portrait:
            let width = baseSize * portraitAspectRatio
            return CGSize(width: width, height: baseSize)
        }
    }
    
    @ViewBuilder
    func shape() -> some View {
        switch self {
        case .circle:
            Circle()
        case .square, .landscape, .portrait:
            Rectangle()
        }
    }
}
