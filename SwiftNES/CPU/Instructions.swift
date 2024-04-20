//
//  Instruction.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 10/4/2024.
//

import Foundation

struct Instruction {
  let name: String
  let cycles: UInt8
  let bytes: UInt8
  let fn: () -> Void
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
  func getInstructions(forOpcode opcode: UInt8) ->Instruction {
    
    let table: [UInt8: Instruction] = [
      0x61: Instruction(name: "ADC", cycles: 6, bytes: 2, fn: { self.ADC(mode: .indirectX) }),
      0x65: Instruction(name: "ADC", cycles: 3, bytes: 2, fn: { self.ADC(mode: .zeroPage) }),
      0x69: Instruction(name: "ADC", cycles: 2, bytes: 2, fn: { self.ADC(mode: .immediate) }),
      0x6D: Instruction(name: "ADC", cycles: 4, bytes: 3, fn: { self.ADC(mode: .absolute) }),
      0x71: Instruction(name: "ADC", cycles: 5, bytes: 2, fn: { self.ADC(mode: .indirectY) }),
      0x75: Instruction(name: "ADC", cycles: 4, bytes: 2, fn: { self.ADC(mode: .zeroPageX) }),
      0x79: Instruction(name: "ADC", cycles: 4, bytes: 3, fn: { self.ADC(mode: .absoluteY) }),
      0x7D: Instruction(name: "ADC", cycles: 4, bytes: 3, fn: { self.ADC(mode: .absoluteX) }),
      0x21: Instruction(name: "AND", cycles: 6, bytes: 2, fn: { self.AND(mode: .indirectX) }),
      0x25: Instruction(name: "AND", cycles: 3, bytes: 2, fn: { self.AND(mode: .zeroPage) }),
      0x29: Instruction(name: "AND", cycles: 2, bytes: 2, fn: { self.AND(mode: .immediate) }),
      0x2D: Instruction(name: "AND", cycles: 4, bytes: 3, fn: { self.AND(mode: .absolute) }),
      0x31: Instruction(name: "AND", cycles: 5, bytes: 2, fn: { self.AND(mode: .indirectY) }),
      0x35: Instruction(name: "AND", cycles: 4, bytes: 2, fn: { self.AND(mode: .zeroPageX) }),
      0x39: Instruction(name: "AND", cycles: 4, bytes: 3, fn: { self.AND(mode: .absoluteY) }),
      0x3D: Instruction(name: "AND", cycles: 4, bytes: 3, fn: { self.AND(mode: .absoluteX) }),
      0x06: Instruction(name: "ASL", cycles: 5, bytes: 2, fn: { self.ASL(mode: .zeroPage)}),
      0x0A: Instruction(name: "ASL_accumulator", cycles: 2, bytes: 1, fn: self.ASL_accumulator),
      0x0E: Instruction(name: "ASL", cycles: 6, bytes: 3, fn: { self.ASL(mode: .absolute)}),
      0x16: Instruction(name: "ASL", cycles: 6, bytes: 2, fn: { self.ASL(mode: .zeroPageX)}),
      0x1E: Instruction(name: "ASL", cycles: 7, bytes: 3, fn: { self.ASL(mode: .absoluteX)}),
      0x90: Instruction(name: "BCC", cycles: 2, bytes: 2, fn: self.BCC),
      0xB0: Instruction(name: "BCS", cycles: 2, bytes: 2, fn: self.BCS),
      0xF0: Instruction(name: "BEQ", cycles: 2, bytes: 2, fn: self.BEQ),
      0x24: Instruction(name: "BIT", cycles: 3, bytes: 2, fn: { self.BIT(mode: .zeroPage)}),
      0x2C: Instruction(name: "BIT", cycles: 4, bytes: 3, fn: { self.BIT(mode: .absolute)}),
      0x30: Instruction(name: "BMI", cycles: 2, bytes: 2, fn: self.BMI),
      0xD0: Instruction(name: "BNE", cycles: 2, bytes: 2, fn: self.BNE),
      0x10: Instruction(name: "BPL", cycles: 2, bytes: 2, fn: self.BPL),
      0x00: Instruction(name: "BRK", cycles: 7, bytes: 1, fn: self.BRK),
      0x50: Instruction(name: "BVC", cycles: 2, bytes: 2, fn: self.BVC),
      0x70: Instruction(name: "BVS", cycles: 2, bytes: 2, fn: self.BVS),
      0x18: Instruction(name: "CLC", cycles: 2, bytes: 1, fn: self.CLC),
      0xD8: Instruction(name: "CLD", cycles: 2, bytes: 1, fn: self.CLD),
      0x58: Instruction(name: "CLI", cycles: 2, bytes: 1, fn: self.CLI),
      0xB8: Instruction(name: "CLV", cycles: 2, bytes: 1, fn: self.CLV),
      0xC1: Instruction(name: "CMP", cycles: 6, bytes: 2, fn: { self.CMP(mode: .indirectX)}),
      0xC5: Instruction(name: "CMP", cycles: 3, bytes: 2, fn: { self.CMP(mode: .zeroPage)}),
      0xC9: Instruction(name: "CMP", cycles: 2, bytes: 2, fn: { self.CMP(mode: .immediate)}),
      0xCD: Instruction(name: "CMP", cycles: 4, bytes: 3, fn: { self.CMP(mode: .absolute)}),
      0xD1: Instruction(name: "CMP", cycles: 5, bytes: 2, fn: { self.CMP(mode: .indirectY)}),
      0xD5: Instruction(name: "CMP", cycles: 4, bytes: 2, fn: { self.CMP(mode: .zeroPageX)}),
      0xD9: Instruction(name: "CMP", cycles: 4, bytes: 3, fn: { self.CMP(mode: .absoluteY)}),
      0xDD: Instruction(name: "CMP", cycles: 4, bytes: 3, fn: { self.CMP(mode: .absoluteX)}),
      0xE0: Instruction(name: "CPX", cycles: 2, bytes: 2, fn: { self.CPX(mode: .immediate)}),
      0xE4: Instruction(name: "CPX", cycles: 3, bytes: 2, fn: { self.CPX(mode: .zeroPage)}),
      0xEC: Instruction(name: "CPX", cycles: 4, bytes: 3, fn: { self.CPX(mode: .absolute)}),
      0xC0: Instruction(name: "CPY", cycles: 2, bytes: 2, fn: { self.CPY(mode: .immediate)}),
      0xC4: Instruction(name: "CPY", cycles: 3, bytes: 2, fn: { self.CPY(mode: .zeroPage)}),
      0xCC: Instruction(name: "CPY", cycles: 4, bytes: 3, fn: { self.CPY(mode: .absolute)}),
      0xC6: Instruction(name: "DEC", cycles: 5, bytes: 2, fn: { self.DEC(mode: .zeroPage)}),
      0xCE: Instruction(name: "DEC", cycles: 6, bytes: 3, fn: { self.DEC(mode: .absolute)}),
      0xD6: Instruction(name: "DEC", cycles: 6, bytes: 2, fn: { self.DEC(mode: .zeroPageX)}),
      0xDE: Instruction(name: "DEC", cycles: 7, bytes: 3, fn: { self.DEC(mode: .absoluteX)}),
      0xCA: Instruction(name: "DEX", cycles: 2, bytes: 1, fn: self.DEX),
      0x88: Instruction(name: "DEY", cycles: 2, bytes: 1, fn: self.DEY),
      0x41: Instruction(name: "EOR", cycles: 6, bytes: 2, fn: { self.EOR(mode: .indirectX)}),
      0x45: Instruction(name: "EOR", cycles: 3, bytes: 2, fn: { self.EOR(mode: .zeroPage)}),
      0x49: Instruction(name: "EOR", cycles: 2, bytes: 2, fn: { self.EOR(mode: .immediate)}),
      0x4D: Instruction(name: "EOR", cycles: 4, bytes: 3, fn: { self.EOR(mode: .absolute)}),
      0x51: Instruction(name: "EOR", cycles: 5, bytes: 2, fn: { self.EOR(mode: .indirectY)}),
      0x55: Instruction(name: "EOR", cycles: 4, bytes: 2, fn: { self.EOR(mode: .zeroPageX)}),
      0x59: Instruction(name: "EOR", cycles: 4, bytes: 3, fn: { self.EOR(mode: .absoluteY)}),
      0x5D: Instruction(name: "EOR", cycles: 4, bytes: 3, fn: { self.EOR(mode: .absoluteX)}),
      0xE6: Instruction(name: "INC", cycles: 5, bytes: 2, fn: { self.INC(mode: .zeroPage)}),
      0xEE: Instruction(name: "INC", cycles: 6, bytes: 3, fn: { self.INC(mode: .absolute)}),
      0xF6: Instruction(name: "INC", cycles: 6, bytes: 2, fn: { self.INC(mode: .zeroPageX)}),
      0xFE: Instruction(name: "INC", cycles: 7, bytes: 3, fn: { self.INC(mode: .absoluteX)}),
      0xE8: Instruction(name: "INX", cycles: 2, bytes: 1, fn: self.INX),
      0xC8: Instruction(name: "INY", cycles: 2, bytes: 1, fn: self.INY),
      0x4C: Instruction(name: "JMP", cycles: 3, bytes: 3, fn: self.JMP),
      0x6C: Instruction(name: "JMP", cycles: 5, bytes: 3, fn: self.JMP_indirect),
      0x20: Instruction(name: "JSR", cycles: 6, bytes: 3, fn: self.JSR),
      0xA1: Instruction(name: "LDA", cycles: 6, bytes: 2, fn: { self.LDA(mode: .indirectX)}),
      0xA5: Instruction(name: "LDA", cycles: 3, bytes: 2, fn: { self.LDA(mode: .zeroPage)}),
      0xA9: Instruction(name: "LDA", cycles: 2, bytes: 2, fn: { self.LDA(mode: .immediate)}),
      0xAD: Instruction(name: "LDA", cycles: 4, bytes: 3, fn: { self.LDA(mode: .absolute)}),
      0xB1: Instruction(name: "LDA", cycles: 5, bytes: 2, fn: { self.LDA(mode: .indirectY)}),
      0xB5: Instruction(name: "LDA", cycles: 4, bytes: 2, fn: { self.LDA(mode: .zeroPageX)}),
      0xB9: Instruction(name: "LDA", cycles: 4, bytes: 3, fn: { self.LDA(mode: .absoluteY)}),
      0xBD: Instruction(name: "LDA", cycles: 4, bytes: 3, fn: { self.LDA(mode: .absoluteX)}),
      0xA2: Instruction(name: "LDX", cycles: 2, bytes: 2, fn: { self.LDX(mode: .immediate)}),
      0xA6: Instruction(name: "LDX", cycles: 3, bytes: 2, fn: { self.LDX(mode: .zeroPage)}),
      0xAE: Instruction(name: "LDX", cycles: 4, bytes: 3, fn: { self.LDX(mode: .absolute)}),
      0xB6: Instruction(name: "LDX", cycles: 4, bytes: 2, fn: { self.LDX(mode: .zeroPageY)}),
      0xBE: Instruction(name: "LDX", cycles: 4, bytes: 3, fn: { self.LDX(mode: .absoluteY)}),
      0xA0: Instruction(name: "LDY", cycles: 2, bytes: 2, fn: { self.LDY(mode: .immediate)}),
      0xA4: Instruction(name: "LDY", cycles: 3, bytes: 2, fn: { self.LDY(mode: .zeroPage)}),
      0xAC: Instruction(name: "LDY", cycles: 4, bytes: 3, fn: { self.LDY(mode: .absolute)}),
      0xB4: Instruction(name: "LDY", cycles: 4, bytes: 2, fn: { self.LDY(mode: .zeroPageX)}),
      0xBC: Instruction(name: "LDY", cycles: 4, bytes: 3, fn: { self.LDY(mode: .absoluteX)}),
      0x46: Instruction(name: "LSR", cycles: 5, bytes: 2, fn: { self.LSR(mode: .zeroPage)}),
      0x4A: Instruction(name: "LSR_accumulator", cycles: 2, bytes: 1, fn: self.LSR_accumulator),
      0x4E: Instruction(name: "LSR", cycles: 6, bytes: 3, fn: { self.LSR(mode: .absolute)}),
      0x56: Instruction(name: "LSR", cycles: 6, bytes: 2, fn: { self.LSR(mode: .zeroPageX)}),
      0x5E: Instruction(name: "LSR", cycles: 7, bytes: 3, fn: { self.LSR(mode: .absoluteX)}),
      0xEA: Instruction(name: "NOP", cycles: 2, bytes: 1, fn: self.NOP),
      0x01: Instruction(name: "ORA", cycles: 6, bytes: 2, fn: { self.ORA(mode: .indirectX)}),
      0x05: Instruction(name: "ORA", cycles: 3, bytes: 2, fn: { self.ORA(mode: .zeroPage)}),
      0x09: Instruction(name: "ORA", cycles: 2, bytes: 2, fn: { self.ORA(mode: .immediate)}),
      0x0D: Instruction(name: "ORA", cycles: 4, bytes: 3, fn: { self.ORA(mode: .absolute)}),
      0x11: Instruction(name: "ORA", cycles: 5, bytes: 2, fn: { self.ORA(mode: .indirectY)}),
      0x15: Instruction(name: "ORA", cycles: 4, bytes: 2, fn: { self.ORA(mode: .zeroPageX)}),
      0x19: Instruction(name: "ORA", cycles: 4, bytes: 3, fn: { self.ORA(mode: .absoluteY)}),
      0x1D: Instruction(name: "ORA", cycles: 4, bytes: 3, fn: { self.ORA(mode: .absoluteX)}),
      0x48: Instruction(name: "PHA", cycles: 3, bytes: 1, fn: self.PHA),
      0x08: Instruction(name: "PHP", cycles: 3, bytes: 1, fn: self.PHP),
      0x68: Instruction(name: "PLA", cycles: 4, bytes: 1, fn: self.PLA),
      0x28: Instruction(name: "PLP", cycles: 4, bytes: 1, fn: self.PLP),
      0x26: Instruction(name: "ROL", cycles: 5, bytes: 2, fn: { self.ROL(mode: .zeroPage)}),
      0x2A: Instruction(name: "ROL_accumulator", cycles: 2, bytes: 1, fn: self.ROL_accumulator),
      0x2E: Instruction(name: "ROL", cycles: 6, bytes: 3, fn: { self.ROL(mode: .absolute)}),
      0x36: Instruction(name: "ROL", cycles: 6, bytes: 2, fn: { self.ROL(mode: .zeroPageX)}),
      0x3E: Instruction(name: "ROL", cycles: 7, bytes: 3, fn: { self.ROL(mode: .absoluteX)}),
      0x66: Instruction(name: "ROR", cycles: 5, bytes: 2, fn: { self.ROR(mode: .zeroPage)}),
      0x6A: Instruction(name: "ROR_accumulator", cycles: 2, bytes: 1, fn: self.ROR_accumulator),
      0x6E: Instruction(name: "ROR", cycles: 6, bytes: 3, fn: { self.ROR(mode: .absolute)}),
      0x76: Instruction(name: "ROR", cycles: 6, bytes: 2, fn: { self.ROR(mode: .zeroPageX)}),
      0x7E: Instruction(name: "ROR", cycles: 7, bytes: 3, fn: { self.ROR(mode: .absoluteX)}),
      0x40: Instruction(name: "RTI", cycles: 6, bytes: 1, fn: self.RTI),
      0x60: Instruction(name: "RTS", cycles: 6, bytes: 1, fn: self.RTS),
      0xE1: Instruction(name: "SBC", cycles: 6, bytes: 2, fn: { self.SBC(mode: .indirectX)}),
      0xE5: Instruction(name: "SBC", cycles: 3, bytes: 2, fn: { self.SBC(mode: .zeroPage)}),
      0xE9: Instruction(name: "SBC", cycles: 2, bytes: 2, fn: { self.SBC(mode: .immediate)}),
      0xED: Instruction(name: "SBC", cycles: 4, bytes: 3, fn: { self.SBC(mode: .absolute)}),
      0xF1: Instruction(name: "SBC", cycles: 5, bytes: 2, fn: { self.SBC(mode: .indirectY)}),
      0xF5: Instruction(name: "SBC", cycles: 4, bytes: 2, fn: { self.SBC(mode: .zeroPageX)}),
      0xF9: Instruction(name: "SBC", cycles: 4, bytes: 3, fn: { self.SBC(mode: .absoluteY)}),
      0xFD: Instruction(name: "SBC", cycles: 4, bytes: 3, fn: { self.SBC(mode: .absoluteX)}),
      0x38: Instruction(name: "SEC", cycles: 2, bytes: 1, fn: self.SEC),
      0xF8: Instruction(name: "SED", cycles: 2, bytes: 1, fn: self.SED),
      0x78: Instruction(name: "SEI", cycles: 2, bytes: 1, fn: self.SEI),
      0x81: Instruction(name: "STA", cycles: 6, bytes: 2, fn: { self.STA(mode: .indirectX)}),
      0x85: Instruction(name: "STA", cycles: 3, bytes: 2, fn: { self.STA(mode: .zeroPage)}),
      0x8D: Instruction(name: "STA", cycles: 4, bytes: 3, fn: { self.STA(mode: .absolute)}),
      0x91: Instruction(name: "STA", cycles: 6, bytes: 2, fn: { self.STA(mode: .indirectY)}),
      0x95: Instruction(name: "STA", cycles: 4, bytes: 2, fn: { self.STA(mode: .zeroPageX)}),
      0x99: Instruction(name: "STA", cycles: 5, bytes: 3, fn: { self.STA(mode: .absoluteY)}),
      0x9D: Instruction(name: "STA", cycles: 5, bytes: 3, fn: { self.STA(mode: .absoluteX)}),
      0x86: Instruction(name: "STX", cycles: 3, bytes: 2, fn: { self.STX(mode: .zeroPage)}),
      0x8E: Instruction(name: "STX", cycles: 4, bytes: 3, fn: { self.STX(mode: .absolute)}),
      0x96: Instruction(name: "STX", cycles: 4, bytes: 2, fn: { self.STX(mode: .zeroPageY)}),
      0x84: Instruction(name: "STY", cycles: 3, bytes: 2, fn: { self.STY(mode: .zeroPage)}),
      0x8C: Instruction(name: "STY", cycles: 4, bytes: 3, fn: { self.STY(mode: .absolute)}),
      0x94: Instruction(name: "STY", cycles: 4, bytes: 2, fn: { self.STY(mode: .zeroPageX)}),
      0xAA: Instruction(name: "TAX", cycles: 2, bytes: 1, fn: self.TAX),
      0xA8: Instruction(name: "TAY", cycles: 2, bytes: 1, fn: self.TAY),
      0xBA: Instruction(name: "TSX", cycles: 2, bytes: 1, fn: self.TSX),
      0x8A: Instruction(name: "TXA", cycles: 2, bytes: 1, fn: self.TXA),
      0x9A: Instruction(name: "TXS", cycles: 2, bytes: 1, fn: self.TXS),
      0x98: Instruction(name: "TYA", cycles: 2, bytes: 1, fn: self.TYA),
    ]
    
    guard let instruction = table[opcode] else {
      fatalError("Unknown opcode: \(opcode)")
    }
    
    return instruction
  }
}
