//
//  PhotoEditorView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 29.04.2025.
//

import SwiftUI

struct PhotoEditorView: View {
    
    @ObservedObject var viewModel: PhotoEditorViewModel
    
    init(viewModel: PhotoEditorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            editControls()
            canvas()
            editModePanel()
        }
        .background(Asset.Colors.background.swiftUIColor)
        .onChange(of: viewModel.editMode) { _, newValue in
            if newValue == .crop {
                viewModel.startCropping()
            }
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
            undoRedoViews()
            Spacer()
            switch viewModel.editMode {
            case .move:
                Spacer()
            case .crop:
                Spacer()
            case .filters:
                Spacer()
            case .markup:
                Spacer()
            case nil:
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
}

#Preview {
    PhotoEditorView(viewModel: PhotoEditorViewModel(originalImage: UIImage(named: "gotta.JPG")!, delegate: nil))
}
