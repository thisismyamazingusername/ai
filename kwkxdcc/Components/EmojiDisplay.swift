//
//  EmojiDisplay.swift
//  kwkxdcc
//
//  Created by sd on 1/21/25.
//

import Foundation
import SwiftUI

struct EmojiDisplay: View {
    var emoji: String
    var description: String

    var body: some View {
        VStack {
            Text(emoji).font(.largeTitle)
            Text(description).font(.headline)
        }
        .padding()
    }
}
