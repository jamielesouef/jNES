//
//  ScreenView.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import SwiftUI

protocol ScreenPixelBufferAdapter {
  func toPixelBuffer() -> [[PixelData]]
}

final class ScreenViewViewModel: ObservableObject {
  @Published var pixelBuffer: [[PixelData]] = Array(repeating: Array(repeating: PixelData(r: 0, g: 0, b: 0, a: 255), count: 64), count: 64)
  private var width = 64
  private var height = 64
  private var buffer: [[PixelData]] = []
  private var timer: Timer?
  
  init(adapter: ScreenPixelBufferAdapter? = nil) {
//    self.timer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { [weak self] _ in
//      self?.loadFromAdapter()
//    }
  }
  
  func updateBuffer(with adapter: ScreenPixelBufferAdapter) {
    DispatchQueue.main.async {
      self.pixelBuffer = adapter.toPixelBuffer()
    }
  }
}

struct ScreenView: View {
  
  @StateObject var viewModel: ScreenViewViewModel
  
  init(viewModel: ScreenViewViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    VStack {
      PixelBufferView(buffer: viewModel.pixelBuffer, pixelSize: 10) // Adjust pixelSize as needed
    }
  }
}
