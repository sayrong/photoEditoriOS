//
//  ImageEditingService.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 14.05.2025.
//

import SwiftUI

protocol IImageEditingService {
    func processImage(image: UIImage, editState: PhotoEditState) async throws -> UIImage
}

enum ImageEditingError: Error {
    case cropFailure
    case filterFailure
}

final class ImageEditingService: IImageEditingService {
    
    private var croppedImageCache: (UIImage, CropInfo)?
    private var filteredImageCache: (UIImage, FilterType, CropInfo?)?

    func processImage(image: UIImage, editState: PhotoEditState) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let croppedImage = try self.applyCrop(image, editState.crop)
                let filteredImage = try self.applyFilter(image: croppedImage, editState.filter, editState.crop)
                continuation.resume(returning: filteredImage)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func applyCrop(_ originalImage: UIImage, _ cropInfo: CropInfo?) throws -> UIImage {
        guard let cropInfo else { return originalImage }
        if let cached = croppedImageCache, cached.1 == cropInfo { return cached.0 }

        let result = cropImage(originalImage, with: cropInfo)
        
        guard let result else {
            throw ImageEditingError.cropFailure
        }
        croppedImageCache = (result, cropInfo)
        return result
    }

    private func cropImage(_ image: UIImage, with info: CropInfo) -> UIImage? {
        switch info.mode {
        case .circle, .landscape, .portrait:
            return image.cropToCircle(cropRect: info.rect)
        case .square:
            return image.cropToSquare(cropRect: info.rect)
        }
    }

    private func applyFilter(image: UIImage, _ filterInfo: FilterType?, _ cropInfo: CropInfo?) throws -> UIImage {
        guard let filterInfo else {
            return image
        }
        if let filteredImageCache, filteredImageCache.2 == cropInfo, filteredImageCache.1 == filterInfo {
            return filteredImageCache.0
        }
        
        let filterImage = image.apply(filter: filterInfo)
        
        guard let filterImage else {
            throw ImageEditingError.filterFailure
        }
        filteredImageCache = (filterImage, filterInfo, cropInfo)
        return filterImage
    }
}
