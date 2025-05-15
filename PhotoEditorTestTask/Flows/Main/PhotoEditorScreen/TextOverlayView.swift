//
//  TextOverlayView.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 15.05.2025.
//

import SwiftUI

struct TextOverlayView: View {
    @Binding var text: PhotoText
    @Binding var selectedId: UUID?
    
    @State var isEditing: Bool = true
    @State var color: Color = .white
    
    var commitState: (() -> Void)?
    
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureRotation: Angle = .zero
    
    @FocusState private var isTextFieldFocused: Bool
    
    let maxScale: CGFloat = 3.0
    let minScale: CGFloat = 0.5
    
    @State var showColorPicker: Bool = false
    
    var body: some View {
        Group {
            if isEditing {
                TextField("", text: $text.text)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .padding(12)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(6)
                    .fixedSize()
                    .focused($isTextFieldFocused)
            } else {
                Text(text.text)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
        }
        .contentShape(Rectangle())
        .scaleEffect(text.scale * gestureScale)
        .rotationEffect(text.rotation + gestureRotation)
        .offset(x: text.offset.width + dragOffset.width,
                y: text.offset.height + dragOffset.height)
        .gesture(gesture)
        .onTapGesture {
            isEditing = true
        }
        .onAppear {
            syncColorWithModel()
            if isEditing {
                isTextFieldFocused = true
                selectedId = text.id
                sendColorToPicker()
            }
        }
        .onChange(of: selectedId) { _, newValue in
            // если выбрали другой текст - выйти из режима редактирования
            isEditing = (newValue == text.id)
        }
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                // включили редактирование — зарегистрировать себя как выбранного
                selectedId = text.id
                sendColorToPicker()
            } else {
                text.color = color
                commitState?()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .colorDidChange)) { notification in
            guard isEditing else { return }
            if let userInfo = notification.userInfo,
               let uiColor = userInfo["color"] as? UIColor {
                color = Color(uiColor)
            }
        }
    }
    
    private func sendColorToPicker() {
        NotificationCenter.default.post(
            name: .currentActiveElementColor,
            object: nil,
            userInfo: ["color": UIColor(color)]
        )
    }
    
    private func syncColorWithModel() {
        if color != text.color {
            color = text.color
        }
    }
    
    private var gesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                text.offset.width += value.translation.width
                text.offset.height += value.translation.height
            }
            .simultaneously(with: MagnifyGesture()
                .updating($gestureScale) { value, state, _ in
                    let newValue = text.scale * value.magnification
                    if newValue > minScale && newValue < maxScale {
                        state = value.magnification
                    }
                }
                .onEnded { value in
                    let newValue = text.scale * value.magnification
                    text.scale = min(max(newValue, minScale), maxScale)
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
                        text.rotation += rotation
                    } else {
                        print("Invalid gesture rotation in .onEnded: \(rotation)")
                    }
                }
            )
    }
}
