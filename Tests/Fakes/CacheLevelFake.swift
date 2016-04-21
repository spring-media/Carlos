import Foundation
import Carlos
import PiedPiper

class CacheLevelFake<A, B>: CacheLevel {
  typealias KeyType = A
  typealias OutputType = B
  
  init() {}
  
  var queueUsedForTheLastCall: UnsafeMutablePointer<Void>!
  
  var numberOfTimesCalledGet = 0
  var didGetKey: KeyType?
  var cacheRequestToReturn: Future<OutputType>?
  var promisesReturned: [Promise<OutputType>] = []
  func get(key: KeyType) -> Future<OutputType> {
    numberOfTimesCalledGet += 1
    
    didGetKey = key
    
    queueUsedForTheLastCall = currentQueueSpecific()
    
    let returningPromise: Promise<OutputType>
    let returningFuture: Future<OutputType>
    
    if let requestToReturn = cacheRequestToReturn {
      returningFuture = requestToReturn
      returningPromise = Promise<OutputType>().mimic(requestToReturn)
    } else {
      returningPromise = Promise<OutputType>()
      returningFuture = returningPromise.future
    }
    
    promisesReturned.append(returningPromise)
    
    return returningFuture
  }
  
  var numberOfTimesCalledSet = 0
  var didSetValue: OutputType?
  var didSetKey: KeyType?
  func set(value: OutputType, forKey key: KeyType) {
    numberOfTimesCalledSet += 1
    
    didSetKey = key
    didSetValue = value
    
    queueUsedForTheLastCall = currentQueueSpecific()
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

class FetcherFake<A, B>: Fetcher {
  typealias KeyType = A
  typealias OutputType = B
  
  var queueUsedForTheLastCall: UnsafeMutablePointer<Void>!
  
  init() {}
  
  var numberOfTimesCalledGet = 0
  var didGetKey: KeyType?
  var cacheRequestToReturn: Future<OutputType>?
  func get(key: KeyType) -> Future<OutputType> {
    numberOfTimesCalledGet += 1
    
    didGetKey = key
    
    queueUsedForTheLastCall = currentQueueSpecific()
    
    return cacheRequestToReturn ?? Promise<OutputType>().future
  }
}