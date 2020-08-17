//
//  NetworkFetcherTests.swift
//  Carlos
//
//  Created by Esad Hajdarevic on 30/07/15.
//  Copyright (c) 2015 WeltN24. All rights reserved.
//

import Foundation

import Quick
import Nimble

import Carlos
import OpenCombine

final class NetworkFetcherTests: QuickSpec {
  override func spec() {
    describe("NetworkFetcher") {
      var sut: NetworkFetcher!
      var cancellables: Set<AnyCancellable>!
      
      beforeEach {
        cancellables = Set<AnyCancellable>()
        sut = NetworkFetcher()
      }
      
      afterEach {
        cancellables = nil
      }
      
      context("simultaneous requests") {
        var finished = 0
        let simultaneousRequests = 3
        
        beforeEach {
          let url = URL(string:"http://www.google.com/images/logos/google_logo_41.png")!
          let lockQueue = DispatchQueue(label: "com.carlos.test")
          
          for _ in 0..<simultaneousRequests {
            sut.get(url).sink(receiveCompletion: { _ in }, receiveValue: { _ in
              lockQueue.sync() {
                finished += 1
              }
            }).store(in: &cancellables)
          }
        }
        
        it("should complete all requests") {
          expect(finished).toEventually(equal(simultaneousRequests), timeout: 10)
        }
      }
    }
  }
}
