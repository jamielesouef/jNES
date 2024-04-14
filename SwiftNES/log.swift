//
//  l.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 13/4/2024.
//

import Foundation

func log(_ thing: Any...){
  #if DEBUG
  thing.forEach {
    print("Debug: —" + String(describing: $0))
  }
  #endif
}

func log<T: BinaryInteger>(_ thing: T..., r: Int = 2){
  #if DEBUG
  thing.forEach {
    print("Debug: —" + String($0, radix: r))
  }
  #endif
}
