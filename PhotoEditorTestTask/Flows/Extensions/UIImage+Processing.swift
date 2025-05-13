//
//  UIImage+Processing.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

import UIKit
import CoreImage

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
    
    func apply(filter: FilterType) -> UIImage? {
        let inputImage = self
        
        guard let ciImage = CIImage(image: inputImage) else { return nil }

        guard let coreImageFilter = CIFilter(name: filter.ciFilterName) else {
            print("Фильтр $filter.ciFilterName) не найден")
            return nil
        }

        coreImageFilter.setValue(ciImage, forKey: kCIInputImageKey)

        if filter.hasIntensity, let intensity = filter.intensityValue {
            coreImageFilter.setValue(intensity, forKey: kCIInputIntensityKey)
        }

        guard let outputImage = coreImageFilter.outputImage else { return nil }

        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
