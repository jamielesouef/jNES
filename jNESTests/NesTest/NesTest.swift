//
//  NesTest.swift
//  jNESTests
//
//  Created by Jamie Le Souef on 3/5/2024.
//

import XCTest
@testable import jNES

final class NesTest: XCTestCase {
  var nestest: [CPUState]!
  override func setUpWithError() throws {
    // load nestest_no_clock.log file
    let path = Bundle(for: type(of: self)).path(forResource: "nestest_no_clock", ofType: "log")
    //split by new line
    let data = try String(contentsOfFile: path!, encoding: .utf8).split(whereSeparator: \.isNewline)
    nestest = try data.map { try CPUState(string: String($0)) }
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  
  // test the first row of the nestest_no_clock.log file
  func testFirstRow() throws {
    let firstRow = nestest[0]
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
    
    var trace = [CPUState]()
    cpu.reset()
    cpu.__run_with_trace {
      trace.append($0)
    }
  
    let expectation = XCTestExpectation(description: "Waiting for CPU to finish")
    DispatchQueue.main.asyncAfter(deadline: .now() + 5 ) {
      XCTAssertEqual(trace.count, self.nestest.count)
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5)
    

  }
}
