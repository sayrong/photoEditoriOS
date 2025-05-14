//
//  ImageEditingService.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 14.05.2025.
//

import SwiftUI

protocol IImageEditingService {
    func processImage(image: UIImage, editState: PhotoEditState) -> UIImage
}

final class ImageEditingService: IImageEditingService {
    
    private var croppedImageCache: (UIImage, CropInfo)?
    private var filteredImageCache: (UIImage, FilterType, CropInfo?)?

    func processImage(image: UIImage, editState: PhotoEditState) -> UIImage {
        let croppedImage = applyCrop(image, editState.crop)
        let filteredImage = applyFilter(image: croppedImage, editState.filter, editState.crop)
        return filteredImage
    }
    
    private func applyCrop(_ originalImage: UIImage, _ cropInfo: CropInfo?) -> UIImage {
        guard let cropInfo else { return originalImage }
        if let cached = croppedImageCache, cached.1 == cropInfo { return cached.0 }

        let result = cropImage(originalImage, with: cropInfo)
            
        if let result {
            croppedImageCache = (result, cropInfo)
        } else {
            assertionFailure("crop failure")
        }
        return result ?? originalImage
    }

    private func cropImage(_ image: UIImage, with info: CropInfo) -> UIImage? {
        switch info.mode {
        case .circle, .landscape, .portrait:
            return image.cropToCircle(cropRect: info.rect)
        case .square:
            return image.cropToSquare(cropRect: info.rect)
        }
    }

    private func applyFilter(image: UIImage, _ filterInfo: FilterType?, _ cropInfo: CropInfo?) -> UIImage {
        guard let filterInfo else {
            return image
        }
        if let filteredImageCache, filteredImageCache.2 == cropInfo, filteredImageCache.1 == filterInfo {
            return filteredImageCache.0
        }
        
        let filterImage = image.apply(filter: filterInfo)
        
        if let filterImage {
            filteredImageCache = (filterImage, filterInfo, cropInfo)
        } else {
            assertionFailure()
        }
        return filterImage ?? image
    }
}
