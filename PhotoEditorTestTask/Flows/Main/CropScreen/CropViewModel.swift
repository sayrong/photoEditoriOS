//
//  CropViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 12.05.2025.
//

import SwiftUI

final class CropViewModel: ObservableObject {
    
    var image: UIImage
    var onCrop: ((CropInfo) -> Void)?
    var onCancel: (() -> Void)?
    
    @Published var cropMode: CropMode = .square
    @Published var scale: CGFloat = 1
    @Published var offset: CGSize = .zero
    var lastScale: CGFloat = 1
    var lastOffset: CGSize = .zero
    var imageViewSize: CGSize = .zero
    
    init(image: UIImage, onCrop: ((CropInfo) -> Void)?, onCancel: (() -> Void)?) {
        self.image = image
        self.onCrop = onCrop
        self.onCancel = onCancel
    }
    
    func defineCrop() {
        let cropRect = calculateCropRect(image)
        onCrop?(CropInfo(mode: cropMode, rect: cropRect))
    }
    
    func cancel() {
        onCancel?()
    }
    
    // MARK: Gestures
    func processDragValue(_ value: CGSize) {
        let maxOffsetPoint = calculateDragGestureMax()
        // limit in interval
        let newX = min(
            max(value.width + lastOffset.width, -maxOffsetPoint.x),
            maxOffsetPoint.x
        )
        let newY = min(
            max(value.height + lastOffset.height, -maxOffsetPoint.y),
            maxOffsetPoint.y
        )
        offset = CGSize(width: newX, height: newY)
    }
    
    func dragDidEnd() {
        lastOffset = offset
    }
    
    func processScaleValue(_ value: CGFloat) {
        let maxScaleValues = calculateMagnificationGestureMaxValues()
        scale = min(max(value * lastScale, maxScaleValues.0), maxScaleValues.1)
        updateOffset()
    }
    
    func scaleDidEnd() {
        lastScale = scale
        lastOffset = offset
    }
    
    private func updateOffset() {
        let maxOffsetPoint = calculateDragGestureMax()
        let newX = min(max(offset.width, -maxOffsetPoint.x), maxOffsetPoint.x)
        let newY = min(max(offset.height, -maxOffsetPoint.y), maxOffsetPoint.y)
        offset = CGSize(width: newX, height: newY)
        lastOffset = offset
    }
    
    private func calculateDragGestureMax() -> CGPoint {
        let imageSizeInView = imageViewSize
        let maskSize = cropMode.size()
        let xLimit = max(0, ((imageSizeInView.width / 2) * scale) - (maskSize.width / 2))
        let yLimit = max(0, ((imageSizeInView.height / 2) * scale) - (maskSize.height / 2))
        return CGPoint(x: xLimit, y: yLimit)
    }
    
    private func calculateMagnificationGestureMaxValues() -> (CGFloat, CGFloat) {
        let maxMagnificationScale: CGFloat = 4.0
        let imageSizeInView = imageViewSize
        let maskSize = cropMode.size()
        let minScale = max(maskSize.width / imageSizeInView.width, maskSize.height / imageSizeInView.height)
        return (minScale, maxMagnificationScale)
    }
     
    private func calculateCropRect(_ image: UIImage) -> CGRect {
        let factor = min(
            (image.size.width / imageViewSize.width),
            (image.size.height / imageViewSize.height)
        )
        let centerInOriginalImage = CGPoint(
            x: image.size.width / 2,
            y: image.size.height / 2
        )
        
        let maskSize = cropMode.size()
        let cropSizeInOriginalImage = CGSize(
            width: (maskSize.width * factor) / scale,
            height: (maskSize.height * factor) / scale
        )
        
        let offsetX = offset.width * factor / scale
        let offsetY = offset.height * factor / scale
        
        let cropRectX = (centerInOriginalImage.x - cropSizeInOriginalImage.width / 2) - offsetX
        let cropRectY = (centerInOriginalImage.y - cropSizeInOriginalImage.height / 2) - offsetY
        
        return CGRect(
            origin: CGPoint(x: cropRectX, y: cropRectY),
            size: cropSizeInOriginalImage
        )
    }
}
