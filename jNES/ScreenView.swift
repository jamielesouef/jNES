//
//  ScreenView.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import SwiftUI

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
