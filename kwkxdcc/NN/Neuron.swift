//
//  Neuron.swift
//  kwkxdcc
//
//  Created by sd on 1/21/25.
//

import Foundation

class Neuron {
    var weights: [Double]
    var bias: Double
    var activationFunc: (Double) -> Double

    init(inputSize: Int, activationFunc: @escaping (Double) -> Double) {
        self.weights = (0..<inputSize).map { _ in Double.random(in: -1...1) }
        self.bias = Double.random(in: -1...1)
        self.activationFunc = activationFunc
    }

    func output(inputs: [Double]) -> Double {
        let weightedSum = zip(weights, inputs).map(*).reduce(0, +) + bias
        return activationFunc(weightedSum)
    }
}
