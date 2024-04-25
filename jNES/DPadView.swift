//
//  DPadView.swift
//  jNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import SwiftUI

struct DPadView: View {
  let buttonSize: CGFloat = 50
  let spacing: CGFloat = 10
  
    var body: some View {
      VStack(spacing: spacing) {
        buildButton()
        HStack(spacing: spacing) {
          buildButton()
          buildbuttonSpacer()
          buildButton()
        }
        buildButton()
      }
    }
  func buildbuttonSpacer() -> some View {
    Rectangle()
      .fill(Color.clear)
      .frame(width: buttonSize, height: buttonSize)
      .cornerRadius(10)
  }
  func buildButton() -> some View {
    Rectangle()
      .fill(Color.blue)
      .frame(width: buttonSize, height: buttonSize)
      .cornerRadius(10)
  }
}

#Preview {
    DPadView()
}
