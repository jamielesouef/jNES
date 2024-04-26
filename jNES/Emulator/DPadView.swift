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
  
  let onUp: (ControllerButton) -> Void
  let onDown: (ControllerButton) -> Void
  
  var body: some View {
    VStack(spacing: spacing) {
      buildButton(button: .up)
      HStack(spacing: spacing) {
        buildButton(button: .left)
        buildbuttonSpacer()
        buildButton(button: .right)
      }
      buildButton(button: .down)
    }
  }
  
  func buildbuttonSpacer() -> some View {
    Rectangle()
      .fill(Color.clear)
      .frame(width: buttonSize, height: buttonSize)
      .cornerRadius(10)
  }
  
  func buildButton(button: ControllerButton) -> some View {
    Rectangle()
      .fill(Color.blue)
      .frame(width: buttonSize, height: buttonSize)
      .cornerRadius(10)
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { _ in
            onDown(button)
          }
          .onEnded { _ in
            onUp(button)
          }
      )
  }
}

#Preview {
  DPadView(onUp: {_ in}, onDown: {_ in})
}
