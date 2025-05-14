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
    
    private weak var delegate: PhotoEditorCoordinatorDelegate?
    private var stateManager: PhotoEditStateManager
    
    private var originalImage: UIImage
    
    private var croppedImageCache: (UIImage, CropInfo)?
    private var filteredImageCache: (UIImage, FilterType, CropInfo?)?
    
    @Published var editMode: EditMode?
    @Published var photoState: PhotoEditState
    
    init(originalImage: UIImage, delegate: PhotoEditorCoordinatorDelegate?) {
        self.originalImage = originalImage
        self.delegate = delegate
        self.stateManager = PhotoEditStateManager()
        self.photoState = stateManager.current
    }
    
    func startCropping() {
        delegate?.presentCropper(with: originalImage,
                                 onComplete: { [weak self] result in
            guard let self = self else { return }
            self.photoState.crop = result
            self.stateManager.commitState(self.photoState)
            self.editMode = nil
        })
    }
    
    func currentImage() -> UIImage {
        let croppedImage = applyCrop()
        let filteredImage = applyFilter(image: croppedImage)
        return filteredImage
    }
    
    private func applyCrop() -> UIImage {
        guard let cropInfo = photoState.crop else { return originalImage }
        if let cached = croppedImageCache, cached.1 == cropInfo { return cached.0 }

        let result = cropImage(with: cropInfo)
            
        if let result {
            croppedImageCache = (result, cropInfo)
        } else {
            assertionFailure("crop failure")
        }
        return result ?? originalImage
    }

    private func cropImage(with info: CropInfo) -> UIImage? {
        switch info.mode {
        case .circle, .landscape, .portrait:
            return originalImage.cropToCircle(cropRect: info.rect)
        case .square:
            return originalImage.cropToSquare(cropRect: info.rect)
        }
    }

    private func applyFilter(image: UIImage) -> UIImage {
        guard let filterInfo = photoState.filter else {
            return image
        }
        if let filteredImageCache, filteredImageCache.2 == photoState.crop, filteredImageCache.1 == filterInfo {
            return filteredImageCache.0
        }
        
        let filerImage = image.apply(filter: filterInfo)
        
        if let filerImage {
            filteredImageCache = (filerImage, filterInfo, photoState.crop)
        } else {
            assertionFailure()
        }
        return filerImage ?? image
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
