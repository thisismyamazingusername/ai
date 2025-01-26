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
            Layer(numNeurons: 64, inputSize: 200, activationFunc: sigmoid),
            // trying to add layer lets see if it works wo dim change
            Layer(numNeurons: 32, inputSize: 64, activationFunc: sigmoid),
            Layer(numNeurons: 6, inputSize: 32, activationFunc: sigmoid)
        ]
    }

    func predict(input: [CGPoint]) -> (prediction: String, confidence: Double) {
        let flattenedInput = input.flatMap { [$0.x, $0.y] }.toDouble()
        let output = layers.reduce(flattenedInput) { $1.forward(inputs: $0) }
        let expOutput = output.map { exp($0) }
        let sumExp = expOutput.reduce(0, +)
        let probabilities = expOutput.map { $0 / sumExp }
        
        // printing all probabilities
        for (index, prob) in probabilities.enumerated() {
            print("Emoji \(EmojiData.all[index].id): \(prob)")
        }
        
        let maxIndex = probabilities.firstIndex(of: probabilities.max()!)!
        let confidence = probabilities[maxIndex]
        
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
                error = layer.backward(error: error, learningRate: 0.1)
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
