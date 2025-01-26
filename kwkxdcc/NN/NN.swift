//
//  NN.swift
//  kwkxdcc
//
//  Created by sd on 1/13/25.
//

import Foundation
import UIKit
import Accelerate
import Combine

class NeuralNetwork: ObservableObject {
    var layers: [Layer]

    init() {
        layers = [
            Layer(numNeurons: 32, inputSize: 200, activationFunc: sigmoid),
            Layer(numNeurons: 6, inputSize: 32, activationFunc: sigmoid)
        ]
    }

    func predict(input: [CGPoint]) -> (prediction: String, confidence: Double) {
        let flattenedInput = input.flatMap { [$0.x, $0.y] }.toDouble()
        let output = layers.reduce(flattenedInput) { $1.forward(inputs: $0) }
        let maxValue = output.max() ?? 0
        let maxIndex = output.firstIndex(of: maxValue) ?? 0
        let sortedOutput = output.sorted(by: >)
        let confidence = sortedOutput[0] - (sortedOutput.count > 1 ? sortedOutput[1] : 0)
        
        return (EmojiData.all[maxIndex].id, confidence)
    }


    func teach(input: [CGPoint], label: String) {
            // flattened/converted -> double??
            var flattenedInput = input.flatMap { [$0.x, $0.y] }.toDouble()

            // pad w zeros if < 200 elms
            while flattenedInput.count < 200 {
                flattenedInput.append(0)
            }
            
            // shorten if > 200 elms
            if flattenedInput.count > 200 {
                flattenedInput = Array(flattenedInput.prefix(200))
            }
        
            
            var activations = [flattenedInput]
            var outputs = flattenedInput
            for layer in layers {
                outputs = layer.forward(inputs: outputs)
                activations.append(outputs)
            }

            let targetIndex = EmojiData.all.firstIndex { $0.id == label } ?? 0
            var target = [Double](repeating: 0.0, count: outputs.count)
            target[targetIndex] = 1.0

            var error = zip(outputs, target).map { $1 - $0 }
            for layer in layers.reversed() {
                error = layer.backward(error: error, learningRate: 0.01)
            }
        }
    
    func canvasToGrid(points: [CGPoint], width: CGFloat, height: CGFloat) -> [[Bool]] {
        let gridSize = 10  // 10x10 grid
        var grid: [[Bool]] = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)

        for point in points {
            let rowIndex = Int(point.y / (height / CGFloat(gridSize)))
            let colIndex = Int(point.x / (width / CGFloat(gridSize)))

            if rowIndex >= 0 && rowIndex < gridSize && colIndex >= 0 && colIndex < gridSize {
                grid[rowIndex][colIndex] = true
            }
        }

        return grid
    }

}


extension Array where Element == CGFloat {
    func toDouble() -> [Double] {
        return self.map { Double($0) }
    }
}
