//
//  DrawingCanvasView.swift
//  kwkxdcc
//
//  Created by sd on 1/21/25.
//

import Foundation
import SwiftUI

struct DrawingCanvasView: UIViewRepresentable {
    var onDrawingEnd: (([CGPoint]) -> Void)?

    func makeUIView(context: Context) -> DrawingCanvas {
        let drawingCanvas = DrawingCanvas(frame: .zero)
        drawingCanvas.onDrawingEnd = onDrawingEnd
        return drawingCanvas
    }

    func updateUIView(_ uiView: DrawingCanvas, context: Context) {
        uiView.setNeedsDisplay()
    }
}
