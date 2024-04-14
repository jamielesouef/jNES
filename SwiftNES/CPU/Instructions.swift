//
//  Instruction.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 10/4/2024.
//

import Foundation

struct Instruction {
  let mode: AddressingMode
  let cycles: UInt8
  let bytes: UInt8
  let fn: () -> Void
  
  init(
    mode: AddressingMode,
    cycles: UInt8,
    bytes: UInt8,
    fn: @escaping () -> Void = {}
  ) {
    self.mode = mode
    self.cycles = cycles
    self.bytes = bytes
    self.fn = fn
  }
}

//enum InstructionSet {
//  case ADC
//  case AND
//  case ASL
//  case BCC
//  case BCS
//  case BEQ
//  case BIT
//  case BMI
//  case BNE
//  case BPL
//  case BRK
//  case BVC
//  case BVS
//  case CLC
//  case CLD
//  case CLI
//  case CLV
//  case CMP
//  case CPX
//  case CPY
//  case DEC
//  case DEY
//  case EOR
//  case INC
//  case INX
//  case INY
//  case JMP
//  case JSR
//  case LDA
//  case LDX
//  case LDY
//  case LSR
//  case NOP
//  case ORA
//  case PHA
//  case PHP
//  case PLA
//  case PLP
//  case ROL
//  case ROR
//  case RTI
//  case RTS
//  case SBC
//  case SEC
//  case SED
//  case SEI
//  case STA
//  case STX
//  case STY
//  case TAX
//  case TAY
//  case TSX
//  case TXA
//  case TXS
//  case TYA
//  case DEX
//}

extension CPU {
  func getInstructions(forOpcode opcode: UInt8) -> Instruction {
    
    let table: [UInt8: Instruction] = [
      0x61: Instruction(mode: .indirectX, cycles: 6, bytes: 2, fn: self.ADC),
      0x65: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.ADC),
      0x69: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.ADC),
      0x6D: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.ADC),
      0x71: Instruction(mode: .indirectY, cycles: 5, bytes: 2, fn: self.ADC),
      0x75: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.ADC),
      0x79: Instruction(mode: .absoluteY, cycles: 4, bytes: 3, fn: self.ADC),
      0x7D: Instruction(mode: .absoluteX, cycles: 4, bytes: 3, fn: self.ADC),
      
      0x21: Instruction(mode: .indirectX, cycles: 6, bytes: 2, fn: self.AND),
      0x25: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.AND),
      0x29: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.AND),
      0x2D: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.AND),
      0x31: Instruction(mode: .indirectY, cycles: 5, bytes: 2, fn: self.AND),
      0x35: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.AND),
      0x39: Instruction(mode: .absoluteY, cycles: 4, bytes: 3, fn: self.AND),
      0x3D: Instruction(mode: .absoluteX, cycles: 4, bytes: 3, fn: self.AND),
      
      0x06: Instruction(mode: .zeroPage, cycles: 5, bytes: 2, fn: self.ASL),
      0x0A: Instruction(mode: .accumulator, cycles: 2, bytes: 1, fn: self.ASL),
      0x0E: Instruction(mode: .absolute, cycles: 6, bytes: 3, fn: self.ASL),
      0x16: Instruction(mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.ASL),
      0x1E: Instruction(mode: .absoluteX, cycles: 7, bytes: 3, fn: self.ASL),
      
      0x90: Instruction(mode: .relative, cycles: 2, bytes: 2, fn: self.BCC),
      
      0xB0: Instruction(mode: .relative, cycles: 2, bytes: 2, fn: self.BCS),
      
      0xF0: Instruction(mode: .relative, cycles: 2, bytes: 2, fn: self.BEQ),
      
      0x24: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.BIT),
      0x2C: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.BIT),
      
      0x30: Instruction(mode: .relative, cycles: 2, bytes: 2, fn: self.BMI),
      
      0xD0: Instruction(mode: .relative, cycles: 2, bytes: 2, fn: self.BNE),
      
      0x10: Instruction(mode: .relative, cycles: 2, bytes: 2, fn: self.BPL),
      
      0x00: Instruction(mode: .implied, cycles: 7, bytes: 1, fn: self.BRK),
      
      0x50: Instruction(mode: .relative, cycles: 2, bytes: 2, fn: self.BVC),
      
      0x70: Instruction(mode: .relative, cycles: 2, bytes: 2, fn: self.BVS),
      
      0x18: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.CLC),
      
      0xD8: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.CLD),
      
      0x58: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.CLI),
      
      0xB8: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.CLV),
      
      0xC1: Instruction(mode: .indirectX, cycles: 6, bytes: 2, fn: self.CMP),
      0xC5: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.CMP),
      0xC9: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.CMP),
      0xCD: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.CMP),
      0xD1: Instruction(mode: .indirectY, cycles: 5, bytes: 2, fn: self.CMP),
      0xD5: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.CMP),
      0xD9: Instruction(mode: .absoluteY, cycles: 4, bytes: 3, fn: self.CMP),
      0xDD: Instruction(mode: .absoluteX, cycles: 4, bytes: 3, fn: self.CMP),
      
      0xE0: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.CPX),
      0xE4: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.CPX),
      0xEC: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.CPX),
      0xC0: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.CPY),
      0xC4: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.CPY),
      0xCC: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.CPY),
      
      0xC6: Instruction(mode: .zeroPage, cycles: 5, bytes: 2, fn: self.DEC),
      0xCE: Instruction(mode: .absolute, cycles: 6, bytes: 3, fn: self.DEC),
      0xD6: Instruction(mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.DEC),
      0xDE: Instruction(mode: .absoluteX, cycles: 7, bytes: 3, fn: self.DEC),
      
      0xCA: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.DEX),
      0x88: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.DEY),
      
      0x41: Instruction(mode: .indirectX, cycles: 6, bytes: 2, fn: self.EOR),
      0x45: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.EOR),
      0x49: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.EOR),
      0x4D: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.EOR),
      0x51: Instruction(mode: .indirectY, cycles: 5, bytes: 2, fn: self.EOR),
      0x55: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.EOR),
      0x59: Instruction(mode: .absoluteY, cycles: 4, bytes: 3, fn: self.EOR),
      0x5D: Instruction(mode: .absoluteX, cycles: 4, bytes: 3, fn: self.EOR),
      
      0xE6: Instruction(mode: .zeroPage, cycles: 5, bytes: 2, fn: self.INC),
      0xEE: Instruction(mode: .absolute, cycles: 6, bytes: 3, fn: self.INC),
      0xF6: Instruction(mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.INC),
      0xFE: Instruction(mode: .absoluteX, cycles: 7, bytes: 3, fn: self.INC),
      
      0xE8: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.INX),
      0xC8: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.INY),
      
      0x4C: Instruction(mode: .absolute, cycles: 3, bytes: 3, fn: self.JMP),
      0x6C: Instruction(mode: .indirect, cycles: 5, bytes: 3, fn: self.JMP),
      
      0x20: Instruction(mode: .absolute, cycles: 6, bytes: 3, fn: self.JSR),
      
      0xA1: Instruction(mode: .indirectX, cycles: 6, bytes: 2, fn: self.LDA),
      0xA5: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.LDA),
      0xA9: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.LDA),
      0xAD: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.LDA),
      0xB1: Instruction(mode: .indirectY, cycles: 5, bytes: 2, fn: self.LDA),
      0xB5: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.LDA),
      0xB9: Instruction(mode: .absoluteY, cycles: 4, bytes: 3, fn: self.LDA),
      0xBD: Instruction(mode: .absoluteX, cycles: 4, bytes: 3, fn: self.LDA),
      
      0xA2: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.LDX),
      0xA6: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.LDX),
      0xAE: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.LDX),
      0xB6: Instruction(mode: .zeroPageY, cycles: 4, bytes: 2, fn: self.LDX),
      0xBE: Instruction(mode: .absoluteY, cycles: 4, bytes: 3, fn: self.LDX),
      
      0xA0: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.LDY),
      0xA4: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.LDY),
      0xAC: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.LDY),
      0xB4: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.LDY),
      0xBC: Instruction(mode: .absoluteX, cycles: 4, bytes: 3, fn: self.LDY),
      
      0x46: Instruction(mode: .zeroPage, cycles: 5, bytes: 2, fn: self.LSR),
      0x4A: Instruction(mode: .accumulator, cycles: 2, bytes: 1, fn: self.LSR),
      0x4E: Instruction(mode: .absolute, cycles: 6, bytes: 3, fn: self.LSR),
      0x56: Instruction(mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.LSR),
      0x5E: Instruction(mode: .absoluteX, cycles: 7, bytes: 3, fn: self.LSR),
      
      0xEA: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.NOP),
      
      0x01: Instruction(mode: .indirectX, cycles: 6, bytes: 2, fn: self.ORA),
      0x05: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.ORA),
      0x09: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.ORA),
      0x0D: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.ORA),
      0x11: Instruction(mode: .indirectY, cycles: 5, bytes: 2, fn: self.ORA),
      0x15: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.ORA),
      0x19: Instruction(mode: .absoluteY, cycles: 4, bytes: 3, fn: self.ORA),
      0x1D: Instruction(mode: .absoluteX, cycles: 4, bytes: 3, fn: self.ORA),
      
      0x48: Instruction(mode: .implied, cycles: 3, bytes: 1, fn: self.PHA),
      0x08: Instruction(mode: .implied, cycles: 3, bytes: 1, fn: self.PHP),
      
      0x68: Instruction(mode: .implied, cycles: 4, bytes: 1, fn: self.PLA),
      
      0x28: Instruction(mode: .implied, cycles: 4, bytes: 1, fn: self.PLP),
      
      0x26: Instruction(mode: .zeroPage, cycles: 5, bytes: 2, fn: self.ROL),
      
      0x2A: Instruction(mode: .accumulator, cycles: 2, bytes: 1, fn: self.ROL),
      0x2E: Instruction(mode: .absolute, cycles: 6, bytes: 3, fn: self.ROL),
      0x36: Instruction(mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.ROL),
      0x3E: Instruction(mode: .absoluteX, cycles: 7, bytes: 3, fn: self.ROL),
      
      0x66: Instruction(mode: .zeroPage, cycles: 5, bytes: 2, fn: self.ROR),
      0x6A: Instruction(mode: .accumulator, cycles: 2, bytes: 1, fn: self.ROR),
      0x6E: Instruction(mode: .absolute, cycles: 6, bytes: 3, fn: self.ROR),
      0x76: Instruction(mode: .zeroPageX, cycles: 6, bytes: 2, fn: self.ROR),
      0x7E: Instruction(mode: .absoluteX, cycles: 7, bytes: 3, fn: self.ROR),
      
      0x40: Instruction(mode: .implied, cycles: 6, bytes: 1, fn: self.RTI),
      
      0x60: Instruction(mode: .implied, cycles: 6, bytes: 1, fn: self.RTS),
      
      0xE1: Instruction(mode: .indirectX, cycles: 6, bytes: 2, fn: self.SBC),
      0xE5: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.SBC),
      0xE9: Instruction(mode: .immediate, cycles: 2, bytes: 2, fn: self.SBC),
      0xED: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.SBC),
      0xF1: Instruction(mode: .indirectY, cycles: 5, bytes: 2, fn: self.SBC),
      0xF5: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.SBC),
      0xF9: Instruction(mode: .absoluteY, cycles: 4, bytes: 3, fn: self.SBC),
      0xFD: Instruction(mode: .absoluteX, cycles: 4, bytes: 3, fn: self.SBC),
      0x38: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.SEC),
      
      0xF8: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.SED),
      
      0x78: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.SEI),
      
      0x81: Instruction(mode: .indirectX, cycles: 6, bytes: 2, fn: self.STA),
      0x85: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.STA),
      0x8D: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.STA),
      0x91: Instruction(mode: .indirectY, cycles: 6, bytes: 2, fn: self.STA),
      0x95: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.STA),
      0x99: Instruction(mode: .absoluteY, cycles: 5, bytes: 3, fn: self.STA),
      0x9D: Instruction(mode: .absoluteX, cycles: 5, bytes: 3, fn: self.STA),
      
      0x86: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.STX),
      0x8E: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.STX),
      0x96: Instruction(mode: .zeroPageY, cycles: 4, bytes: 2, fn: self.STX),
      0x84: Instruction(mode: .zeroPage, cycles: 3, bytes: 2, fn: self.STY),
      0x8C: Instruction(mode: .absolute, cycles: 4, bytes: 3, fn: self.STY),
      0x94: Instruction(mode: .zeroPageX, cycles: 4, bytes: 2, fn: self.STY),
      0xAA: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.TAX),
      0xA8: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.TAY),
      0xBA: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.TSX),
      0x8A: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.TXA),
      0x9A: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.TXS),
      0x98: Instruction(mode: .implied, cycles: 2, bytes: 1, fn: self.TYA)
    ]
    guard let instruction = table[opcode] else {
      fatalError("Unknown opcode: \(opcode)")
    }
    
    return instruction
  }
}
