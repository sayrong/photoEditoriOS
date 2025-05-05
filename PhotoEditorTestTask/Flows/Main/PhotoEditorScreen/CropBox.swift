//
//  CropBox.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 03.05.2025.
//

import SwiftUI

struct CropBox: View {
    @Binding var cropRect: CGRect
    let imageSize: CGSize
    let boxSize: CGSize
    
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    
    var body: some View {
        Rectangle()
            .stroke(Color.yellow, lineWidth: 2)
            .frame(width: cropRect.width, height: cropRect.height)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        var newOffset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                        
                        // Ограничиваем рамку внутри картинки
                        let halfWidth = cropRect.width / 2
                        let halfHeight = cropRect.height / 2
                        
                        let maxX = (boxSize.width / 2) - halfWidth
                        let maxY = (boxSize.height / 2) - halfHeight
                        
                        newOffset.width = min(max(newOffset.width, -maxX), maxX)
                        newOffset.height = min(max(newOffset.height, -maxY), maxY)
                        
                        offset = newOffset
                        
                        // обновляем cropRect
                        cropRect.origin = CGPoint(
                            x: (boxSize.width / 2 - halfWidth + offset.width) / boxSize.width * imageSize.width,
                            y: (boxSize.height / 2 - halfHeight + offset.height) / boxSize.height * imageSize.height
                        )
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
    }
}

struct CropDemoView: View {
    let image = UIImage(systemName: "arrow.clockwise.icloud")!
    @State private var croppedImage: UIImage?
    @State private var cropRect = CGRect(x: 0, y: 0, width: 150, height: 150)
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                    
                    CropBox(
                        cropRect: $cropRect,
                        imageSize: image.size,
                        boxSize: geo.size
                    )
                }
            }
            .aspectRatio(image.size, contentMode: .fit)
            
            Button("Crop") {
                croppedImage = cropImage()
            }
            
            if let croppedImage = croppedImage {
                Image(uiImage: croppedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
        }
        .padding()
    }
    
    private func cropImage() -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let scaleX = CGFloat(cgImage.width) / image.size.width
        let scaleY = CGFloat(cgImage.height) / image.size.height
        
        let scaledRect = CGRect(
            x: cropRect.origin.x * scaleX,
            y: cropRect.origin.y * scaleY,
            width: cropRect.width * scaleX,
            height: cropRect.height * scaleY
        )
        
        guard let croppedCGImage = cgImage.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: croppedCGImage)
    }
}


#Preview {
    CropDemoView()
}
