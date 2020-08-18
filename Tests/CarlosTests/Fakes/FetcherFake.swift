//
//  FetcherFake.swift
//  
//
//  Created by Lisovyi, Ivan on 17.08.20.
//

import Foundation

import Carlos
import OpenCombine

class FetcherFake<A, B>: Fetcher {
  typealias KeyType = A
  typealias OutputType = B
  
  var queueUsedForTheLastCall: UnsafeMutableRawPointer!
  
  init() {}
  
  var numberOfTimesCalledGet = 0
  var didGetKey: KeyType?
  var getSubject: PassthroughSubject<OutputType, Error>!
  func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    numberOfTimesCalledGet += 1
    
    didGetKey = key
    
    return getSubject.eraseToAnyPublisher()
  }
}
