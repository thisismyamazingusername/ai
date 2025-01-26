//
//  ContentView.swift
//  kwkxdcc
//
//  Created by sd on 1/11/25.
//
//
import SwiftUI
import AVFoundation
import Combine

enum AppMode: String, CaseIterable {
    case teach
    case play
}

struct ContentView: View {
    @State private var mode: AppMode = .teach
    @State private var progress: CGFloat = 0.0
    @State private var currentEmoji: EmojiData?
    @State private var currentEmojiIndex: Int = 0
    @State private var neuralNetwork = NeuralNetwork()
    @State private var trainedCount: Int = 0
    @State private var drawing: [CGPoint] = []
    @State private var showThankYou: Bool = false
    @State private var predictionResult: String?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var timer: Timer?
    
    let totalTrainingRounds = 12 // 6 emojis 2 passes
    
    var body: some View {
        VStack {
            if showThankYou {
                Text("Thank you for playing!")
            } else {
                ProgressBar(progress: progress)
                    .padding()
                
                if mode == .teach {
                    if let emoji = currentEmoji {
                        EmojiDisplay(emoji: emoji.symbol, description: emoji.description)
                    }
                } else {
                    if let result = predictionResult {
                        EmojiDisplay(emoji: result, description: "Prediction")
                    }
                }
                
                DrawingCanvasView(drawing: $drawing, currentEmojiIndex: $currentEmojiIndex, model: neuralNetwork)
                    .padding()
                    .onChange(of: drawing) { oldValue, newValue in
                        if mode == .play {
                            timer?.invalidate()
                            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                                predict()
                            }
                        }
                    }
                
                if mode == .teach {
                    Button(action: teachNext) {
                        Text("Teach")
                    }
                    .disabled(drawing.isEmpty || trainedCount >= totalTrainingRounds)
                } else {
                    Button(action: { showThankYou = true }) {
                        Text("So What?")
                    }
                }
            }
        }
        .onAppear {
            loadEmojis()
        }
    }

    private func teachNext() {
        guard let emojiID = currentEmoji?.id else { return }

        processDrawing(points: drawing, canvasWidth: UIScreen.main.bounds.width, canvasHeight: UIScreen.main.bounds.height)
        
        neuralNetwork.teach(input: drawing, label: emojiID)
        print("Teaching with emoji: \(emojiID)")
        
        trainedCount += 1
        progress = CGFloat(trainedCount) / CGFloat(totalTrainingRounds)
        
        if trainedCount < totalTrainingRounds {
            nextEmoji()
        } else {
            mode = .play
            print("Training complete! Switch to Play mode.")
        }
        
        drawing = []
    }

    private func predict() {
        let (prediction, confidence) = neuralNetwork.predict(input: drawing)
        
        if confidence > 0.2 {
            //   ADJUST THIS to 0.5 hmm brb
            predictionResult = EmojiData.all.first(where: { $0.id == prediction })?.symbol ?? "🫠"
            playSound(name: "recognized")
        } else {
            predictionResult = "🫠"
            playSound(name: "missed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            drawing = []
            predictionResult = nil
        }
    }


    private func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }

    private func loadEmojis() {
        currentEmoji = EmojiData.all.first
    }
        
    private func nextEmoji() {
        currentEmojiIndex = (currentEmojiIndex + 1) % EmojiData.all.count
        currentEmoji = EmojiData.all[currentEmojiIndex]
    }

    func processDrawing(points: [CGPoint], canvasWidth: CGFloat, canvasHeight: CGFloat) {
        let grid = neuralNetwork.canvasToGrid(points: points, width: canvasWidth, height: canvasHeight)
        var inputPoints: [CGPoint] = []
        
        for (rowIndex, row) in grid.enumerated() {
            for (colIndex, isActive) in row.enumerated() {
                if isActive {
                    let point = CGPoint(x: CGFloat(colIndex) * (canvasWidth / CGFloat(grid.count)),
                                        y: CGFloat(rowIndex) * (canvasHeight / CGFloat(grid.count)))
                    inputPoints.append(point)
                }
            }
        }
        
        neuralNetwork.teach(input: inputPoints, label: EmojiData.all[currentEmojiIndex].id)
    }
}
