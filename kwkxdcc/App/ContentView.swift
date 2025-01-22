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
            }

            if let emoji = currentEmoji {
                EmojiDisplay(emoji: emoji.symbol, description: emoji.description)
            }

            DrawingCanvasView(onDrawingEnd: handleDrawingEnd)
                .padding()

            Button(action: nextEmoji) {
                Text("Next")
            }
            .disabled(mode == .play)
        }
        .onAppear {
            loadEmojis()
        }
    }

    private func loadEmojis() {
        currentEmoji = EmojiData.all.first
    }

    private func nextEmoji() {
        if let index = EmojiData.all.firstIndex(where: { $0.id == currentEmoji?.id }) {
            currentEmoji = EmojiData.all[index + 1]
            progress += 1.0 / CGFloat(EmojiData.all.count)
        }
    }

    private func handleDrawingEnd(_ drawing: [CGPoint]) {
        if mode == .teach {
            neuralNetwork.teach(input: drawing, label: currentEmoji?.id ?? "")
        } else {
            let prediction = neuralNetwork.predict(input: drawing)
            print("Predicted emoji: \(prediction)")
        }
    }
}
