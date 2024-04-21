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

enum Instructions: UInt8 {
  case ADC_0x61 = 0x61
  case ADC_0x65 = 0x65
  case ADC_0x69 = 0x69
  case ADC_0x6D = 0x6D
  case ADC_0x71 = 0x71
  case ADC_0x75 = 0x75
  case ADC_0x79 = 0x79
  case ADC_0x7D = 0x7D
  case AND_0x21 = 0x21
  case AND_0x25 = 0x25
  case AND_0x29 = 0x29
  case AND_0x2D = 0x2D
  case AND_0x31 = 0x31
  case AND_0x35 = 0x35
  case AND_0x39 = 0x39
  case AND_0x3D = 0x3D
  case ASL_0x06 = 0x06
  case ASL_accumulator_0x0A = 0x0A
  case ASL_0x0E = 0x0E
  case ASL_0x16 = 0x16
  case ASL_0x1E = 0x1E
  case BCC_0x90 = 0x90
  case BCS_0xB0 = 0xB0
  case BEQ_0xF0 = 0xF0
  case BIT_0x24 = 0x24
  case BIT_0x2C = 0x2C
  case BMI_0x30 = 0x30
  case BNE_0xD0 = 0xD0
  case BPL_0x10 = 0x10
  case BRK_0x00 = 0x00
  case BVC_0x50 = 0x50
  case BVS_0x70 = 0x70
  case CLC_0x18 = 0x18
  case CLD_0xD8 = 0xD8
  case CLI_0x58 = 0x58
  case CLV_0xB8 = 0xB8
  case CMP_0xC1 = 0xC1
  case CMP_0xC5 = 0xC5
  case CMP_0xC9 = 0xC9
  case CMP_0xCD = 0xCD
  case CMP_0xD1 = 0xD1
  case CMP_0xD5 = 0xD5
  case CMP_0xD9 = 0xD9
  case CMP_0xDD = 0xDD
  case CPX_0xE0 = 0xE0
  case CPX_0xE4 = 0xE4
  case CPX_0xEC = 0xEC
  case CPY_0xC0 = 0xC0
  case CPY_0xC4 = 0xC4
  case CPY_0xCC = 0xCC
  case DEC_0xC6 = 0xC6
  case DEC_0xCE = 0xCE
  case DEC_0xD6 = 0xD6
  case DEC_0xDE = 0xDE
  case DEX_0xCA = 0xCA
  case DEY_0x88 = 0x88
  case EOR_0x41 = 0x41
  case EOR_0x45 = 0x45
  case EOR_0x49 = 0x49
  case EOR_0x4D = 0x4D
  case EOR_0x51 = 0x51
  case EOR_0x55 = 0x55
  case EOR_0x59 = 0x59
  case EOR_0x5D = 0x5D
  case INC_0xE6 = 0xE6
  case INC_0xEE = 0xEE
  case INC_0xF6 = 0xF6
  case INC_0xFE = 0xFE
  case INX_0xE8 = 0xE8
  case INY_0xC8 = 0xC8
  case JMP_0x4C = 0x4C
  case JMP_0x6C = 0x6C
  case JSR_0x20 = 0x20
  
  case LDA_0xA1 = 0xA1
  case LDA_0xA5 = 0xA5
  case LDA_0xA9 = 0xA9
  case LDA_0xAD = 0xAD
  case LDA_0xB1 = 0xB1
  case LDA_0xB5 = 0xB5
  case LDA_0xB9 = 0xB9
  case LDA_0xBD = 0xBD
  
  case LDX_0xA2 = 0xA2
  case LDX_0xA6 = 0xA6
  case LDX_0xAE = 0xAE
  case LDX_0xB6 = 0xB6
  case LDX_0xBE = 0xBE
  case LDY_0xA0 = 0xA0
  case LDY_0xA4 = 0xA4
  case LDY_0xAC = 0xAC
  case LDY_0xB4 = 0xB4
  case LDY_0xBC = 0xBC
  case LSR_0x46 = 0x46
  case LSR_accumulator_0x4A = 0x4A
  case LSR_0x4E = 0x4E
  case LSR_0x56 = 0x56
  case LSR_0x5E = 0x5E
  case NOP_0xEA = 0xEA
  case ORA_0x01 = 0x01
  case ORA_0x05 = 0x05
  case ORA_0x09 = 0x09
  case ORA_0x0D = 0x0D
  case ORA_0x11 = 0x11
  case ORA_0x15 = 0x15
  case ORA_0x19 = 0x19
  case ORA_0x1D = 0x1D
  case PHA_0x48 = 0x48
  case PHP_0x08 = 0x08
  case PLA_0x68 = 0x68
  case PLP_0x28 = 0x28
  case ROL_0x26 = 0x26
  case ROL_accumulator_0x2A = 0x2A
  case ROL_0x2E = 0x2E
  case ROL_0x36 = 0x36
  case ROL_0x3E = 0x3E
  case ROR_0x66 = 0x66
  case ROR_accumulator_0x6A = 0x6A
  case ROR_0x6E = 0x6E
  case ROR_0x76 = 0x76
  case ROR_0x7E = 0x7E
  case RTI_0x40 = 0x40
  case RTS_0x60 = 0x60
  case SBC_0xE1 = 0xE1
  case SBC_0xE5 = 0xE5
  case SBC_0xE9 = 0xE9
  case SBC_0xED = 0xED
  case SBC_0xF1 = 0xF1
  case SBC_0xF5 = 0xF5
  case SBC_0xF9 = 0xF9
  case SBC_0xFD = 0xFD
  case SEC_0x38 = 0x38
  case SED_0xF8 = 0xF8
  case SEI_0x78 = 0x78
  case STA_0x81 = 0x81
  case STA_0x85 = 0x85
  case STA_0x8D = 0x8D
  case STA_0x91 = 0x91
  case STA_0x95 = 0x95
  case STA_0x99 = 0x99
  case STA_0x9D = 0x9D
  case STX_0x86 = 0x86
  case STX_0x8E = 0x8E
  case STX_0x96 = 0x96
  case STY_0x84 = 0x84
  case STY_0x8C = 0x8C
  case STY_0x94 = 0x94
  case TAX_0xAA = 0xAA
  case TAY_0xA8 = 0xA8
  case TSX_0xBA = 0xBA
  case TXA_0x8A = 0x8A
  case TXS_0x9A = 0x9A
  case TYA_0x98 = 0x98
}



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
      0x00: Instruction(name: "BRK", cycles: 7, bytes: 1, fn: {}), //self.BRK),
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
      
      0x85: Instruction(name: "STA", cycles: 3, bytes: 2, fn: { self.STA(mode: .zeroPage)}),
      0x95: Instruction(name: "STA", cycles: 4, bytes: 2, fn: { self.STA(mode: .zeroPageX)}),
      0x8D: Instruction(name: "STA", cycles: 4, bytes: 3, fn: { self.STA(mode: .absolute)}),
      0x9D: Instruction(name: "STA", cycles: 5, bytes: 3, fn: { self.STA(mode: .absoluteX)}),
      0x99: Instruction(name: "STA", cycles: 5, bytes: 3, fn: { self.STA(mode: .absoluteY)}),
      0x81: Instruction(name: "STA", cycles: 6, bytes: 2, fn: { self.STA(mode: .indirectX)}),
      0x91: Instruction(name: "STA", cycles: 6, bytes: 2, fn: { self.STA(mode: .indirectY)}),
      
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
      let code = String(opcode, radix: 16)
      log(memory.getProgramCounter())
      fatalError("Unknown opcode: \(code)")
    }
    
    return instruction
  }
}
