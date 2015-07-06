//
//  NetworkFetcherTests.swift
//  Carlos
//
//  Created by Monaco, Vittorio on 06/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import UIKit
import XCTest
import Carlos

class NetworkFetcherTests: XCTestCase {
  var sut: NetworkFetcher!
  
  override func setUp() {
    super.setUp()
    
    sut = NetworkFetcher()
  }
  
  func testShouldFailIfURLIsInvalid() {
    sut.get("I'm not a URL (at least I hope so)", onSuccess: { data in
      XCTFail("Should not get here")
    }, onFailure: { error in
      XCTAssertEqual(error!.code, FetchError.InvalidFetchable.rawValue, "Should use the right error")
    })
  }
}
