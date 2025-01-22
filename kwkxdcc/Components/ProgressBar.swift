//
//  ProgressBar.swift
//  kwkxdcc
//
//  Created by sd on 1/21/25.
//

import Foundation
import SwiftUI

struct ProgressBar: View {
    var progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: 6)
                    .opacity(0.3)
                    .foregroundColor(.gray)

                Rectangle().frame(width: geometry.size.width * progress, height: 6)
                    .foregroundColor(.blue)
            }
            .cornerRadius(3.0)
        }
        .frame(height: 6)
    }
}
