//
//  MovableImage.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 02.05.2025.
//

import SwiftUI

final class MovableImageViewModel: ObservableObject {
    
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    @Published var position: CGSize = .zero
    @Published var currentScale: CGFloat = 1.0
    @Published var rotationAngle: Angle = .zero
    
    func reset() {
        withAnimation {
            position = .zero
            currentScale = 1.0
            rotationAngle = .zero
        }
    }
}

struct MovableImage: View {
    
    @ObservedObject var viewModel: MovableImageViewModel
    
    @GestureState var dragOffset: CGSize = .zero
    @GestureState var gestureScale: CGFloat = 1.0
    @GestureState var gestureRotation: Angle = .zero
    
    var body: some View {
        Image(uiImage: viewModel.image)
            .resizable()
            .scaledToFit()
            .scaleEffect(viewModel.currentScale * gestureScale)
            .rotationEffect(viewModel.rotationAngle + gestureRotation)
            .offset(x: viewModel.position.width + dragOffset.width,
                    y: viewModel.position.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        viewModel.position.width += value.translation.width
                        viewModel.position.height += value.translation.height
                    }
                    .simultaneously(
                        with: MagnifyGesture()
                            .updating($gestureScale) { value, state, _ in
                                state = value.magnification
                            }
                            .onEnded { value in
                                viewModel.currentScale *= value.magnification
                            }
                    )
                    .simultaneously(with:
                        RotateGesture()
                        .updating($gestureRotation) {  value, state, _ in
                            state = value.rotation
                        }
                        .onEnded { value in
                            viewModel.rotationAngle += value.rotation
                        }
                    )
            )
    }
}

struct MovableImageControls: View {
    
    @ObservedObject var viewModel: MovableImageViewModel
    
    var body: some View {
        Button {
            viewModel.reset()
        } label: {
            Image(systemName: "arrow.circlepath")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(8)
                .foregroundStyle(.white)
        }
    }
}
