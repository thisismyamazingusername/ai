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
    @State private var drawing: [[CGPoint]] = []
    @State private var lastDrawingTime: Date = Date()
    @State private var showThankYou: Bool = false
    @State private var predictionResult: String?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var timer: Timer?
    @State private var isProcessing: Bool = false
    
    let totalTrainingRounds = 12 // 6 emojis 2 passes
    
    var body: some View {
        VStack {
            if showThankYou {
                VStack {
                    Text("Thank you for playing! ")
                        .padding()
                    
                    Button(action: {
                        showThankYou = false
                        mode = .play
                    }) {
                        Text("Return to Play")
                    }
                    .padding()
                    
                    Button(action: {
                        showThankYou = false
                        mode = .teach
                        trainedCount = 0
                        progress = 0
                        currentEmojiIndex = 0
                        loadEmojis()
                    }) {
                        Text("Restart & Teach")
                    }
                    .padding()
                }
            }  else if mode == .teach && progress == 0 {
                VStack {
                    Text("Welcome. Let's play a game to understand the tradeoffs of AI, especially how it can fuel or combat the climate change crisis. You will be given emojis and a description. Draw an interpretation of the emoji to teach AI! The model will then guess what you draw.")
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        progress = 0.01 
                    }) {
                        Text("Start Teaching")
                    }
                    .padding()
                }
            }  else {
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
                
                Picker("Mode", selection: $mode) {
                    ForEach(AppMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue.capitalized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                DrawingCanvasView(drawing: $drawing, currentEmojiIndex: $currentEmojiIndex, model: neuralNetwork)
                    .padding()
                    .onChange(of: drawing) { oldValue, newValue in
                        lastDrawingTime = Date()
                        if mode == .play {
                            timer?.invalidate()
                            timer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
                                if Date().timeIntervalSince(lastDrawingTime) >= 3.5 && !drawing.isEmpty {
                                    predict()
                                }
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

        let flattenedDrawing = drawing.flatMap { $0 }
        let processedDrawing = processDrawing(points: flattenedDrawing, canvasWidth: UIScreen.main.bounds.width, canvasHeight: UIScreen.main.bounds.height)
        
        neuralNetwork.teach(input: processedDrawing, label: emojiID)
        print("Teaching emoji: \(emojiID)")
        
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
        guard !drawing.isEmpty else { return }
        isProcessing = true
        predictionResult = "Processing..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let flattenedDrawing = drawing.flatMap { $0 }
            let (prediction, confidence) = neuralNetwork.predict(input: flattenedDrawing)
            
            // 0.16 would be random, 0.2 is good, testing w 0.17 tho
            // ideally should be highest confidence but if not random ?? does it count
            if confidence > 0.17 {
                predictionResult = EmojiData.all.first(where: { $0.id == prediction })?.symbol ?? "??"
                playSound(name: "recognized")
            } else {
                predictionResult = "🫠 missed that"
                playSound(name: "missed")
            }
            
            isProcessing = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                drawing = []
                predictionResult = nil
            }
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

    func processDrawing(points: [CGPoint], canvasWidth: CGFloat, canvasHeight: CGFloat) -> [CGPoint] {
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
        
        return inputPoints
    }
}
