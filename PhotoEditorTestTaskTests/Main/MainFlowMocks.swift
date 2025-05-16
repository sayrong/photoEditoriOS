//
//  MainFlowMocks.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 16.05.2025.
//

import XCTest
import SwiftUI
@testable import PhotoEditorTestTask
import PencilKit

class MockStateManager: IPhotoEditStateManager {
    var current = PhotoEditState()
    var canUndoValue = false
    var canRedoValue = false
    var undoCalled = false
    var redoCalled = false
    var commitStateCalled = false

    func canUndo() -> Bool { canUndoValue }
    func canRedo() -> Bool { canRedoValue }
    func undo() { undoCalled = true }
    func redo() { redoCalled = true }
    func commitState(_ state: PhotoEditState) { commitStateCalled = true; current = state }
}

class MockImageEditingService: IImageEditingService {
    func processImage(image: UIImage, editState: PhotoEditState) -> UIImage {
        // Return a dummy image or the input image
        return image
    }
}

class MockImageExportService: IImageExportService {
    func exportCanvas(canvasSize: CGSize, canvasView: PKCanvasView, image: UIImage, photoState: PhotoEditState) -> UIImage {
        // Return a dummy image or the input image
        return image
    }
}

class MockCoordinator: PhotoEditorCoordinatorDelegate {
    var presentCropperCalled = false
    var lastImage: UIImage?
    var onComplete: ((CropInfo) -> Void)?

    func presentCropper(with image: UIImage, onComplete: @escaping (CropInfo) -> Void) {
        presentCropperCalled = true
        lastImage = image
        self.onComplete = onComplete
    }
}
