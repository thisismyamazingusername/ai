//
//  Trainer.swift
//  kwkxdcc
//
//  Created by sd on 1/21/25.
//

import Foundation

class Trainer {
    private var layers: [Layer] = []
    private var learningRate: Double
    private var lossFunction: ([Double], [Double]) -> Double
    private var lossFunctionDerivative: ([Double], [Double]) -> [Double]

    init(learningRate: Double = 0.1,
         lossFunction: @escaping ([Double], [Double]) -> Double,
         lossFunctionDerivative: @escaping ([Double], [Double]) -> [Double]) {
        self.learningRate = learningRate
        self.lossFunction = lossFunction
        self.lossFunctionDerivative = lossFunctionDerivative
    }

    func addLayer(_ layer: Layer) {
        layers.append(layer)
    }

    func train(input: [Double], target: [Double]) -> Double {
        var activations = input
        var allActivations: [[Double]] = [activations]

        for layer in layers {
            activations = layer.forward(inputs: activations)
            allActivations.append(activations)
        }

        let loss = lossFunction(activations, target)

        var error = lossFunctionDerivative(activations, target)

        for (_, layer) in layers.reversed().enumerated() {
            error = layer.backward(error: error, learningRate: learningRate)
        }

        return loss
    }

    func trainBatch(inputs: [[Double]], targets: [[Double]], epochs: Int) {
        for epoch in 1...epochs {
            var totalLoss: Double = 0

            for (input, target) in zip(inputs, targets) {
                totalLoss += train(input: input, target: target)
            }

            print("Epoch \(epoch), Loss: \(totalLoss / Double(inputs.count))")
        }
    }

    func predict(input: [Double]) -> [Double] {
        var activations = input

        for layer in layers {
            activations = layer.forward(inputs: activations)
        }

        return activations
    }
}

