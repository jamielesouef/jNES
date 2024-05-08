import Foundation

final class CPU {
  let bus: Bus

  private var loop = true
  private var programCounterAtOppcodeRun: UInt16 = 0x00
  private var trace: Bool = false

  private(set) var registers: Registers
  private(set) var PC: UInt16 = 0x00

  typealias RunCallback = (CPUState) -> Void

  enum AddressingMode: String {
    case none
    case absolute
    case absoluteX
    case absoluteY
    case accumulator
    case immediate
    case implied
    case indirect
    case indirectX
    case indirectY
    case relative
    case zeroPage
    case zeroPageX
    case zeroPageY
  }

  init(bus: Bus, registers: Registers = Registers()) {
    self.registers = registers
    self.bus = bus
  }

  func reset() {
    bus.reset()
    registers.reset()
    //    setProgramCounter(0xC000)
  }

  func __tick_with_trace(callback: @escaping RunCallback) {
    trace = true

    tick(buildState: trace) { state in
      callback(state)
    }
  }

  func run(trace: Bool = false, callback: @escaping RunCallback) {
    DispatchQueue.global().async { [weak self] in
      guard let self else { return }
      while loop {
        tick(buildState: trace) { state in
          DispatchQueue.main.async {
            callback(state)
          }
        }
      }
    }
  }

  private func tick(buildState: Bool = false, callback: @escaping RunCallback) {
    let opcode: UInt8 = readMem(at: PC)
    let instruction: Instruction = getInstructions(for: opcode)

    if buildState {
      let state = StateBuilder(cpu: self, instruction: instruction, address: PC).build()
      callback(state)
    }

    let newProgramCounter = PC + 1

    setProgramCounter(newProgramCounter)
    programCounterAtOppcodeRun = newProgramCounter

    instruction.fn()

    // handle(controllerState: controllerState)

    // if the opperation does not change the program counter
    // we need to increment it by the number of bytes in the instruction
    let postOpcodePC = PC

    if programCounterAtOppcodeRun == 0xFFFF {
      loop = false
      return
    }

    if programCounterAtOppcodeRun == postOpcodePC {
      setProgramCounter(postOpcodePC + UInt16(instruction.bytes) - 1)
    }
  }

  func stop() {
    loop = false
    reset()
  }

  func setProgramCounter(_ value: UInt16) {
    PC = value
  }

  func getProgramCounter() -> UInt16 {
    return PC
  }

  func getAddressForOpperateAtPC(with mode: AddressingMode) -> UInt16 {
//    let ptr = PC + 1
    return getAddressForOpperate(with: mode, at: PC)
  }

  func getAddressForOpperate(with mode: AddressingMode, at ptr: UInt16) -> UInt16 {
    switch mode {
    case .absolute, .none:
      return getLittleEndianAddress(at: ptr)

    case .accumulator:
      return UInt16(registers.A)

    case .immediate:
      return ptr

    case .zeroPage:
      return UInt16(bus.readMem(at: ptr))

    case .zeroPageX, .zeroPageY:
      let data: UInt8 = bus.readMem(at: ptr)
      let index = mode == .zeroPageX ? registers.X : registers.Y
      let addr = data &+ index

      return UInt16(addr)

    case .absoluteX, .absoluteY:
      let data = getLittleEndianAddress(at: ptr)
      let offset16 = UInt16(mode == .absoluteX ? registers.X : registers.Y)
      let addr = data &+ offset16
      return addr

    case .indirectX:
      let storedAddress: UInt8 = readMem(at: ptr)
      let addr = storedAddress &+ registers.X

      let lo = UInt16(readMem(at: UInt16(addr)))
      let hi = UInt16(readMem(at: UInt16(addr &+ 1)))
      let ptr = (hi << 8) | lo

      return ptr

    case .indirectY:
      let storedAddress = readMem(at: ptr)

      let lo = readMem(at: UInt16(storedAddress))
      let hi = readMem(at: UInt16(storedAddress &+ 1))

      let pointer = UInt16(hi) << 8 | UInt16(lo)

      return pointer &+ UInt16(registers.Y)

    default: fatalError("Addressing mode: \(mode) not implemented")
    }
  }

  func readMem(at address: UInt16) -> UInt8 {
    bus.readMem(at: address)
  }

  func writeMem(at address: UInt16, value: UInt8) {
    bus.writeMem(at: address, value: value)
  }

  func getLittleEndianAddress(at address: UInt16) -> UInt16 {
    let lo = UInt16(bus.readMem(at: address))
    let hi = UInt16(bus.readMem(at: address + 1))

    let ptr = (hi << 8) | lo
    return ptr
  }

  func stackPush(_ value: UInt8) {
    bus.stackPush(value)
  }

  func stackPop() -> UInt8 {
    bus.stackPop()
  }

  func setStackPointer(_ value: UInt8) {
    bus.setStackPointer(value)
  }

  func getStackPointer() -> UInt8 {
    bus.getStackPointer()
  }
}

private extension CPU {
  // MARK: - Addressing mode

  func handle(controllerState state: UInt8) {
    if state & ControllerButton.left.mask != 0 {
      writeMem(at: 0xFF, value: 0x61)
      print("left written")
      return
    }

    if state & ControllerButton.right.mask != 0 {
      writeMem(at: 0xFF, value: 0x64)
      print("right written")
      return
    }

    if state & ControllerButton.up.mask != 0 {
      writeMem(at: 0xFF, value: 0x77)
      print("up written")
      return
    }

    if state & ControllerButton.down.mask != 0 {
      print("down written")
      writeMem(at: 0xFF, value: 0x73)
      return
    }
  }
}

extension CPU {
  func branch(when condition: Bool) {
    if condition {
      let data = readMem(at: PC)

      let targetAddress = PC &+ (UInt16(data) ^ 0x80) &- 0x80

      setProgramCounter(targetAddress &+ 1)
    }
  }

  func compare(against value: UInt8, mode: AddressingMode) {
    compare(against: Int(value), mode: mode)
  }

  func compare(against value: Int, mode: AddressingMode) {
    let addr = getAddressForOpperate(with: mode, at: PC)
    let data = Int(readMem(at: addr))

    let result = value - data

    setFlag(.negative, condition: ((result >> 7) & 0x1) == 1)
    setFlag(.zero, condition: result == 0)
    setFlag(.carry, condition: value >= data)
  }

  func setRegisterA(_ value: UInt8) {
    registers.set(.A, to: value)

    setFlag(.negative, condition: (registers.A >> 7) == 1)
    setFlag(.zero, condition: registers.A == 0)
  }

  // MARK: - Set flag Functions

  func setFlag(_ flag: Registers.StatusFlag, condition: Bool) {
    if condition {
      registers.set(flag)
    } else {
      registers.clear(flag)
    }
  }

  func setCarryFlag(_ set: Bool) {
    if set {
      registers.set(.carry)
    } else {
      registers.clear(.carry)
    }
  }

  func setCarryFlag(_ value: UInt8) {
    setCarryFlag(value >> 7 == 1)
  }

  func setZeroFlag(_ condition: Bool) {
    if condition {
      registers.set(.zero)
    } else {
      registers.clear(.zero)
    }
  }

  func setZeroFlag(_ value: UInt8) {
    setZeroFlag(value == 0)
  }

  func setOverflowFlag(_ condition: Bool) {
    if condition {
      registers.set(.overflow)
    } else {
      registers.clear(.overflow)
    }
  }

  func setOverflowFlag(_ value: UInt8) {
    setOverflowFlag((value & 1 << 6) != 0)
  }

  func setNegativeFlag(_ condition: Bool) {
    if condition {
      registers.set(.negative)
    } else {
      registers.clear(.negative)
    }
  }

  func setNegativeFlag(_ value: UInt8) {
    setNegativeFlag(value >> 7 == 1)
  }
}
