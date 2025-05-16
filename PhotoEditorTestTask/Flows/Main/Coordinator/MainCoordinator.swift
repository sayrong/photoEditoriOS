//
//  MainCoordinator.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI

final class MainCoordinator: ObservableObject {
    
    enum Route: Identifiable, Hashable {
        static func == (lhs: MainCoordinator.Route, rhs: MainCoordinator.Route) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        var id: String {
            switch self {
            case .selection:
                return "selection"
            case .imageLibrary:
                return "imageLibrary"
            case .camera:
                return "camera"
            case .editor:
                return "editor"
            case .crop:
                return "crop"
            }
        }
        
        case selection
        case imageLibrary
        case camera
        case editor(UIImage)
        case crop(UIImage, (CropInfo) -> Void)
    }
    
    @Published var path: [Route] = []
    @Published var presentedSheet: Route?
    @Published var presentedFullScreen: Route?
    
    private var editorVM: PhotoEditorViewModel?
    
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .selection:
            selectionView()
        case .imageLibrary:
            imageLibraryView()
        case .camera:
            cameraView()
        case .editor(let image):
            editorView(for: image)
        case .crop(let image, let onComplete):
            cropView(for: image, with: onComplete)
        }
    }
    
    private func selectionView() -> some View {
        ImageSelectionView(viewModel: ImageSelectionViewModel(delegate: self))
    }
    
    private func imageLibraryView() -> some View {
        ImagePickerComponent {
            self.path.append(.editor($0))
        }
    }
    
    private func cameraView() -> some View {
        CameraPickerComponent {
            self.path.append(.editor($0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
    }
    
    private func editorView(for img: UIImage) -> some View {
        if editorVM == nil {
            editorVM = PhotoEditorViewModel(originalImage: img, delegate: self,
                                            stateManager: PhotoEditStateManager(),
                                            imageService: ImageEditingService(),
                                            exportService: ImageExportService())
        }
        return PhotoEditorView(viewModel: editorVM!)
    }
    
    private func cropView(for image: UIImage, with onComplete: @escaping (CropInfo) -> Void) -> some View {
        let vm = CropViewModel(image: image, onCrop: { result in
            onComplete(result)
            self.presentedSheet = nil
        }, onCancel: {
            self.presentedSheet = nil
        })
        return CropView(viewModel: vm)
    }
}

extension MainCoordinator: ImageSelectionCoordinatorDelegate {
    func importPhotoFromLibrary() {
        presentedSheet = .imageLibrary
    }
    
    func importPhotoFromCamera() {
        presentedFullScreen = .camera
    }
}

extension MainCoordinator: PhotoEditorCoordinatorDelegate {
    
    func presentCropper(with image: UIImage, onComplete: @escaping (CropInfo) -> Void) {
        presentedSheet = .crop(image, onComplete)
    }
}
