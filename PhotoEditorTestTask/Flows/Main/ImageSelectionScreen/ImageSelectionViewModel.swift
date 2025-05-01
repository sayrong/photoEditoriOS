//
//  ImageSelectionViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import Combine
import UIKit

protocol ImageSelectionCoordinatorDelegate: AnyObject {
    func importPhotoFromLibrary()
    func importPhotoFromCamera()
}

final class ImageSelectionViewModel: ObservableObject {
    
    private weak var delegate: ImageSelectionCoordinatorDelegate?
    
    init(delegate: ImageSelectionCoordinatorDelegate? = nil) {
        self.delegate = delegate
    }
    
    func fromLibraryDidTap() {
        delegate?.importPhotoFromLibrary()
    }
    
    func fromCameraDidTap() {
        delegate?.importPhotoFromCamera()
    }
}
