import Foundation
import Carlos
import PiedPiper

class CacheLevelFake<A, B>: CacheLevel {
  typealias KeyType = A
  typealias OutputType = B
  
  init() {}
  
  var queueUsedForTheLastCall: UnsafeMutableRawPointer!
  
  var numberOfTimesCalledGet = 0
  var didGetKey: KeyType?
  var cacheRequestToReturn: Future<OutputType>?
  var promisesReturned: [Promise<OutputType>] = []
  func get(_ key: KeyType) -> Future<OutputType> {
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
  var setFutureToReturn: Future<()>?
  var setPromisesReturned: [Promise<()>] = []
  func set(_ value: OutputType, forKey key: KeyType) -> Future<()> {
    numberOfTimesCalledSet += 1
    
    didSetKey = key
    didSetValue = value
    
    queueUsedForTheLastCall = currentQueueSpecific()
    
    let returningPromise: Promise<()>
    let returningFuture: Future<()>
    
    if let requestToReturn = setFutureToReturn {
      returningFuture = requestToReturn
      returningPromise = Promise<()>().mimic(requestToReturn)
    } else {
      returningPromise = Promise<()>()
      returningFuture = returningPromise.future
    }
    
    setPromisesReturned.append(returningPromise)
    
    return returningFuture
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
  
  var queueUsedForTheLastCall: UnsafeMutableRawPointer!
  
  init() {}
  
  var numberOfTimesCalledGet = 0
  var didGetKey: KeyType?
  var cacheRequestToReturn: Future<OutputType>?
  func get(_ key: KeyType) -> Future<OutputType> {
    numberOfTimesCalledGet += 1
    
    didGetKey = key
    
    queueUsedForTheLastCall = currentQueueSpecific()
    
    return cacheRequestToReturn ?? Promise<OutputType>().future
  }
}
