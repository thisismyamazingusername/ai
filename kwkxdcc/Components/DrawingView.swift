//
//  DrawingView.swift
//  kwkxdcc
//
//  Created by sd on 1/21/25.
//

import Foundation
import SwiftUI

class DrawingCanvas: UIView {
    var onDrawingEnd: (([CGPoint]) -> Void)?
    var onDrawingUpdate: (([CGPoint]) -> Void)?
    private var currentStroke: [CGPoint] = []
    private var allStrokes: [[CGPoint]] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentStroke.removeAll()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        currentStroke.append(location)
        onDrawingUpdate?(currentStroke)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        allStrokes.append(currentStroke)
        onDrawingEnd?(currentStroke)
        currentStroke.removeAll()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(5.0)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        
        for stroke in allStrokes + [currentStroke] {
            for (index, point) in stroke.enumerated() {
                if index == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
        }
        context.strokePath()
    }
    
    func clearCanvas() {
        currentStroke.removeAll()
        allStrokes.removeAll()
        setNeedsDisplay()
    }
}
