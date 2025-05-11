//
//  PhotoEditorView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI

struct CropInfo {
    
}

final class PhotoEditorViewModel: ObservableObject {
    
    var originalImage: UIImage
    var crop: CropInfo?
    
    init(originalImage: UIImage) {
        self.originalImage = originalImage
    }
}


struct PhotoEditorView: View {
    
    enum EditMode: CaseIterable {
        case move
        case crop
        case filters
        case markup
        
        func iconName() -> String {
            switch self {
            case .move:
                "move.3d"
            case .filters:
                "camera.filters"
            case .markup:
                "pencil.tip"
            case .crop:
                "crop"
            }
        }
    }
    
    var originalImage: UIImage
    @State var editMode: EditMode?
    @StateObject var movableImageVM: MovableImageViewModel
    
    init(image: UIImage) {
        self.originalImage = image
        _movableImageVM = StateObject(wrappedValue: MovableImageViewModel(image: image))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            editControls()
            //canvas()
            CropView(image: originalImage)
            editModePanel()
        }
        .background(Asset.Colors.background.swiftUIColor)
    }
    
    func editControls() -> some View {
        HStack {
            Spacer()
            switch editMode {
            case .move:
                MovableImageControls(viewModel: movableImageVM)
            case .crop:
                Button {
                    
                } label: {
                    Text("crop")
                }

            case .filters:
                Spacer()
            case .markup:
                Spacer()
            case nil:
                Spacer()
            }
        }
        .padding(.trailing, 30)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(.black)
    }
    
    func canvas() -> some View {
        ZStack {
            Color.clear //
            MovableImage(viewModel: movableImageVM)
                //.disabled(editMode != .move)
            
            if editMode == .crop {
                crop()
            }
        }
        .clipped() // обрезает всё, что выходит за пределы
        .contentShape(Rectangle()) // чтобы жесты работали только внутри
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @State private var imageFrame: CGRect = .zero
    
    @State private var cropPosition: CGPoint = CGPoint(x: 200, y: 200)
    @State private var cropSize: CGSize = CGSize(width: 300, height: 300)

    
    func crop() -> some View {
        Group {
            // Затемнение вокруг
            Color.black.opacity(0.5)
                .mask(
                    Rectangle()
                        .overlay(
                            Rectangle()
                                .frame(width: cropSize.width, height: cropSize.height)
                                .position(cropPosition)
                                .blendMode(.destinationOut)
                        )
                )
                
            
//            // Видимая белая рамка
//            Rectangle()
//                .stroke(Color.white, lineWidth: 2)
//                .frame(width: cropSize.width, height: cropSize.height)
//                .position(cropPosition)
        }
        .allowsHitTesting(false)
    }
    
    func editModePanel() -> some View {
        HStack(spacing: 10) {
            ForEach(EditMode.allCases, id: \.self) { mode in
                Button {
                    editMode = editMode == mode ? nil : mode
                } label: {
                    Image(systemName: mode.iconName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(editMode == mode ? Color.blue : .white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.black)
    }
}


#Preview {
    PhotoEditorView(image: UIImage(named: "gotta.JPG")!)
}


extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}
