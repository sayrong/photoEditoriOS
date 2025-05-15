//
//  PhotoEditorViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

import SwiftUI

protocol PhotoEditorCoordinatorDelegate: AnyObject {
    func presentCropper(with image: UIImage, onComplete: @escaping (CropInfo) -> Void)
}

final class PhotoEditorViewModel: ObservableObject {
    
    private weak var coordinator: PhotoEditorCoordinatorDelegate?
    private var stateManager: IPhotoEditStateManager
    private var imageService: IImageEditingService
    
    private var originalImage: UIImage
    
    @Published var editMode: EditMode? {
        didSet {
            handleEditModeChange(oldValue, editMode)
        }
    }
    @Published var photoState: PhotoEditState
    @Published var selectedTextId: UUID?
    
    init(originalImage: UIImage, delegate: PhotoEditorCoordinatorDelegate?,
         stateManager: IPhotoEditStateManager, imageService: IImageEditingService) {
        self.originalImage = originalImage
        self.coordinator = delegate
        self.stateManager = stateManager
        self.imageService = imageService
        self.photoState = stateManager.current
    }
    
    private func handleEditModeChange(_ oldValue: EditMode?, _ newValue: EditMode?) {
        if newValue == .crop {
            startCropping()
        }
        if oldValue == .filters {
            commitState()
        }
    }
    
    private func startCropping() {
        coordinator?.presentCropper(with: originalImage,
                                 onComplete: { [weak self] result in
            guard let self = self else { return }
            self.photoState.crop = result
            self.stateManager.commitState(self.photoState)
            self.editMode = nil
        })
    }

    // Создает Binding для ColorPicker
    func colorBinding() -> Binding<Color> {
        Binding(
            get: { [weak self] in
                self?.getSelectedTextColor() ?? .white
            },
            set: { [weak self] newValue in
                self?.updateSelectedTextColor(newValue)
            }
        )
    }
    
    private func getSelectedTextColor() -> Color {
        if let id = selectedTextId, let text = photoState.texts.first(where: { $0.id == id }) {
            return text.color
        }
        return .white
    }
    
    private func updateSelectedTextColor(_ newColor: Color) {
        if let id = selectedTextId, let index = photoState.texts.firstIndex(where: { $0.id == id }) {
            photoState.texts[index].color = newColor
        }
    }
    
    func addText() {
        let text = PhotoText(
            text: "",
            offset: CGSize(width: 0, height: 0),
            scale: 1.0,
            rotation: .zero,
            color: .white
        )
        photoState.texts.append(text)
        selectedTextId = text.id
    }
    
    func tappedOutsideText() {
        if selectedTextId != nil {
            selectedTextId = nil
        }
    }
    
    func renderedImage() -> UIImage {
        imageService.processImage(image: originalImage, editState: photoState)
    }
    
    func canUndo() -> Bool {
        stateManager.canUndo()
    }
    
    func canRedo() -> Bool {
        stateManager.canRedo()
    }
    
    func undo() {
        stateManager.undo()
        photoState = stateManager.current
    }
    
    func redo() {
        stateManager.redo()
        photoState = stateManager.current
    }
    
    func commitState() {
        handleEmptyTexts()
        stateManager.commitState(photoState)
    }
    
    private func handleEmptyTexts() {
        guard !photoState.texts.isEmpty else {
            return
        }
        photoState.texts = photoState.texts.filter { !$0.text.isEmpty }
    }
}
