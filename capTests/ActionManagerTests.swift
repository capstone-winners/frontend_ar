//
//  ActionManagerTests.swift
//  capTests
//
//  Created by Andrew Tu on 2/21/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

import Foundation
import XCTest
@testable import cap

class ActionManagerTests: XCTestCase {
  
  override func setUp() {
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testLightAction() {
    let colorAction = createSetColorAction(deviceType: DeviceType.light, deviceId: Constants.unknownLightId, color: .red)
    actionTestHelperSucceed(description: "color action", action: colorAction)
  }
  
  
}

extension ActionManagerTests {
  
  /**
   Helper function to test an action being called on the succeed path.
   */
  func actionTestHelperSucceed(description: String, action: Action) {
    let exp = expectation(description: description)
    let expectedUrl = ActionManager.actionToUrlString(action)
    let expectedResponse = "action hit" // TODO: Update the expected response??
    let session = sessionFactory(urlString: expectedUrl, data: Data(expectedResponse.utf8))
    let actionManager = ActionManager(session: session)
    
    actionManager.publish(action, completionHandler: { string in
      XCTAssertEqual(string, expectedResponse)
      exp.fulfill()
    })
    
    wait(for: [exp], timeout: 2)
  }
  
  /**
   Creates a mockable session with that will return an expected data when provided with the given url.
   */
  func sessionFactory(urlString: String, data: Data) -> URLSession {
    // this is the URL we expect to call
    let url = URL(string: urlString)

    // attach that to some fixed data in our protocol handler
    URLProtocolStub.testURLs = [url: data]

    // now set up a configuration to use our mock
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [URLProtocolStub.self]

    // and create the URLSession from that
    return URLSession(configuration: config)
  }
}

// MARK: Stub for Protocol calls
class URLProtocolStub: URLProtocol {
    // this dictionary maps URLs to test data
    static var testURLs = [URL?: Data]()

    // say we want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // ignore this method; just send back what we were given
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        // if we have a valid URL…
        if let url = request.url {
            // …and if we have test data for that URL…
            if let data = URLProtocolStub.testURLs[url] {
                // …load it immediately.
                self.client?.urlProtocol(self, didLoad: data)
            }
        }

        // mark that we've finished
        self.client?.urlProtocolDidFinishLoading(self)
    }

    // this method is required but doesn't need to do anything
    override func stopLoading() { }
}
