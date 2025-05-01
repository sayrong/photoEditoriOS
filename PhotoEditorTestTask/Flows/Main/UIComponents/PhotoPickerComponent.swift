//
//  ImagePickerComponent.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 30.04.2025.
//

import SwiftUI
import PhotosUI

struct ImagePickerComponent: UIViewControllerRepresentable {
    
    var result: (UIImage) -> Void
   
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        private let parent: ImagePickerComponent
        
        init(_ parent: ImagePickerComponent) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let uiImage = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.result(uiImage)
                        }
                    }
                }
            }
        }
    }
}
