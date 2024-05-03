//
//  EmulatorView.swift
//  jNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import SwiftUI
import SpriteKit
import Combine

class ContentViewModel: ObservableObject {
  @Published var pixelData: [[PixelData]]
  
  let nes = try! NES()
  private var cancellables: Set<AnyCancellable> = []
  
  init() {
    // Initialize the pixel data buffer
    self.pixelData = [[PixelData]](repeating: [PixelData](repeating: PixelData(r: 0, g: 0, b: 0), count: 32), count: 32)
    
    nes.updateScreen = { [weak self] adapter in
      let buffer = adapter.toPixelBuffer()
      DispatchQueue.main.async {
        self?.pixelData = buffer
      }
    }
  }
  
  // Example function to update pixel data buffer
  func updatePixelData(from buffer: [[PixelData]]) {
    self.pixelData = buffer
  }
  
  func updatePixelData() {
    // Your logic to update pixel data buffer
    for i in 0..<32 {
      for j in 0..<32 {
        self.pixelData[i][j] = PixelData(r: UInt8.random(in: 0...255), g: UInt8.random(in: 0...255), b: UInt8.random(in: 0...255))
      }
    }
  }
}

struct EmulatorView: View {
  
  @StateObject private var viewModel = ContentViewModel()
  
  var body: some View {
    VStack {
      
      //ImageView(pixelData: viewModel.pixelData)
      ImageView()
        .frame(width: 256, height: 240)
      Spacer()
      DPadView(
        onUp: viewModel.nes.controller.didReceiveButtonUp,
        onDown: viewModel.nes.controller.didReceiveButtonDown
      )
      Spacer()
      HStack() {
        Button("Start") {
          viewModel.nes.powerOn()
        }
        Button("Stop") {
          viewModel.nes.powerOff()
        }
      }
    }
    
  }
  
  func startUpdatingPixelData() {
    // Example: Start a timer to update pixel data buffer
    Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { timer in
      viewModel.updatePixelData()
    }
  }
}

#Preview {
  EmulatorView()
}
