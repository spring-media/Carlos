import Foundation
import Carlos

class CacheLevelFake<A, B>: CacheLevel {
  typealias KeyType = A
  typealias OutputType = B
  
  init() {}
  
  var numberOfTimesCalledGet = 0
  var didGetKey: KeyType?
  var cacheRequestToReturn: CacheRequest<OutputType>?
  func get(fetchable: KeyType) -> CacheRequest<OutputType> {
    numberOfTimesCalledGet++
    
    didGetKey = fetchable
    
    return cacheRequestToReturn ?? CacheRequest<OutputType>()
  }
  
  var numberOfTimesCalledSet = 0
  var didSetValue: OutputType?
  var didSetKey: KeyType?
  func set(value: OutputType, forKey fetchable: KeyType) {
    numberOfTimesCalledSet++
    
    didSetKey = fetchable
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