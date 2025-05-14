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
    
    @State var sliderValue: CGFloat = 0
    @State private var isFilterControlEnabled = false
    @State private var isIntensityControlEnabled = false
    @State private var selectedFilter: FilterType?
    
    @State private var toolPickIsVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            editControls()
            canvas()
            if isFilterControlEnabled {
                FilterControlsView(isIntensityControlEnabled: isIntensityControlEnabled)
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
        
        toolPickIsVisible = newValue == .markup
    }

    private func handleFilterChange(_ newValue: FilterType?) {
        withAnimation {
            isIntensityControlEnabled = {
                if case .sepia = newValue { return true }
                return false
            }()
        }
    }

    @ViewBuilder
    func undoRedoViews() -> some View {
        HStack {
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 12)
            }
            .buttonStyle(CustomButtonStyle())
            .disabled(!viewModel.canUndo())
            
            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 12)
            }
            .buttonStyle(CustomButtonStyle())
            .disabled(!viewModel.canRedo())
        }
        .padding(.leading)
    }
    
    func editControls() -> some View {
        HStack {
            switch viewModel.editMode {
            case .move:
                undoRedoViews()
                Spacer()
            case .crop:
                Spacer()
            case .filters:
                Spacer()
            case .markup:
                undoRedoViews()
                Spacer()
                Button {
                    viewModel.editMode = nil
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 12)
                }
                .buttonStyle(CustomButtonStyle())
                
            case nil:
                undoRedoViews()
                Spacer()
            }
        }
        .padding(.trailing, 30)
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(.black)
    }
    
    func canvas() -> some View {
        ZStack {
            Color.clear //
            MovableImage(image: viewModel.currentImage(),
                         position: $viewModel.photoState.position,
                         currentScale: $viewModel.photoState.scale,
                         rotationAngle: $viewModel.photoState.rotation,
                         commitState: viewModel.commitState)
            .disabled(viewModel.editMode != .move)
            
            DrawingCanvasView(toolPickerVisible: $toolPickIsVisible,
                             drawing: $viewModel.photoState.drawning,
                             commitState: viewModel.commitState)
                .disabled(viewModel.editMode != .markup)
        }
        .clipped() // обрезает всё, что выходит за пределы
        .contentShape(Rectangle()) // чтобы жесты работали только внутри
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func editModePanel() -> some View {
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

    @ViewBuilder
    private func FilterControlsView(isIntensityControlEnabled: Bool) -> some View {
        VStack(spacing: 0) {
            if isIntensityControlEnabled {
                filterIntensity()
            }
            filterTypes()
        }
    }
    
    func filterIntensity() -> some View {
        Slider(value: $sliderValue, in: 0.0...1.0, onEditingChanged: { editing in
            if !editing {
                viewModel.photoState.filter = .sepia(sliderValue)
            }
        })
        .onAppear {
            if case .sepia(let value) = viewModel.photoState.filter {
                sliderValue = value
            }
        }
    }
    
    func filterTypes() -> some View {
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
