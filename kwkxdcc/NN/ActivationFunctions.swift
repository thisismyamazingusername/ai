//
//  ActivationFuncs.swift
//  kwkxdcc
//
//  Created by sd on 1/21/25.
//

import Foundation

func sigmoid(_ x: [Double]) -> [Double] {
    return x.map { 1 / (1 + exp(-$0)) }
}

func softmax(_ x: [Double]) -> [Double] {
    let expValues = x.map { exp($0) }
    let sumExp = expValues.reduce(0, +)
    return expValues.map { $0 / (sumExp + 1e-8) }
}

func sigmoidDerivative(_ x: [Double]) -> [Double] {
    return x.map { $0 * (1 - $0) }
}

func softmaxDerivative(_ x: [Double]) -> [Double] {
    return x.map { $0 * (1 - $0) }
}

func relu(_ x: [Double]) -> [Double] {
    return x.map { max(0, $0) }
}

func reluDerivative(_ x: [Double]) -> [Double] {
    return x.map { $0 > 0 ? 1 : 0 }
}
