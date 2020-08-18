import Foundation

import Carlos
import OpenCombine

class CacheLevelFake<A: Hashable, B>: CacheLevel {
  typealias KeyType = A
  typealias OutputType = B
  
  init() {}
  
  // MARK: Get
  
  var numberOfTimesCalledGet = 0
  var didGetKey: KeyType?
  var getSubject: PassthroughSubject<OutputType, Error>?
  var getPublishers: [KeyType: PassthroughSubject<OutputType, Error>] = [:]
  func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    numberOfTimesCalledGet += 1
    didGetKey = key
    
    if let getSubject = getSubject {
      return getSubject.eraseToAnyPublisher()
    }
    
    if let subject = getPublishers[key] {
      return subject.eraseToAnyPublisher()
    }
    
    let newSubject = PassthroughSubject<OutputType, Error>()
    getPublishers[key] = newSubject
    
    return newSubject.eraseToAnyPublisher()
  }
  
  // MARK: Set
  
  var numberOfTimesCalledSet = 0
  var didSetValue: OutputType?
  var didSetKey: KeyType?
  var setSubject: PassthroughSubject<Void, Error>?
  var setPublishers: [KeyType: PassthroughSubject<Void, Error>] = [:]
  func set(_ value: OutputType, forKey key: KeyType) -> AnyPublisher<Void, Error> {
    numberOfTimesCalledSet += 1
    
    didSetKey = key
    didSetValue = value
    
    if let setSubject = setSubject {
      return setSubject.eraseToAnyPublisher()
    }
    
    if let subject = setPublishers[key] {
      return subject.eraseToAnyPublisher()
    }
    
    let newSubject = PassthroughSubject<Void, Error>()
    setPublishers[key] = newSubject
    
    return newSubject.eraseToAnyPublisher()
  }
  
  var numberOfTimesCalledClear = 0
  func clear() {
    numberOfTimesCalledClear += 1
  }
  
  var numberOfTimesCalledOnMemoryWarning = 0
  func onMemoryWarning() {
    numberOfTimesCalledOnMemoryWarning += 1
  }
}
