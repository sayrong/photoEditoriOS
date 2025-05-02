//
//  DrawingCompoment.swift
//  PhotoEditorTestTask
//
//  Created by DmitrySK on 02.05.2025.
//

import SwiftUI
import PencilKit

struct DrawingCompoment: UIViewRepresentable {
    
    @State var canvasView: PKCanvasView = PKCanvasView()
    @State var toolPicker = PKToolPicker()
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.contentSize = CGSize(width: 2000, height: 1000)
        canvasView.maximumZoomScale = 5.0
        canvasView.minimumZoomScale = 0.1
        canvasView.backgroundColor = UIColor.clear
        canvasView.contentInset = UIEdgeInsets(top: 500, left: 500, bottom: 500, right: 500)
        canvasView.becomeFirstResponder()
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}
