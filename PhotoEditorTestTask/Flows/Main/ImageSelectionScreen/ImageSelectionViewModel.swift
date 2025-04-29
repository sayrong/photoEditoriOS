//
//  ImageSelectionViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import Combine
import UIKit

final class ImageSelectionViewModel: ObservableObject {
    
    @Published private var showingImagePicker = false
    @Published private var showingCamera = false
    @Published private var selectedImage: UIImage? = nil
}
