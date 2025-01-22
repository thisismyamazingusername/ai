//
//  EmojiData.swift
//  kwkxdcc
//
//  Created by sd on 1/21/25.
//

import Foundation

struct EmojiData: Identifiable, Codable {
    let id: String
    let symbol: String
    let description: String

    static let all: [EmojiData] = loadEmojis()

    static func loadEmojis() -> [EmojiData] {
        guard let url = Bundle.main.url(forResource: "Emojis", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let emojis = try? JSONDecoder().decode([EmojiData].self, from: data) else {
            return []
        }
        return emojis
    }
}
