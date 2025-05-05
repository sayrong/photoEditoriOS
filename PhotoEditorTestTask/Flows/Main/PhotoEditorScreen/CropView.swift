//
//  CropView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 03.05.2025.
//

import SwiftUI

class CropViewModel: ObservableObject {
    
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
//    func cropImage() {
//        let renderer = ImageRenderer(content: imageView())
//        renderer.proposedSize = .init(cropSize)
//        if let image = renderer.uiImage {
//            print("ok")
//        } else {
//            print("not ok")
//        }
//    }
    
}

enum CropMode: CaseIterable {
    case circle
    case square
    case landscape
    case portrait
    
    func iconName() -> String {
        switch self {
        case .circle:
            "circle"
        case .square:
            "square"
        case .landscape:
            "rectangle"
        case .portrait:
            "rectangle.portrait"
        }
    }
    
    func size() -> CGSize {
        switch self {
        case .circle:
                .init(width: 300, height: 300)
        case .square:
                .init(width: 300, height: 300)
        case .landscape:
                .init(width: 400, height: 300)
        case .portrait:
                .init(width: 300, height: 420)
        }
    }
}

struct CropView: View {
    
    var image: UIImage
    var onCrop: ((UIImage?) -> Void)?
    
    @State private var cropMode: CropMode = .circle
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @GestureState var isInteracting = false
    
    var body: some View {
        imageView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.black
            }
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    func imageView() -> some View {
        let cropSize = cropMode.size()
        GeometryReader {
            let size = $0.size
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(content: {
                    GeometryReader { proxy in
                        let rect = proxy.frame(in: .named("CROP"))
                        Color.clear
                            .onChange(of: isInteracting) { _, newValue in
                                controlOffset(objectRect: rect, cropSize: size, isInteracting: newValue)
                            }
                    }
                })
                .frame(width: size.width, height: size.height)
        }
        .frame(width: cropSize.width, height: cropSize.height)
        .offset(offset)
        .scaleEffect(scale)
        .overlay {
            grid()
        }
        .cornerRadius(cropMode == .circle ? cropSize.height / 2 : 0)
        .coordinateSpace(name: "CROP")
        .gesture(
            dragGesture()
        )
        .gesture(
            scaleGesture()
        )
    }
    
    private func controlOffset(objectRect: CGRect, cropSize: CGSize, isInteracting: Bool) {
        withAnimation {
            if objectRect.minX > 0 {
                offset.width = (offset.width - objectRect.minX)
            }
            if objectRect.minY > 0 {
                offset.height = (offset.height - objectRect.minY)
            }
            
            if objectRect.maxX < cropSize.width {
                offset.width = objectRect.minX - offset.width
            }
            
            if objectRect.maxY < cropSize.height {
                offset.height = objectRect.minY - offset.height
            }
        }
        if !isInteracting {
            lastOffset = offset
        }
    }
    
    private func scaleGesture() -> some Gesture {
        MagnificationGesture()
            .updating($isInteracting, body: { _, out, _ in
                out = true
            })
            .onChanged({ value in
                let updatedScale = value + lastScale
                scale = (updatedScale < 1 ? 1 : updatedScale)
            })
            .onEnded({ _ in
                if scale < 1 {
                    scale = 1
                    lastScale = 0
                } else {
                    lastScale = scale - 1
                }
            })
    }
    
    private func dragGesture() -> some Gesture {
        DragGesture()
            .updating($isInteracting, body: { _, out, _ in
                out = true
            })
            .onChanged({ value in
                offset = CGSize(width: value.translation.width + lastOffset.width, height: value.translation.height + lastOffset.height)
            })
    }
    
    func grid() -> some View {
        ZStack {
            HStack {
                ForEach(1...5, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.8))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            VStack {
                ForEach(1...8, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.8))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
}

#Preview {
    CropView(image: UIImage(named: "gotta.JPG")!)
}


