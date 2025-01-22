//
//  NN.swift
//  kwkxdcc
//
//  Created by sd on 1/13/25.
//

import Foundation
import UIKit
import Accelerate

class NeuralNetwork {
    var layers: [Layer]

    init() {
        layers = [
            Layer(numNeurons: 16, inputSize: 100, activationFunc: sigmoid),
            Layer(numNeurons: 6, inputSize: 16, activationFunc: sigmoid)
        ]
    }

    func predict(input: [CGPoint]) -> String {
        let flattenedInput = input.flatMap { [$0.x, $0.y] }.toDouble()
        let output = layers.reduce(flattenedInput) { $1.forward(inputs: $0) }
        let maxIndex = output.firstIndex(of: output.max() ?? 0) ?? 0
        return EmojiData.all[maxIndex].id
    }

    func teach(input: [CGPoint], label: String) {
            // flattened/converted -> double??
            var flattenedInput = input.flatMap { [$0.x, $0.y] }.toDouble()
            
            while flattenedInput.count < 100 {
                // 0 padding
                flattenedInput.append(0)
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

}


extension Array where Element == CGFloat {
    func toDouble() -> [Double] {
        return self.map { Double($0) }
    }
}
