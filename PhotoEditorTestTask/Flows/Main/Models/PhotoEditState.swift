//
//  PhotoEditState.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 14.05.2025.
//
import SwiftUI
import PencilKit

struct PhotoEditState: Equatable {
    var position: CGSize = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var crop: CropInfo?
    var filter: FilterType?
    var drawning: PKDrawing?
}
