////
////  TrainerViewModel.swift
////  kwkxdcc
////
////  Created by sd on 1/22/25.
////
//
//import Foundation
//import SwiftUI
//
//class TrainerViewModel: ObservableObject {
//    @Published var currentEmojiIndex: Int = 0
//    @Published var drawnPoints: [CGPoint] = []
//    @Published var pixelGrid: [[Bool]] = []
//
//    private var trainer = Trainer(
//        learningRate: 0.01,
//        lossFunction: { predicted, target in
//            zip(predicted, target).map { pow($0 - $1, 2) }.reduce(0, +)
//        },
//        lossFunctionDerivative: { predicted, target in
//            zip(predicted, target).map { 2 * ($0 - $1) }
//        }
//    )
//    
//    let emojis = ["😀", "🎉", "❤️", "👍"] // Example emoji list
//    private let gridSize = 80
//
//    init() {
//        pixelGrid = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
//    }
//
//    func processDrawing(points: [CGPoint], width: CGFloat, height: CGFloat) {
//        drawnPoints = points
//        pixelGrid = convertToGrid(points: points, width: width, height: height)
//        trainModel()
//    }
//
//    private func convertToGrid(points: [CGPoint], width: CGFloat, height: CGFloat) -> [[Bool]] {
//        var grid = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
//        let pixelWidth = width / CGFloat(gridSize)
//        let pixelHeight = height / CGFloat(gridSize)
//
//        for point in points {
//            let column = Int(point.x / pixelWidth)
//            let row = Int(point.y / pixelHeight)
//
//            if row >= 0 && row < gridSize && column >= 0 && column < gridSize {
//                grid[row][column] = true
//            }
//        }
//        return grid
//    }
//
//    private func trainModel() {
//        let input = pixelGrid.flatMap { $0.map { $0 ? 1.0 : 0.0 } }
//        
//        var target = Array(repeating: 0.0, count: emojis.count)
//        target[currentEmojiIndex] = 1.0
//
//        let loss = trainer.train(input: input, target: target)
//        print("Training complete. Loss: \(loss)")
//    }
//
//    func nextEmoji() {
//        currentEmojiIndex = (currentEmojiIndex + 1) % emojis.count
//        resetCanvas()
//    }
//
//    func resetCanvas() {
//        pixelGrid = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
//        drawnPoints = []
//    }
//}
//
