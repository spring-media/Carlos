//
//  NetworkFetcherTests.swift
//  Carlos
//
//  Created by Esad Hajdarevic on 30/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation
@testable import Carlos
import Quick
import Nimble

class NetworkFetcherTests: QuickSpec {
  override func spec() {
    describe("NetworkFetcher") {
      var sut: NetworkFetcher!

      beforeEach {
        sut = NetworkFetcher()
      }

      context("simultaneous requests") {
        var finished = 0
        let simultaneousRequests = 3

        beforeEach {
          let url = URL(string:"http://www.google.com/images/logos/google_logo_41.png")!
          let lockQueue = DispatchQueue(label: "com.carlos.test")

          for _ in 0..<simultaneousRequests {
            sut.get(url).onSuccess({ data in
              lockQueue.sync() {
                finished += 1
              }
            })
          }
        }

        it("should complete all requests") {
          expect(finished).toEventually(equal(simultaneousRequests), timeout: 10)
        }
      }
    }
  }
}
