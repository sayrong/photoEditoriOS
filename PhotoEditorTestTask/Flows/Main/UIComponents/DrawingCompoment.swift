//
//  DrawingCompoment.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 02.05.2025.
//

import SwiftUI
import PencilKit

struct DrawingCompoment: UIViewRepresentable {
    
    @Binding var toolPickerVisible: Bool
    @Binding var drawing: PKDrawing?
    
    var commitState: (() -> Void)?
    
    @State var canvasView: PKCanvasView = PKCanvasView()
    @State var toolPicker = PKToolPicker()
    
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCompoment

        init(parent: DrawingCompoment) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async {
                let newDrawing = canvasView.drawing

                if newDrawing.bounds.isEmpty {
                    if self.parent.drawing != nil {
                        self.parent.drawing = nil
                        self.parent.commitState?()
                    }
                } else {
                    self.parent.drawing = newDrawing
                    self.parent.commitState?()
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.delegate = context.coordinator
        canvasView.drawing = drawing ?? PKDrawing()
        canvasView.drawingPolicy = .anyInput
        canvasView.contentSize = CGSize(width: 2000, height: 1000)
        canvasView.maximumZoomScale = 5.0
        canvasView.minimumZoomScale = 0.1
        canvasView.backgroundColor = UIColor.clear
        canvasView.contentInset = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)
        canvasView.becomeFirstResponder()
        
        toolPicker.setVisible(toolPickerVisible, forFirstResponder: canvasView)
        toolPicker.showsDrawingPolicyControls = true
        toolPicker.addObserver(canvasView)
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        toolPicker.setVisible(toolPickerVisible, forFirstResponder: canvasView)
        
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
}
