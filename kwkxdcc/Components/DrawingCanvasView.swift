//
//  DrawingCanvasView.swift
//  kwkxdcc
//
//  Created by sd on 1/21/25.
//

import Foundation
import SwiftUI

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var drawing: [[CGPoint]]
    @Binding var currentEmojiIndex: Int
    @ObservedObject var model: NeuralNetwork
    
    func makeUIView(context: Context) -> DrawingCanvas {
        let canvas = DrawingCanvas()
        canvas.onDrawingEnd = { stroke in
            drawing.append(stroke)
        }
        return canvas
    }
    
    func updateUIView(_ uiView: DrawingCanvas, context: Context) {
        if drawing.isEmpty {
            uiView.clearCanvas()
        }
        uiView.setNeedsDisplay()
    }
}
