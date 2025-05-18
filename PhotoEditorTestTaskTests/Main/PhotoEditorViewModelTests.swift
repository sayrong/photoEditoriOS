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
    var mockAuthService: MockAuthService!
    var mockCoordinator: MockCoordinator!
    var testImage: UIImage!

    override func setUp() {
        super.setUp()
        mockStateManager = MockStateManager()
        mockImageService = MockImageEditingService()
        mockExportService = MockImageExportService()
        mockCoordinator = MockCoordinator()
        mockAuthService = MockAuthService()
        testImage = UIImage() // Use a real or dummy image
        viewModel = PhotoEditorViewModel(
            originalImage: testImage,
            delegate: mockCoordinator,
            stateManager: mockStateManager,
            imageService: mockImageService,
            exportService: mockExportService,
            authService: mockAuthService
        )
    }

    func testAddTextAppendsTextAndSelectsIt() {
        // Given (Arrange)
        let initialTextCount = viewModel.currentPhotoState.texts.count
        // When (Act)
        viewModel.addText()
        // Then (Assert)
        XCTAssertEqual(viewModel.currentPhotoState.texts.count, initialTextCount + 1, "Should add one text element")
        XCTAssertEqual(viewModel.activeTextId, viewModel.currentPhotoState.texts.first?.id, "Added text should be selected")
    }

    func testTappedOutsideTextDeselectsText() {
        // Given (Arrange)
        // When (Act)
        viewModel.addText()
        viewModel.deselectText()
        // Then (Assert)
        XCTAssertNil(viewModel.activeTextId)
    }

    func testUndoCallsStateManagerAndUpdatesState() {
        // Given
        mockStateManager.canUndoValue = true
        // When
        viewModel.undo()
        // Then
        XCTAssertTrue(mockStateManager.undoCalled)
        XCTAssertEqual(viewModel.currentPhotoState, mockStateManager.current)
    }

    func testEditModeChangeToCropCallsCoordinator() {
        // Given
        // When
        viewModel.editMode = .crop
        // Then
        XCTAssertTrue(mockCoordinator.presentCropperCalled)
    }

    func testCommitStateRemovesEmptyTexts() {
        // Given
        // When
        viewModel.currentPhotoState.texts = [PhotoText(text: "", offset: .zero, scale: 1, rotation: .zero, color: .white)]
        viewModel.commitState()
        // Then
        XCTAssertTrue(viewModel.currentPhotoState.texts.isEmpty)
        XCTAssertTrue(mockStateManager.commitStateCalled)
    }
    
    func testLogoutCalled() async {
        // Given
        let exp = expectation(description: "Logout")
        mockAuthService.didLogoutHandler = {
            exp.fulfill()
        }
        // When
        viewModel.logoutDidTap()
        // Then
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(mockAuthService.logoutCalled)
    }
    
    func testLogoutErrorShown() async {
        // Given
        mockAuthService.logoutResult = .failure(.networkError)
        let exp = expectation(description: "Logout")
        mockCoordinator.didLogoutFailHandler = { _ in
            exp.fulfill()
        }
        // When
        viewModel.logoutDidTap()
        // Then
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertTrue(mockAuthService.logoutCalled, "Logout should be called")
        XCTAssertTrue(mockCoordinator.didLogoutCalled, "Coordinator should be notified of logout failure")
    }

    func testRedoCallsStateManagerAndUpdatesState() {
        // Given
        mockStateManager.canRedoValue = true
        // When
        viewModel.redo()
        // Then
        XCTAssertTrue(mockStateManager.redoCalled)
        XCTAssertEqual(viewModel.currentPhotoState, mockStateManager.current)
    }

    func testAddTextWithDefaultProperties() {
        // Given
        // When
        viewModel.addText()
        // Then
        let addedText = viewModel.currentPhotoState.texts.first
        XCTAssertNotNil(addedText)
        XCTAssertEqual(addedText?.scale, 1.0)
        XCTAssertEqual(addedText?.text, "")
        XCTAssertEqual(addedText?.color, .white) // assuming white is default
    }

    func testMultipleTextElements() {
        // Given
        // When
        viewModel.addText()
        viewModel.addText()
        // Then
        XCTAssertEqual(viewModel.currentPhotoState.texts.count, 2)
    }
}
