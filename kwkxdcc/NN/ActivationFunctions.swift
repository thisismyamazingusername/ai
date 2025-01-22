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

// sigDerivativeFunc in /Layer
