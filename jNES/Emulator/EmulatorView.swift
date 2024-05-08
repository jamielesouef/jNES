//
//  EmulatorView.swift
//  jNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import Combine
import SpriteKit
import SwiftUI

class ContentViewModel: ObservableObject {
  @Published var pixelData: [[PixelData]]

  let nes = try? NES()
  private var cancellables: Set<AnyCancellable> = []

  init() {
    // Initialize the pixel data buffer
    pixelData = Array(
      repeating: Array(
        repeating: PixelData.black,
        count: 32
      ),
      count: 32
    )

    nes?.updateScreen = { [weak self] adapter in
      let buffer = adapter.toPixelBuffer()
      DispatchQueue.main.async {
        self?.pixelData = buffer
      }
    }
  }

  // Example function to update pixel data buffer
  func updatePixelData(from buffer: [[PixelData]]) {
    pixelData = buffer
  }

  func updatePixelData() {
    // Your logic to update pixel data buffer
    for col in 0 ..< 32 {
      for row in 0 ..< 32 {
        pixelData[col][row] = PixelData(
          red: UInt8.random(in: 0 ... 255),
          green: UInt8.random(in: 0 ... 255),
          blue: UInt8.random(in: 0 ... 255)
        )
      }
    }
  }
}

struct EmulatorView: View {
  @StateObject private var viewModel = ContentViewModel()

  var body: some View {
    VStack {
      // ImageView(pixelData: viewModel.pixelData)
      ImageView()
        .frame(width: 256, height: 240)
      Spacer()
      HStack {
        Button("Start") {
          viewModel.nes?.powerOn()
        }
        Button("Stop") {
          viewModel.nes?.powerOff()
        }
      }
    }
  }

  func startUpdatingPixelData() {
    // Example: Start a timer to update pixel data buffer
    Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { _ in
      viewModel.updatePixelData()
    }
  }
}

#Preview {
  EmulatorView()
}
