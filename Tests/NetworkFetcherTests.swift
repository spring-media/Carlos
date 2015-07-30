//
//  NetworkFetcherTests.swift
//  Carlos
//
//  Created by Esad Hajdarevic on 30/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation
import Carlos
import Quick
import Nimble

class NetworkFetcherTests: QuickSpec {
  override func spec() {
    describe("NetworkFetcher") {
      var sut: NetworkFetcher!

      beforeEach {
        sut = NetworkFetcher()
      }

      context("simulatenous requests") {
        var finished = 0
        let simulatenousRequests = 3

        beforeEach {
          let url = NSURL(string:"http://www.google.com/images/logos/google_logo_41.png")!
          let lockQueue = dispatch_queue_create("com.carlos.test", nil)

          for i in 0..<simulatenousRequests {
            sut.get(url).onSuccess({ data in
              dispatch_sync(lockQueue) {
                finished++
              }
            })
          }
        }

        it("should complete all requests") {
          expect(finished).toEventually(equal(simulatenousRequests), timeout: 10)
        }
      }
    }
  }
}
