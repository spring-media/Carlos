import Foundation
import Carlos

class CacheLevelFake<A, B>: CacheLevel {
  typealias KeyType = A
  typealias OutputType = B
  
  init() {}
  
  var numberOfTimesCalledGet = 0
  var didGetKey: KeyType?
  var cacheRequestToReturn: CacheRequest<OutputType>?
  func get(key: KeyType) -> CacheRequest<OutputType> {
    numberOfTimesCalledGet++
    
    didGetKey = key
    
    return cacheRequestToReturn ?? CacheRequest<OutputType>()
  }
  
  var numberOfTimesCalledSet = 0
  var didSetValue: OutputType?
  var didSetKey: KeyType?
  func set(value: OutputType, forKey key: KeyType) {
    numberOfTimesCalledSet++
    
    didSetKey = key
    didSetValue = value
  }
  
  var numberOfTimesCalledClear = 0
  func clear() {
    numberOfTimesCalledClear++
  }
  
  var numberOfTimesCalledOnMemoryWarning = 0
  func onMemoryWarning() {
    numberOfTimesCalledOnMemoryWarning++
  }
}