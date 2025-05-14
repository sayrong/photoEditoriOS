//
//  MovableImage.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 02.05.2025.
//

import SwiftUI

struct MovableImage: View {
    
    let image: UIImage
    
    @Binding var position: CGSize
    @Binding var currentScale: CGFloat
    @Binding var rotationAngle: Angle
    
    var commitState: (() -> Void)?
    
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureRotation: Angle = .zero
    
    let maxScale: CGFloat = 2.0
    let minScale: CGFloat = 0.5
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .scaleEffect(currentScale * gestureScale)
            .rotationEffect(rotationAngle + gestureRotation)
            .offset(x: position.width + dragOffset.width,
                    y: position.height + dragOffset.height)
            .gesture(gesture)
    }
    
    private var gesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                position.width += value.translation.width
                position.height += value.translation.height
                commitState?()
            }
            .simultaneously(with: MagnifyGesture()
                .updating($gestureScale) { value, state, _ in
                    let newValue = currentScale * value.magnification
                    if newValue > minScale && newValue < maxScale {
                        state = value.magnification
                    }
                }
                .onEnded { value in
                    let newValue = currentScale * value.magnification
                    currentScale = min(max(newValue, minScale), maxScale)
                    commitState?()
                }
            )
            .simultaneously(with: RotateGesture()
                .updating($gestureRotation) {  value, state, _ in
                    let rotation = value.rotation
                    if rotation.radians.isFinite {
                        state = rotation
                    }
                }
                .onEnded { value in
                    let rotation = value.rotation
                    if rotation.radians.isFinite {
                        rotationAngle += rotation
                        commitState?()
                    } else {
                        print("Invalid gesture rotation in .onEnded: \(rotation)")
                    }
                }
            )
    }
}
