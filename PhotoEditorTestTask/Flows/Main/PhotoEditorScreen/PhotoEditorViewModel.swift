//
//  PhotoEditorViewModel.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

import SwiftUI
import PencilKit

protocol PhotoEditorCoordinatorDelegate: AnyObject {
    func presentCropper(with image: UIImage, onComplete: @escaping (CropInfo) -> Void)
    func logoutDidFail(with message: AlertMessage)
}

final class PhotoEditorViewModel: ObservableObject {
    
    private weak var coordinator: PhotoEditorCoordinatorDelegate?
    private var stateManager: IPhotoEditStateManager
    private var imageService: IImageEditingService
    private var exportService: IImageExportService
    private var authService: IAuthService
    
    private var sourceImage: UIImage
    var canvasView: PKCanvasView
    var canvasSize: CGSize = .zero
    
    @Published var editMode: EditMode? {
        didSet {
            onEditModeChanged(oldValue, editMode)
        }
    }
    @Published var currentPhotoState: PhotoEditState {
        didSet {
            onPhotoStateChanged(oldValue, currentPhotoState)
        }
    }
    @Published var activeTextId: UUID?
    @Published var processedImage: UIImage
    
    init(originalImage: UIImage, delegate: PhotoEditorCoordinatorDelegate?,
         stateManager: IPhotoEditStateManager, imageService: IImageEditingService,
         exportService: IImageExportService, authService: IAuthService) {
        self.sourceImage = originalImage
        self.coordinator = delegate
        self.stateManager = stateManager
        self.imageService = imageService
        self.exportService = exportService
        self.authService = authService
        self.currentPhotoState = stateManager.current
        self.canvasView = .init()
        self.processedImage = sourceImage
    }
    
    private func onEditModeChanged(_ oldValue: EditMode?, _ newValue: EditMode?) {
        if newValue == .crop {
            presentCropper()
        }
        if oldValue == .filters {
            commitState()
        }
    }

    private func onPhotoStateChanged(_ oldValue: PhotoEditState, _ newValue: PhotoEditState) {
        // Only update image if crop or filter changed
        if currentPhotoState.crop != oldValue.crop ||
            currentPhotoState.filter != oldValue.filter {
            Task { [weak self] in
                await self?.updateProcessedImage()
            }
        }
    }
    
    private func presentCropper() {
        coordinator?.presentCropper(with: sourceImage,
                                 onComplete: { [weak self] result in
            guard let self = self else { return }
            self.currentPhotoState.crop = result
            self.stateManager.commitState(self.currentPhotoState)
            self.editMode = nil
        })
    }

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
        if let id = activeTextId, let text = currentPhotoState.texts.first(where: { $0.id == id }) {
            return text.color
        }
        return .white
    }
    
    private func updateSelectedTextColor(_ newColor: Color) {
        if let id = activeTextId, let index = currentPhotoState.texts.firstIndex(where: { $0.id == id }) {
            currentPhotoState.texts[index].color = newColor
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
        currentPhotoState.texts.append(text)
        activeTextId = text.id
    }
    
    func deselectText() {
        if activeTextId != nil {
            activeTextId = nil
        }
    }
    
    @MainActor
    func updateProcessedImage() async {
        do {
            let image = try await imageService.processImage(image: sourceImage, editState: currentPhotoState)
            self.processedImage = image
        } catch {
            assertionFailure("Failed to process image: \(error)")
        }
    }
    
    func canUndo() -> Bool {
        stateManager.canUndo()
    }
    
    func canRedo() -> Bool {
        stateManager.canRedo()
    }
    
    func undo() {
        stateManager.undo()
        currentPhotoState = stateManager.current
    }
    
    func redo() {
        stateManager.redo()
        currentPhotoState = stateManager.current
    }
    
    func commitState() {
        removeEmptyTexts()
        stateManager.commitState(currentPhotoState)
    }
    
    private func removeEmptyTexts() {
        guard !currentPhotoState.texts.isEmpty else {
            return
        }
        currentPhotoState.texts = currentPhotoState.texts.filter { !$0.text.isEmpty }
    }
    
    func exportCanvas() -> UIImage {
        exportService.exportCanvas(canvasSize: canvasSize,
                                   canvasView: canvasView,
                                   image: processedImage,
                                   photoState: currentPhotoState)
    }
    
    func logoutDidTap() {
        Task { [weak self] in
            guard let self else { return }
            
            let result = await authService.logout()
            
            await MainActor.run {
                switch result {
                case .success:
                    break
                case .failure(let authError):
                    let error = AlertMessage(title: L10n.error, message: authError.userMessage)
                    self.coordinator?.logoutDidFail(with: error)
                }
            }
        }
    }
}
