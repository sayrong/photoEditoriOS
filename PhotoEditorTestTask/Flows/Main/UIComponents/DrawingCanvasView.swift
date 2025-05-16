//
//  DrawingCompoment.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 02.05.2025.
//

import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    
    @Binding var canvasView: PKCanvasView
    @Binding var toolPickerVisible: Bool
    @Binding var drawing: PKDrawing?
    var commitState: (() -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        setupCanvasView(context)
        setupToolPicker(context)
        return canvasView
    }
    
    private func setupCanvasView(_ context: Context) {
        canvasView.delegate = context.coordinator
        canvasView.drawing = drawing ?? PKDrawing()
        canvasView.drawingPolicy = .anyInput
        canvasView.contentSize = CGSize(width: 2000, height: 1000)
        canvasView.maximumZoomScale = 5.0
        canvasView.minimumZoomScale = 0.1
        canvasView.backgroundColor = UIColor.clear
        canvasView.contentInset = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)
        canvasView.becomeFirstResponder()
    }
    
    private func setupToolPicker(_ context: Context) {
        let toolPicker = context.coordinator.toolPicker
        
        toolPicker.setVisible(toolPickerVisible, forFirstResponder: canvasView)
        toolPicker.showsDrawingPolicyControls = true
        toolPicker.addObserver(canvasView)
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        updateToolPicker(context: context)
        updateDrawingIfNeeded(uiView, context: context)
    }
    
    private func updateDrawingIfNeeded(_ uiView: PKCanvasView, context: Context) {
        // Clear if drawing is nil
        guard let drawing else {
            if !uiView.drawing.bounds.isEmpty {
                uiView.drawing = PKDrawing()
            }
            return
        }
        if uiView.drawing != drawing {
            uiView.drawing = drawing
            
        }
    }
    
    private func updateToolPicker(context: Context) {
        let toolPicker = context.coordinator.toolPicker
        
        if toolPickerVisible != toolPicker.isVisible {
            toolPicker.setVisible(toolPickerVisible, forFirstResponder: canvasView)
        }
    }
}

extension DrawingCanvasView {
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
        let toolPicker: PKToolPicker
        
        var parent: DrawingCanvasView

        init(parent: DrawingCanvasView) {
            toolPicker = PKToolPicker()
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            commitStateIfNeeded(canvasView)
        }
        
        private func commitStateIfNeeded(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async {
                let newDrawing = canvasView.drawing

                if newDrawing.bounds.isEmpty {
                    if self.parent.drawing != nil {
                        self.parent.drawing = nil
                        self.parent.commitState?()
                    }
                } else if self.parent.drawing != newDrawing {
                    self.parent.drawing = newDrawing
                    self.parent.commitState?()
                }
            }
        }
    }
}
