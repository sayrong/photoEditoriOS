//
//  MovableImage.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 02.05.2025.
//

import SwiftUI

final class MovableImageViewModel: ObservableObject {
    
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
    
    let image: UIImage
    @ObservedObject var viewModel: MovableImageViewModel
    
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureRotation: Angle = .zero
    
    let maxScale: CGFloat = 2.0
    let minScale: CGFloat = 0.5
    
    var body: some View {
        Image(uiImage: image)
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
                                state = min(max(value.magnification, minScale), maxScale)
                            }
                            .onEnded { value in
                                let newValue = viewModel.currentScale * value.magnification
                                guard newValue > minScale && newValue < maxScale else { return }
                                viewModel.currentScale = newValue
                            }
                    )
                    .simultaneously(with:
                        RotateGesture()
                        .updating($gestureRotation) {  value, state, _ in
                            let rotation = value.rotation
                            if rotation.radians.isFinite {
                                state = rotation
                            }
                        }
                        .onEnded { value in
                            let rotation = value.rotation
                            if rotation.radians.isFinite {
                                viewModel.rotationAngle += rotation
                            } else {
                                print("Invalid gesture rotation in .onEnded: \(rotation)")
                            }
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
