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
    private var points: [CGPoint] = []
    private var pixelGrid: [[Bool]] = []
    // 10x10 grid maybe 75+?
    private let gridSize = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        pixelGrid = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
        self.backgroundColor = .white
        // bg white?
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func convertToGridCoordinates(_ point: CGPoint) -> (Int, Int)? {
        let width = self.bounds.width
        let height = self.bounds.height

        let pixelWidth = width / CGFloat(gridSize)
        let pixelHeight = height / CGFloat(gridSize)

        let column = Int(point.x / pixelWidth)
        let row = Int(point.y / pixelHeight)

        if row >= 0 && row < gridSize && column >= 0 && column < gridSize {
            return (row, column)
        }

        return nil
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        points.append(location)
        if let (row, column) = convertToGridCoordinates(location) {
            pixelGrid[row][column] = true
        }
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onDrawingEnd?(points)
        points = []
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let width = self.bounds.width
        let height = self.bounds.height
        let pixelWidth = width / CGFloat(gridSize)
        let pixelHeight = height / CGFloat(gridSize)

        
        context.setFillColor(UIColor.blue.cgColor)
        for row in 0..<gridSize {
            for column in 0..<gridSize {
                if pixelGrid[row][column] {
                    context.fill(CGRect(x: CGFloat(column) * pixelWidth,
                                        y: CGFloat(row) * pixelHeight,
                                        width: pixelWidth,
                                        height: pixelHeight))
                }
            }
        }
    }
}
