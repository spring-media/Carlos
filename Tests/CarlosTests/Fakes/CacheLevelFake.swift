import Foundation

import Carlos
import OpenCombine

class CacheLevelFake<A, B>: CacheLevel {
  typealias KeyType = A
  typealias OutputType = B
  
  init() {}
  
  // MARK: Get
  
  var queueUsedForTheLastCall: UnsafeMutableRawPointer!
  var numberOfTimesCalledGet = 0
  var didGetKey: KeyType?
  var getSubject: PassthroughSubject<OutputType, Error>?
  var getPublishers: [AnyPublisher<OutputType, Error>] = []
  func get(_ key: KeyType) -> AnyPublisher<OutputType, Error> {
    numberOfTimesCalledGet += 1
    
    didGetKey = key
    
    queueUsedForTheLastCall = currentQueueSpecific()
    
    let publisher: AnyPublisher<OutputType, Error>
    
    if let subject = getSubject {
      publisher = subject.eraseToAnyPublisher()
    } else {
      getSubject = PassthroughSubject()
      publisher = getSubject!.eraseToAnyPublisher()
    }
    
    getPublishers.append(publisher)
    
    return publisher
  }
  
  // MARK: Set
  
  var numberOfTimesCalledSet = 0
  var didSetValue: OutputType?
  var didSetKey: KeyType?
  var setSubject: PassthroughSubject<Void, Error>?
  var setPublishers: [AnyPublisher<Void, Error>] = []
  func set(_ value: OutputType, forKey key: KeyType) -> AnyPublisher<Void, Error> {
    numberOfTimesCalledSet += 1
    
    didSetKey = key
    didSetValue = value
    
    queueUsedForTheLastCall = currentQueueSpecific()
    
    let publisher: AnyPublisher<Void, Error>
    
    if let subject = setSubject {
      publisher = subject.eraseToAnyPublisher()
    } else {
      setSubject = PassthroughSubject()
      publisher = setSubject!.eraseToAnyPublisher()
    }
    
    setPublishers.append(publisher)
    
    return publisher
  }
  
  var numberOfTimesCalledClear = 0
  func clear() {
    numberOfTimesCalledClear += 1
    
    queueUsedForTheLastCall = currentQueueSpecific()
  }
  
  var numberOfTimesCalledOnMemoryWarning = 0
  func onMemoryWarning() {
    numberOfTimesCalledOnMemoryWarning += 1
    
    queueUsedForTheLastCall = currentQueueSpecific()
  }
}
