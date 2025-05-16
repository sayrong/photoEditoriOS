//
//  PhotoEditorView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI
import Combine
import PencilKit

struct PhotoEditorView: View {
    
    @ObservedObject var viewModel: PhotoEditorViewModel
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
    }

    @State private var isFilterControlEnabled = false
    @State private var isIntensityControlEnabled = false
    @State private var isToolPickerVisible: Bool = false
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            editControls()
            canvas()
                .readSize { newSize in
                    viewModel.canvasSize = newSize
                }
            if isFilterControlEnabled {
                filterControlsView(isIntensityControlEnabled: isIntensityControlEnabled)
            }
            editModePanel()
        }
        .background(Asset.Colors.background.swiftUIColor)
        .onChange(of: viewModel.editMode) { oldValue, newValue in
            handleEditModeChange(oldValue, newValue)
        }
        .onChange(of: viewModel.currentPhotoState.filter) { _, newValue in
            handleFilterChange(newValue)
        }
        .sheet(isPresented: $showShareSheet) {
            let image = viewModel.exportCanvas()
            ShareSheet(activityItems: [image])
        }
    }
    
    private func handleEditModeChange(_ oldValue: EditMode?, _ newValue: EditMode?) {
        withAnimation {
            isFilterControlEnabled = newValue == .filters
        }
        isToolPickerVisible = newValue == .markup
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
            SymbolButton("square.and.arrow.up") {
                showShareSheet.toggle()
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
            
            SymbolButton("textformat.size.larger") {
                viewModel.addText()
            }
            
            ColorPicker("", selection: viewModel.colorBinding())
                .labelsHidden()
                .frame(width: 0, height: 0)
                .opacity(viewModel.activeTextId != nil ? 1 : 0)
                .animation(.easeInOut, value: viewModel.activeTextId)
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
            MovableImage(image: viewModel.processedImage,
                         position: $viewModel.currentPhotoState.position,
                         currentScale: $viewModel.currentPhotoState.scale,
                         rotationAngle: $viewModel.currentPhotoState.rotation,
                         commitState: viewModel.commitState)
            .disabled(viewModel.editMode != .move)
            
            DrawingCanvasView(canvasView: $viewModel.canvasView, toolPickerVisible: $isToolPickerVisible,
                              drawing: $viewModel.currentPhotoState.drawning,
                              commitState: viewModel.commitState)
            .allowsHitTesting(viewModel.editMode == .markup)
            
            ForEach($viewModel.currentPhotoState.texts) { $text in
                TextOverlayView(text: $text,
                                selectedId: $viewModel.activeTextId,
                                commitState: viewModel.commitState)
                }
        }
        .clipped()
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            viewModel.deselectText()
        }
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
                IntensitySlider(filter: $viewModel.currentPhotoState.filter)
            }
            filterTypes()
        }
    }
    
    private func filterTypes() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                Button {
                    viewModel.currentPhotoState.filter = nil
                } label: {
                    Text("Orig")
                }
                ForEach(FilterType.allCases, id: \.self) { type in
                    Button {
                        viewModel.currentPhotoState.filter = type
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
    PhotoEditorView(viewModel: .preview())
}
