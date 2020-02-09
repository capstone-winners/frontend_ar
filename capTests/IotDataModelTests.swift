//
//  IotDataModelTests.swift
//  capTests
//
//  Created by Andrew Tu on 2/8/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import XCTest
@testable import cap

class IotDataManagerTests: XCTestCase {
  
  var manager : IotDataManager!
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    manager = IotDataManager()
    
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testDecodeDeviceData() {
    let obj = manager.decode(jsonString: dummyAbstractData().toJSONString())
    XCTAssertEqual(obj?.toJSONString(), dummyAbstractData().toJSONString())
  }
  
  func testDecodeLightData() {
    let obj = manager.decode(jsonString: dummyLightData().toJSONString())
    XCTAssertEqual(obj?.toJSONString(), dummyLightData().toJSONString())
  }
  
  func testDecodeClimateData() {
    let obj = manager.decode(jsonString: dummyClimateData().toJSONString())
    XCTAssertEqual(obj?.toJSONString(), dummyClimateData().toJSONString())
  }
  
  func testDecodeLockData() {
    let obj = manager.decode(jsonString: dummyLockData().toJSONString())
    XCTAssertEqual(obj?.toJSONString(), dummyLockData().toJSONString())
  }
  
  func testDecodeNilData() {
    let obj = manager.decode(anchor: nil)
    XCTAssert(obj == nil)
  }
  
  func testDecodeBadDeviceType() {
    let badJson = """
    {\"isOn\":true,\"brightness\":0.01999,\"color\":{\"r\":0,\"g\":0,\"b\":0,\"a\":1},\"super\":{\"status\":\"ok\",\"deviceId\":\"Vibe Check \",\"deviceType\":\"lightbulb\",\"location\":\"Trap House\",\"group\":\"Toms Room\"}}

    """
    
    let obj = manager.decode(jsonString: badJson)
    XCTAssert(obj == nil)
  }
  
  func testDecodeBadSuperType() {
    let badJson = """

    {\"isOn\":true,\"brightness\":0.01999,\"color\":{\"r\":0,\"g\":0,\"b\":0,\"a\":1},\"super\":10}

    """
    
    let obj = manager.decode(jsonString: badJson)
    XCTAssert(obj == nil)
  }
  
  func testDummyLightData() {
    let obj = manager.decode(jsonString: dummyLightData().toJSONString())
    XCTAssert(manager.getUdid(dummyLightData().toJSONString()) != nil)
    
  }
  
  func testPrint(){
    print(dummyLockData().toJSONString())
    print(dummyLightData().toJSONString())
    print(dummyClimateData().toJSONString())
    print(dummyAbstractData().toJSONString())
  }
}
