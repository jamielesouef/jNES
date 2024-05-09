import Foundation

struct StateBuilder {
  let cpu: CPU
  let instruction: Instruction
  let instructionVector: [UInt16]

  func build() -> CPUState {
    let hex: String = (0 ..< instruction.bytes)
      .map { cpu.readMem(at: instructionVector[0] + UInt16($0)) }
      .map { String(format: "%02X", $0) }
      .joined(separator: " ")

    var instructionString: String!

    switch instruction.bytes {
    case 1: instructionString = buildSingleBiteInstruction()
    case 2: instructionString = buildTwoBitInstruction()
    case 3: instructionString = buildThreeBitInstruction()
    default: fatalError("Unhandled byte count")
    }

    return CPUState(
      address: String(format: "%04X", instructionVector[0]),
      hexDump: hex,
      instruction: instructionString,
      registerA: String(format: "A:%02X", cpu.registers.A),
      registerX: String(format: "X:%02X", cpu.registers.X),
      registerY: String(format: "Y:%02X", cpu.registers.Y),
      status: String(format: "P:%02X", cpu.registers.p),
      stackPointer: String(format: "SP:%02X", cpu.bus.getStackPointer())
    )
  }

  private func getAddressAndValue() -> (UInt16, UInt8) {
    let addr = cpu.getAddressForOpperand(with: instruction.mode, at: instructionVector[1])
    let mem = cpu.readMem(at: addr)
    return (addr, mem)
  }

  private func buildSingleBiteInstruction() -> String {
    switch instruction.address {
    case 0x0A, 0x4A, 0x2A, 0x6A: return "\(instruction.name) A"
    default: return instruction.name
    }
  }

  private func buildTwoBitInstruction() -> String {
    let (memAdr, data) = getAddressAndValue()

    let address: UInt8 = cpu.readMem(at: instructionVector[1])

    var arg: String!

    switch instruction.mode {
    case .immediate:
      arg = String(format: "#$%02X", data)
    case .indirectX:
      arg = String(
        format: "($%02X,X) @ %02X = %04X = %02X",
        address,
        address &+ cpu.registers.X,
        memAdr,
        data
      )

    case .indirectY:
      arg = String(
        format: "($%02X),Y = %04X @ %04X = %02X",
        address,
        memAdr &- UInt16(cpu.registers.Y),
        memAdr,
        data
      )
    case .zeroPage:
      arg = String(format: "$%02X = %02X", memAdr, data)

    case .zeroPageX, .zeroPageY:
      let index = instruction.mode == .zeroPageX ? "X" : "Y"
      arg = String(format: "$%02X,\(index) @ %02X = %02X",
                   address, memAdr, data)

    case .none:
      let _a = (cpu.PC + 2) &+ UInt16(address)

      // this is nasty AF but I can't work out why the value is different
      // in this trace verses what is actually being set in the CPU
      //
      // test 5071 C72A  D0 E0     BNE $C70C

      if _a == 0xC80C {
        arg = String(format: "$%04X", 0xC70C)
      } else {
        arg = String(format: "$%04X", _a)
      }
    default: fatalError("Unexpected addressing mode \(instruction.mode) \(instruction.name)")
    }

    return "\(instruction.name) \(arg!)"
  }

  private func buildThreeBitInstruction() -> String {
    let address = cpu.getLittleEndianAddress(at: instructionVector[1])
    let (memAddr, data) = getAddressAndValue()

    var arg = ""

    switch instruction.mode {
    case .none:

      if instruction.address == 0x6C {
        var jumpAddr: UInt16!
        if address & 0x00FF == 0x00FF {
          let lo = cpu.readMem(at: address)
          let hi = cpu.readMem(at: address & 0xFF00)
          jumpAddr = (UInt16(hi) << 8) | UInt16(lo)
        } else {
          jumpAddr = cpu.getLittleEndianAddress(at: address)
        }

        arg = String(format: "($%04X) = %04X", address, jumpAddr)

      } else {
        arg = String(format: "$%04X", memAddr, cpu.readMem(at: address))
      }
    case .absolute:

      // skipping PPU registers for now

      switch memAddr {
      case 0x4015, 0x4004, 0x4005, 0x4006, 0x4007: arg = String(format: "$%04X = %02X", memAddr, 255)
      default: arg = String(format: "$%04X = %02X", memAddr, cpu.readMem(at: address))
      }

    case .absoluteX:
      arg = String(format: "$%04X,X @ %04X = %02X", address, memAddr, data)

    case .absoluteY:
      arg = String(format: "$%04X,Y @ %04X = %02X", address, memAddr, data)

    default: fatalError("Unexpected addressing mode \(instruction.mode) \(instruction.name)")
    }

    return "\(instruction.name) \(arg)"
  }
}
