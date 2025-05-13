//
//  UIImage+Processing.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

import UIKit

extension UIImage {
    
    func cropToCircle(cropRect: CGRect) -> UIImage? {
        let image = self
        let imageRendererFormat = image.imageRendererFormat
        imageRendererFormat.opaque = false
        
        let circleCroppedImage = UIGraphicsImageRenderer(
            size: cropRect.size,
            format: imageRendererFormat).image { _ in
                let drawRect = CGRect(origin: .zero, size: cropRect.size)
                UIBezierPath(ovalIn: drawRect).addClip()
                let drawImageRect = CGRect(
                    origin: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y),
                    size: image.size
                )
                image.draw(in: drawImageRect)
            }
        
        return circleCroppedImage
    }
    
    func cropToSquare(cropRect: CGRect) -> UIImage? {
        let image = self
        guard let cgImage = image.cgImage,
              let result = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: result)
    }
}
