//
//  MainCoordinator.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI

final class MainCoordinator: ObservableObject {
    
    enum Route: Identifiable, Hashable {
        var id: Self { self }
        
        case selection
        case imageLibrary
        case camera
        case editor(UIImage)
    }
    
    @Published var path: [Route] = []
    @Published var presentedSheet: Route?
    @Published var presentedFullScreen: Route?
    
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .selection:
            selectionView()
        case .imageLibrary:
            ImagePickerComponent {
                self.path.append(.editor($0))
            }
        case .camera:
            CameraPickerComponent {
                self.path.append(.editor($0))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
        case .editor(let img):
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
        }
    }
    
    private func selectionView() -> some View {
        ImageSelectionView(viewModel: ImageSelectionViewModel(delegate: self))
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
