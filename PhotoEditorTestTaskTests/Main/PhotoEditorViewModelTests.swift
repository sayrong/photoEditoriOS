//
//  PhotoEditorViewModelTests.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 16.05.2025.
//
import XCTest
import SwiftUI
@testable import PhotoEditorTestTask

class PhotoEditorViewModelTests: XCTestCase {
    var viewModel: PhotoEditorViewModel!
    var mockStateManager: MockStateManager!
    var mockImageService: MockImageEditingService!
    var mockExportService: MockImageExportService!
    var mockCoordinator: MockCoordinator!
    var testImage: UIImage!

    override func setUp() {
        super.setUp()
        mockStateManager = MockStateManager()
        mockImageService = MockImageEditingService()
        mockExportService = MockImageExportService()
        mockCoordinator = MockCoordinator()
        testImage = UIImage() // Use a real or dummy image
        viewModel = PhotoEditorViewModel(
            originalImage: testImage,
            delegate: mockCoordinator,
            stateManager: mockStateManager,
            imageService: mockImageService,
            exportService: mockExportService
        )
    }

    func testAddTextAppendsTextAndSelectsIt() {
        viewModel.addText()
        XCTAssertEqual(viewModel.currentPhotoState.texts.count, 1)
        XCTAssertEqual(viewModel.activeTextId, viewModel.currentPhotoState.texts.first?.id)
    }

    func testTappedOutsideTextDeselectsText() {
        viewModel.addText()
        viewModel.deselectText()
        XCTAssertNil(viewModel.activeTextId)
    }

    func testUndoCallsStateManagerAndUpdatesState() {
        mockStateManager.canUndoValue = true
        viewModel.undo()
        XCTAssertTrue(mockStateManager.undoCalled)
        XCTAssertEqual(viewModel.currentPhotoState, mockStateManager.current)
    }

    func testEditModeChangeToCropCallsCoordinator() {
        viewModel.editMode = .crop
        XCTAssertTrue(mockCoordinator.presentCropperCalled)
    }

    func testCommitStateRemovesEmptyTexts() {
        viewModel.currentPhotoState.texts = [PhotoText(text: "", offset: .zero, scale: 1, rotation: .zero, color: .white)]
        viewModel.commitState()
        XCTAssertTrue(viewModel.currentPhotoState.texts.isEmpty)
        XCTAssertTrue(mockStateManager.commitStateCalled)
    }
}
