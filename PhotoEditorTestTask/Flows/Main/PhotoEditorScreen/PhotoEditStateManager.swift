//
//  PhotoEditStateManager.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

import SwiftUI

struct CropInfo: Equatable {
    var mode: CropMode
    var rect: CGRect
}

struct PhotoEditState: Equatable {
    var position: CGSize = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    var crop: CropInfo?
}

final class PhotoEditStateManager {
    private(set) var states: [PhotoEditState] = [PhotoEditState()]
    private var redoStack: [PhotoEditState] = []
    private let maxStates = 100

    var current: PhotoEditState {
        get { states.last ?? PhotoEditState() }
        set {
            if states.isEmpty {
                states.append(newValue)
            } else {
                states[states.count - 1] = newValue
            }
        }
    }

    func commitState(_ state: PhotoEditState) {
        redoStack.removeAll()
        states.append(state)
        
        if states.count > maxStates {
            states.removeFirst(states.count - maxStates / 2)
        }
    }
    
    func canUndo() -> Bool {
        states.count > 1
    }

    func undo() {
        guard states.count > 1 else { return }
        let last = states.removeLast()
        redoStack.append(last)
    }

    func canRedo() -> Bool {
        !redoStack.isEmpty
    }
    
    func redo() {
        guard let next = redoStack.popLast() else { return }
        states.append(next)
    }

    func reset() {
        states = [PhotoEditState()]
        redoStack.removeAll()
    }
}
