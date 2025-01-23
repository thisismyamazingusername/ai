//
//  ContentView.swift
//  kwkxdcc
//
//  Created by sd on 1/11/25.
//
//
import SwiftUI

enum AppMode: String, CaseIterable {
    case teach
    case play
}

struct ContentView: View {
    @State private var mode: AppMode = .teach
    @State private var progress: CGFloat = 0.0
    @State private var currentEmoji: EmojiData?
    @State private var neuralNetwork = NeuralNetwork()
    @State private var trainedCount: Int = 0
    @State private var drawing: [CGPoint] = []
    
    
    var body: some View {
        VStack {
            ProgressBar(progress: progress)
                .padding()
            
            HStack {
                Text("Mode:")
                Picker("Mode", selection: $mode) {
                    Text("Teach").tag(AppMode.teach)
                    Text("Play").tag(AppMode.play)
                }
                .pickerStyle(SegmentedPickerStyle())
                .disabled(trainedCount < 13) //EmojiData.all.count or each 2x+ = 13?
                
            }
            
            if let emoji = currentEmoji {
                EmojiDisplay(emoji: emoji.symbol, description: emoji.description)
            }
            
            DrawingCanvasView(onDrawingEnd: { points in
                drawing = points // Store the drawing for teaching
            })
            .padding()
            
            if mode == .teach {
                Button(action: teachNext) {
                    Text("Teach next")
                }
                .disabled(drawing.isEmpty || trainedCount >= EmojiData.all.count)
            }
        }
                .onAppear {
                    loadEmojis()
                }
        }
        
    private func teachNext() {
            guard let emojiID = currentEmoji?.id else { return }
            
            neuralNetwork.teach(input: drawing, label: emojiID)
            print("Teaching with emoji: \(emojiID)")
            
            trainedCount += 1
            progress = CGFloat(trainedCount) / CGFloat(EmojiData.all.count)
            
            if trainedCount < EmojiData.all.count {
                nextEmoji()
            } else {
                mode = .play
                print("Training complete! Switch to Play mode.")
            }
            
            drawing = []
        }
        
        
        private func loadEmojis() {
            currentEmoji = EmojiData.all.first
        }
        
    private func nextEmoji() {
        if let currentIndex = EmojiData.all.firstIndex(where: { $0.id == currentEmoji?.id }) {
            let nextIndex = (currentIndex + 1) % EmojiData.all.count
            currentEmoji = EmojiData.all[nextIndex]
        }
        }
    }
    
