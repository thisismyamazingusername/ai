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
    var learningRate: Double =  0.01
    let learningRateDecay: Double = 0.99
//   exp w 0.005 - 0.05
    let l2RegularizationStrength: Double = 0.0001
//
    
    init() {
        layers = [
            Layer(numNeurons: 128, inputSize: 256, activationType: .relu),
            Layer(numNeurons: 64, inputSize: 128, activationType: .relu),
            Layer(numNeurons: 5, inputSize: 64, activationType: .softmax)
        ]
    }

    func predict(input: [CGPoint]) -> (prediction: String, confidence: Double) {
        let gridInput = canvasToGrid(points: input, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let flattenedInput = gridInput.flatMap { $0 }
        let output = layers.reduce(flattenedInput) { $1.forward(inputs: $0) }
        
        // nno NaN values
        guard !output.contains(where: { $0.isNaN }) else {
            print("x: NaN values in output")
            return ("Error", 0.0)
        }
        
//        let expOutput = output.map { exp($0) }
//        let sumExp = expOutput.reduce(0, +)
//        let probabilities = expOutput.map { $0 / sumExp }
        
        // printing all probabilities
        for (index, prob) in output.enumerated() {
            if index < EmojiData.all.count {
                print("Emoji \(EmojiData.all[index].id): \(prob)")
            } else {
                print("x: Output neuron \(index) has no corresponding emoji")
            }
        }

        
        guard let maxValue = output.max(), let maxIndex = output.firstIndex(of: maxValue) else {
             print("x: Unable to find maximum value in output")
             return ("Error", 0.0)
         }
        
        return (EmojiData.all[maxIndex].id, maxValue)
        
    }


    func teach(input: [CGPoint], label: String) {
        let gridInput = canvasToGrid(points: input, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let flattenedInput = gridInput.flatMap { $0 }
        var output = flattenedInput
        
//        while output.count < 256 {
//            output.append(0)
//        }
//        output = Array(output.prefix(256))
        
        var activations = [output]
        for layer in layers {
            output = layer.forward(inputs: output)
            activations.append(output)
        }
        
        let targetIndex = EmojiData.all.firstIndex { $0.id == label } ?? 0
        var target = [Double](repeating: 0.0, count: 5)
        target[targetIndex] = 1.0

        var error = crossEntropyDerivative(predicted: output, actual: target)
        
        for i in (0..<layers.count).reversed() {
            error = layers[i].backward(error: error, learningRate: learningRate, l2Strength: l2RegularizationStrength)
            if i > 0 {
                error = zip(error, layers[i-1].activationFuncDerivative(activations[i])).map(*)
            }
        }
        learningRate *= learningRateDecay
    }

         func normalize(_ input: [Double]) -> [Double] {
             let minVal = input.min() ?? 0
             let maxVal = input.max() ?? 1
             return input.map { ($0 - minVal) / (maxVal - minVal + 1e-8) }
         }
    
    func canvasToGrid(points: [CGPoint], width: CGFloat, height: CGFloat) -> [[Double]] {
        let gridSize = 16
        var grid = Array(repeating: Array(repeating: 0.0, count: gridSize), count: gridSize)

        for point in points {
            let rowIndex = Int(point.y / (height / CGFloat(gridSize)))
            let colIndex = Int(point.x / (width / CGFloat(gridSize)))

            if rowIndex >= 0 && rowIndex < gridSize && colIndex >= 0 && colIndex < gridSize {
                grid[rowIndex][colIndex] = 1.0
                
                // focus on the drawn areas
                for i in -1...1 {
                    for j in -1...1 {
                        let newRow = rowIndex + i
                        let newCol = colIndex + j
                        if newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize {
                            grid[newRow][newCol] = max(grid[newRow][newCol], 0.5)
                        }
                    }
                }
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
