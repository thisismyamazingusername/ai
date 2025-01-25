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
    private var drawingPoints: [CGPoint] = []
    
    private var currentPoints: [CGPoint] = []
    var allPoints: [CGPoint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .lightGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            
            currentPoints.append(location)
            
            allPoints.append(location)
            onDrawingUpdate?(currentPoints)
            setNeedsDisplay()
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            onDrawingEnd?(currentPoints)
            
            allPoints.append(contentsOf: currentPoints)
            
            currentPoints.removeAll()
        }

        override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else { return }

            context.setStrokeColor(UIColor.blue.cgColor)
            context.setLineWidth(5.0)
            context.setLineJoin(.round)
            context.setLineCap(.round)

            for (index, point) in allPoints.enumerated() {
                if index > 0 {
                    let previousPoint = allPoints[index - 1]
                    context.move(to: previousPoint)
                    context.addLine(to: point)
                }
            }
            context.strokePath()
        }
}
