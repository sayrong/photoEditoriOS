//
//  PhotoEditStateManager.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 13.05.2025.
//

import SwiftUI

protocol IPhotoEditStateManager {
    var current: PhotoEditState { get }
    func commitState(_ state: PhotoEditState)
    func canUndo() -> Bool
    func undo()
    func canRedo() -> Bool
    func redo()
}

final class PhotoEditStateManager: IPhotoEditStateManager {
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
        guard current != state else { return }
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
