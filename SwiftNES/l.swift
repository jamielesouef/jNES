//
//  l.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 13/4/2024.
//

import Foundation

func l<T: BinaryInteger>(_ thing: T..., r: Int = 2){
  thing.forEach {
    print(String($0, radix: r))
  }
}
