//
//  Layer.swift
//  kwkxdcc
//
//  Created by sd on 1/11N1/25.
//

import Foundation

class Layer {
    var weights: [[Double]]
    var biases: [Double]
    var activationFunc: ([Double]) -> [Double]
    var activationFuncDerivative: ([Double]) -> [Double]
    private var inputs: [Double] = []

    init(numNeurons: Int, inputSize: Int, activationFunc: @escaping ([Double]) -> [Double]) {
        self.weights = (0..<numNeurons).map { _ in (0..<inputSize).map { _ in Double.random(in: -1...1) } }
        self.biases = [Double](repeating: 0.0, count: numNeurons)
        self.activationFunc = activationFunc
        self.activationFuncDerivative = sigmoidDerivative
    }

    func forward(inputs: [Double]) -> [Double] {
        self.inputs = inputs
        let z = weights.map { zip($0, inputs).map(*).reduce(0, +) }
        return activationFunc(z)
    }

    func backward(error: [Double], learningRate: Double) -> [Double] {
        let output = activationFunc(weights.map { zip($0, inputs).map(*).reduce(0, +) })
        let delta = zip(error, activationFuncDerivative(output)).map(*)
        
        print("weights.count: \(weights.count)")
        print("weights[i].count: \(weights[0].count)")
        print("delta.count: \(delta.count)")
        print("inputs.count: \(inputs.count)")

        for i in 0..<weights.count {
            for j in 0..<weights[i].count {
                weights[i][j] -= learningRate * delta[i] * inputs[j]
            }
        }
        
        for i in 0..<biases.count {
            biases[i] -= learningRate * delta[i]
        }
        
        var prevLayerError = [Double](repeating: 0, count: weights[0].count)
        for i in 0..<weights[0].count {
            for j in 0..<weights.count {
                prevLayerError[i] += weights[j][i] * delta[j]
            }
        }
        
        return prevLayerError
    }

}

func sigmoidDerivative(_ x: [Double]) -> [Double] {
    return x.map { $0 * (1 - $0) }
}

