//
//  Layer.swift
//  kwkxdcc
//
//  Created by sd on 1/11N1/25.
//

import Foundation

enum ActivationType {
    case relu
    case sigmoid
    case softmax
}

class Layer {
    var weights: [[Double]]
    var biases: [Double]
    var activationFunc: ([Double]) -> [Double]
    var activationFuncDerivative: ([Double]) -> [Double]
    private var inputs: [Double] = []
    var activationType: ActivationType
    
    init(numNeurons: Int, inputSize: Int, activationType: ActivationType) {
        // trying to add Xavier/Glorot initialization? (IDK ABT THIS)
        let scale = sqrt(2.0 / Double(inputSize + numNeurons))
        self.weights = (0..<numNeurons).map { _ in (0..<inputSize).map { _ in Double.random(in: -scale...scale) } }
        self.biases = [Double](repeating: 0.0, count: numNeurons)
        self.activationType = activationType
        
        switch activationType {
        case .sigmoid:
            self.activationFunc = sigmoid
            self.activationFuncDerivative = sigmoidDerivative
        case .softmax:
            self.activationFunc = softmax
            self.activationFuncDerivative = softmaxDerivative
        case .relu:
            self.activationFunc = relu
            self.activationFuncDerivative = reluDerivative
        }
    }
    
    func forward(inputs: [Double]) -> [Double] {
        self.inputs = inputs
        let z = zip(weights, biases).map { weight, bias in
            zip(weight, inputs).map(*).reduce(0, +) + bias
        }
        return activationFunc(z)
    }
    
    func backward(error: [Double], learningRate: Double, l2Strength: Double) -> [Double] {
            let z = zip(weights, biases).map { weight, bias in
                zip(weight, inputs).map(*).reduce(0, +) + bias
            }
            
            let delta: [Double]
            if activationType == .softmax {
                delta = error
            } else {
                delta = zip(error, activationFuncDerivative(z)).map(*)
            }
        
            print("weights.count: \(weights.count)")
            print("weights[i].count: \(weights[0].count)")
            print("delta.count: \(delta.count)")
            print("inputs.count: \(inputs.count)")
                
            print("Layer: weights: \(weights.count)x\(weights[0].count), delta: \(delta.count), inputs: \(inputs.count)")
            
            
            for i in 0..<weights.count {
                for j in 0..<weights[i].count {
                    weights[i][j] -= learningRate * (delta[i] * inputs[j] + l2Strength * weights[i][j])
                }
                biases[i] -= learningRate * delta[i]
            }
            
            let prevLayerError = (0..<inputs.count).map { j in
                (0..<weights.count).reduce(0.0) { $0 + weights[$1][j] * delta[$1] }
            }
            
            return prevLayerError
    }
}

func crossEntropyDerivative(predicted: [Double], actual: [Double]) -> [Double] {
    return zip(predicted, actual).map { $0 - $1 }
}
