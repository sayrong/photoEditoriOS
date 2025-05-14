//
//  PhotoEditorViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

import SwiftUI

protocol PhotoEditorCoordinatorDelegate: AnyObject {
    func presentCropper(with image: UIImage, onComplete: @escaping (CropInfo) -> Void)
}

final class PhotoEditorViewModel: ObservableObject {
    
    private weak var coordinator: PhotoEditorCoordinatorDelegate?
    private var stateManager: IPhotoEditStateManager
    private var imageService: IImageEditingService
    
    private var originalImage: UIImage
    
    @Published var editMode: EditMode? {
        didSet {
            handleEditModeChange(oldValue, editMode)
        }
    }
    @Published var photoState: PhotoEditState
    
    init(originalImage: UIImage, delegate: PhotoEditorCoordinatorDelegate?,
         stateManager: IPhotoEditStateManager, imageService: IImageEditingService) {
        self.originalImage = originalImage
        self.coordinator = delegate
        self.stateManager = stateManager
        self.imageService = imageService
        self.photoState = stateManager.current
    }
    
    private func handleEditModeChange(_ oldValue: EditMode?, _ newValue: EditMode?) {
        if newValue == .crop {
            startCropping()
        }
        if oldValue == .filters {
            commitState()
        }
    }
    
    private func startCropping() {
        coordinator?.presentCropper(with: originalImage,
                                 onComplete: { [weak self] result in
            guard let self = self else { return }
            self.photoState.crop = result
            self.stateManager.commitState(self.photoState)
            self.editMode = nil
        })
    }
    
    func renderedImage() -> UIImage {
        imageService.processImage(image: originalImage, editState: photoState)
    }
    
    func canUndo() -> Bool {
        stateManager.canUndo()
    }
    
    func canRedo() -> Bool {
        stateManager.canRedo()
    }
    
    func undo() {
        stateManager.undo()
        photoState = stateManager.current
    }
    
    func redo() {
        stateManager.redo()
        photoState = stateManager.current
    }
    
    func commitState() {
        stateManager.commitState(photoState)
    }
}
