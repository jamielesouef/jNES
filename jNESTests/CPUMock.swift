//
//  CPUMock.swift
//  SwiftNESTests
//
//  Created by Jamie Le Souef on 11/4/2024.
//

import Foundation
@testable import jNES

extension CPU {
  static func mock() -> CPU {
    
    let zeroPage: [UInt8] =  [21,62,148,13,16,143,207,111,149,249,104,194,225,233,29,251,140,34,169,125,240,6,18,66,117,194,77,29,124,172,113,155,84,48,70,62,68,81,43,171,34,75,161,39,254,51,163,59,42,26,14,96,254,232,82,247,103,1,23,29,193,115,63,67,59,84,86,109,186,41,189,69,249,30,6,216,72,225,201,158,193,236,98,106,203,86,54,99,96,79,24,75,238,108,153,207,182,71,5,24,79,194,192,157,241,241,173,140,87,30,196,86,39,180,151,106,89,164,222,178,228,21,197,92,84,228,68,48,194,40,86,121,120,202,103,152,6,29,128,230,143,32,105,164,212,237,83,61,232,27,190,36,229,202,89,228,158,201,47,220,111,80,179,207,161,151,130,63,112,178,40,211,135,56,190,123,204,71,240,120,239,119,35,128,223,39,134,122,15,228,180,211,197,159,224,1,51,201,85,51,221,212,244,25,65,51,1,57,46,44,5,240,199,1,147,107,25,123,85,93,81,27,106,178,59,136,186,100,170,34,121,245,22,198,189,75,240,114,107,152,176,186,71,192,78,12,170,199,2,155,145,221,70,64,56,192]
    
    var buffer: [UInt8] = Array(repeating: 0, count: 0xFFFF)
    let stack: [UInt8] = Array(repeating: 0, count: 0xFF)
    buffer.insert(contentsOf: zeroPage, at: 0)
    buffer.insert(contentsOf: stack, at: 0x0100)
    buffer.insert(contentsOf: programMock, at: 0x8000)
    
    let file = Bundle.main.url(forResource: "nestest", withExtension: "nes")!
    let data = try! Data(contentsOf: file)
    
    let rom = try! Rom(data: [UInt8](data))
    
    let registers =  Registers(A: 0x33, X: 0x10, Y: 0xFF, p: 0x00)
    let mem = Bus(buffer: buffer, rom: rom)
    let cpu = CPU(bus: mem, registers: registers)
    
    return cpu
  }
}
