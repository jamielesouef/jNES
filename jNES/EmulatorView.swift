//
//  EmulatorView.swift
//  jNES
//
//  Created by Jamie Le Souef on 25/4/2024.
//

import SwiftUI

struct EmulatorView: View {
  let nes = NES()
  let viewModel = ScreenViewViewModel()
    var body: some View {
      VStack {
        ScreenView(viewModel: viewModel)
          .frame(width: 256, height: 240)
      }
      Spacer()
      DPadView()
      Spacer()
      HStack {
        Button("Start") {
          nes.powerOn()
        }
        Button("Stop") {
          nes.powerOff()
        }
      }
      
      Spacer()
    }
}

#Preview {
    EmulatorView()
}
