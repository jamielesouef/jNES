//
//  NesTest.swift
//  jNESTests
//
//  Created by Jamie Le Souef on 3/5/2024.
//

@testable import jNES
import XCTest

final class NesTest: XCTestCase {
  var exptectedNesTestResult: [CPUState]!
  override func setUpWithError() throws {
    continueAfterFailure = false

    // load nestest_no_clock.log file
    let path = Bundle(for: type(of: self)).path(forResource: "nestest_no_clock", ofType: "log")
    // split by new line
    let data = try String(contentsOfFile: path!, encoding: .utf8).split(whereSeparator: \.isNewline)
    exptectedNesTestResult = try data.map { try CPUState(string: String($0)) }
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  // test the first row of the nestest_no_clock.log file
  func testFirstRow() throws {
    let firstRow = exptectedNesTestResult[0]
    XCTAssertEqual(firstRow.address, "C000")
    XCTAssertEqual(firstRow.hexDump, "4C F5 C5")
    XCTAssertEqual(firstRow.instruction, "JMP $C5F5")
    XCTAssertEqual(firstRow.registerA, "A:00")
    XCTAssertEqual(firstRow.registerX, "X:00")
    XCTAssertEqual(firstRow.registerY, "Y:00")
    XCTAssertEqual(firstRow.status, "P:24")
    XCTAssertEqual(firstRow.stackPointer, "SP:FD")
  }

  func testRunningNesTest() throws {
    let file = Bundle.main.url(forResource: "nestest", withExtension: "nes")!
    let data = try Data(contentsOf: file)

    let rom = try Rom(data: [UInt8](data))

    let bus = Bus(rom: rom)
    let cpu = CPU(bus: bus)

    cpu.reset()
    cpu.setProgramCounter(0xC000)

    for i in 0 ..< exptectedNesTestResult.count {
      var r: CPUState!
      let e = exptectedNesTestResult[i]
//      print(i, e.address)
      cpu.__tick_with_trace { r = $0 }

      test(e.address, r.address, e.address, i)
      test(e.address, r.hexDump, e.hexDump, i)
      test(e.address, r.instruction, e.instruction, i)
      test(e.address, r.registerA, e.registerA, i)
      test(e.address, r.registerX, e.registerX, i)
      test(e.address, r.registerY, e.registerY, i)
      test(e.address, r.status, e.status, i)
      test(e.address, r.stackPointer, e.stackPointer, i)
    }
  }

  func test(_: String, _ actual: String, _ expected: String, _ line: Int) {
    let m = "\n xpt:\t \(expected)\n got:\t \(actual) (@\(line + 1))"
    XCTAssertEqual(expected, actual, m)
  }
}
