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
    helperTestFullData(dummyAbstractData())
  }
  
  func testDecodeLightData() {
    helperTestFullData(dummyLightData())
  }
  
  func testDecodeClimateData() {
    helperTestFullData(dummyClimateData())
  }
  
  func testDecodeLockData() {
    helperTestFullData(dummyLockData())
  }
  
  func testDecodeMusicData() {
    helperTestFullData(dummyMusicData())
  }
  
  /**
   If the manager attempts to decode a nil anchor, return a nil obj.
   */
  func testDecodeNilData() {
    let obj = manager.decode(anchor: nil)
    XCTAssert(obj == nil)
  }
  
  /**
   If the manager receives a bad json file, return nil.
   */
  func testDecodeBadDeviceType() {
    let badJson = """
    {\"isOn\":true,\"brightness\":0.01999,\"color\":{\"r\":0,\"g\":0,\"b\":0,\"a\":1},\"super\":{\"status\":\"ok\",\"deviceId\":\"Vibe Check \",\"deviceType\":\"lightbulb\",\"location\":\"Trap House\",\"group\":\"Toms Room\"}}

    """
    
    let obj = manager.decode(jsonString: badJson)
    XCTAssert(obj == nil)
  }
  
  /**
   Another version of the bad json where the nested super json is bad.
   */
  func testDecodeBadSuperType() {
    let badJson = """

    {\"isOn\":true,\"brightness\":0.01999,\"color\":{\"r\":0,\"g\":0,\"b\":0,\"a\":1},\"super\":10}

    """
    
    let obj = manager.decode(jsonString: badJson)
    XCTAssert(obj == nil)
  }
  
  func testPrint(){
    print("Abstract:")
    print(dummyAbstractData().toJSONString())
    print("\n\n")
    print("Lock:")
    print(dummyLockData().toJSONString())
    print("\n\n")
    print("Light:")
    print(dummyLightData().toJSONString())
    print("\n\n")
    print("Climate:")
    print(dummyClimateData().toJSONString())
    print("\n\n")
    print("Music:")
    print(dummyMusicData().toJSONString())
  }
}

extension IotDataManagerTests {
  func helperTestDeviceType(_ jsonString: String, expected: DeviceType?) {
    XCTAssertEqual(manager.getType(jsonDict: jsonString), expected)
  }
  
  func helperTestUdid(_ jsonString: String, expected: String?) {
    XCTAssertEqual(manager.getUdid(jsonString), expected)
  }
  
  func helperTestId(_ jsonString: String, expected: String?) {
    XCTAssertEqual(manager.getId(jsonString: jsonString), expected)
  }
  
  func helperTestDecode(_ jsonString: String, expected: String?) {
    XCTAssertEqual(manager.decode(jsonString: jsonString)?.toJSONString(), expected)
  }
  
  func helperTestFullData(_ deviceData: DeviceData) {
    let jsonString = deviceData.toJSONString()
    let deviceType = deviceData.deviceType
    let deviceId = deviceData.deviceId
    
    helperTestDeviceType(jsonString, expected: deviceType)
    helperTestId(jsonString, expected: deviceId)
    helperTestUdid(jsonString, expected: "\(deviceType)\(deviceId)")
    helperTestDecode(jsonString, expected: deviceData.toJSONString())
  }
}
