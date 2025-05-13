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
    private var processedImage: (UIImage, CropInfo)?
    
    private var filteredImage: (UIImage, FilterType, CropInfo?)?
    
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
    
    func applyCrop() -> UIImage {
        guard let cropInfo = photoState.crop else {
            return originalImage
        }
        if let processedImage, processedImage.1 == cropInfo {
            return processedImage.0
        }
        var cropImage: UIImage?
        if cropInfo.mode == .circle {
            cropImage = originalImage.cropToCircle(cropRect: cropInfo.rect)
        } else {
            cropImage = originalImage.cropToSquare(cropRect: cropInfo.rect)
        }
        if let cropImage {
            processedImage = (cropImage, cropInfo)
        } else {
            assertionFailure()
        }
        return cropImage ?? originalImage
    }
    
    func applyFilter(image: UIImage) -> UIImage {
        guard let filterInfo = photoState.filter else {
            return image
        }
        if let filteredImage, filteredImage.2 == photoState.crop, filteredImage.1 == filterInfo {
            return filteredImage.0
        }
        let filerImage = image.apply(filter: filterInfo)
        
        if let filerImage {
            filteredImage = (filerImage, filterInfo, photoState.crop)
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
