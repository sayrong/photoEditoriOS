//
//  PhotoEditorView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI
import Combine

struct PhotoEditorView: View {
    
    @ObservedObject var viewModel: PhotoEditorViewModel
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
    }

    @State private var isFilterControlEnabled = false
    @State private var isIntensityControlEnabled = false
    @State private var isToolPickIsVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            editControls()
            canvas()
            if isFilterControlEnabled {
                filterControlsView(isIntensityControlEnabled: isIntensityControlEnabled)
            }
            editModePanel()
        }
        .background(Asset.Colors.background.swiftUIColor)
        .onChange(of: viewModel.editMode) { oldValue, newValue in
            handleEditModeChange(oldValue, newValue)
        }
        .onChange(of: viewModel.photoState.filter) { _, newValue in
            handleFilterChange(newValue)
        }
    }
    
    private func handleEditModeChange(_ oldValue: EditMode?, _ newValue: EditMode?) {
        if newValue == .crop {
            viewModel.startCropping()
        }
        withAnimation {
            isFilterControlEnabled = newValue == .filters
        }
        if oldValue == .filters {
            viewModel.commitState()
        }
        
        isToolPickIsVisible = newValue == .markup
    }

    private func handleFilterChange(_ newValue: FilterType?) {
        withAnimation {
            isIntensityControlEnabled = {
                if case .sepia = newValue { return true }
                return false
            }()
        }
    }

    private func editControls() -> some View {
        HStack {
            switch viewModel.editMode {
            case .move:
                undoRedoViews()
                Spacer()
            case .crop, .filters:
                Spacer()
            case .markup:
                undoRedoViews()
                Spacer()
                closeMarkUpButton()
            case nil:
                undoRedoViews()
                Spacer()
            }
        }
        .padding(.trailing, 30)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(.black)
    }
    
    private func undoRedoViews() -> some View {
        HStack {
            SymbolButton("arrow.uturn.backward") {
                viewModel.undo()
            }.disabled(!viewModel.canUndo())
            
            SymbolButton("arrow.uturn.forward") {
                viewModel.redo()
            }.disabled(!viewModel.canRedo())
        }
        .padding(.leading)
    }
    
    private func closeMarkUpButton() -> some View {
        SymbolButton("xmark") {
            viewModel.editMode = nil
        }
    }
    
    private func canvas() -> some View {
        ZStack {
            MovableImage(image: viewModel.currentImage(),
                         position: $viewModel.photoState.position,
                         currentScale: $viewModel.photoState.scale,
                         rotationAngle: $viewModel.photoState.rotation,
                         commitState: viewModel.commitState)
            .disabled(viewModel.editMode != .move)
            
            DrawingCanvasView(toolPickerVisible: $isToolPickIsVisible,
                              drawing: $viewModel.photoState.drawning,
                              commitState: viewModel.commitState)
            .allowsHitTesting(viewModel.editMode == .markup)
        }
        .clipped()
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func editModePanel() -> some View {
        HStack(spacing: 10) {
            ForEach(EditMode.allCases, id: \.self) { mode in
                Button {
                    viewModel.editMode = viewModel.editMode == mode ? nil : mode
                } label: {
                    Image(systemName: mode.iconName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(viewModel.editMode == mode ? Color.blue : .white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.black)
    }

    private func filterControlsView(isIntensityControlEnabled: Bool) -> some View {
        VStack(spacing: 0) {
            if isIntensityControlEnabled {
                IntensitySlider(filter: $viewModel.photoState.filter)
            }
            filterTypes()
        }
    }
    
    private func filterTypes() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                Button {
                    viewModel.photoState.filter = nil
                } label: {
                    Text("Orig")
                }
                ForEach(FilterType.allCases, id: \.self) { type in
                    Button {
                        viewModel.photoState.filter = type
                    } label: {
                        Text(type.displayName)
                    }
                }
            }
            .frame(height: 40)
        }
        .scaledToFit()
        .frame(maxWidth: .infinity)
        .background(.black)
    }
}

#Preview {
    PhotoEditorView(viewModel: PhotoEditorViewModel(originalImage: UIImage(named: "gotta.JPG")!, delegate: nil))
}
