//
//  PhotoText.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 14.05.2025.
//

import SwiftUI

struct PhotoText: Identifiable, Equatable {
    let id: UUID = UUID()
    var text: String
    var offset: CGSize
    var scale: CGFloat
    var rotation: Angle
    var color: Color
}
