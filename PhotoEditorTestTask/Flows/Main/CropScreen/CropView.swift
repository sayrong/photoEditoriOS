//
//  CropView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 03.05.2025.
//

import SwiftUI

struct CropView: View {
    
    @ObservedObject private var viewModel: CropViewModel
    
    init(viewModel: CropViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            cropModePanel()
            cropView()
            controlButtons()
        }
        .background(.black)
    }
    
    private func cropModePanel() -> some View {
        HStack {
            ForEach(CropMode.allCases, id: \.self) { mode in
                Button {
                    viewModel.cropMode = mode
                } label: {
                    Image(systemName: mode.iconName())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(viewModel.cropMode == mode ? Color.blue : .white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(.black)
    }
    
    private func controlButtons() -> some View {
        HStack {
            Button("Cancel") {
                viewModel.cancel()
            }
            Spacer()
            Button("Save") {
                viewModel.defineCrop()
            }
        }
        .padding(.horizontal, 20)
        .padding()
        .frame(maxWidth: .infinity)
        .background(.black)
    }
    
    private func cropView() -> some View {
        VStack {
            ZStack {
                Image(uiImage: viewModel.image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .opacity(0.5)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    viewModel.imageViewSize = geometry.size
                                }
                        }
                    )
                
                Image(uiImage: viewModel.image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(viewModel.scale)
                    .offset(viewModel.offset)
                    .mask(
                        viewModel.cropMode.shape()
                            .frame(width: viewModel.cropMode.size().width,
                                   height: viewModel.cropMode.size().height)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(dragGesture())
            .gesture(scaleGesture())
        }
        .clipped()
    }
    
    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.processDragValue(value.translation)
            }
            .onEnded { _ in
                viewModel.dragDidEnd()
            }
    }
    
    private func scaleGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                viewModel.processScaleValue(value.magnitude)
            }
            .onEnded { _ in
                viewModel.scaleDidEnd()
            }
    }
}

#Preview {
    CropView(viewModel: CropViewModel(image: UIImage(named: "gotta.JPG")!, onCrop: nil, onCancel: nil))
}
