import Foundation
import PiedPiper

extension CacheLevel {  
  /**
   Performs a batch of get requests on this CacheLevel
   
   - parameter keys: The list of keys to batch
   
   - returns: A Future that will call the success callback when all the keys will be either fetched or failed, passing a list containing just the successful results
   */
  public func batchGetSome(_ keys: [KeyType]) -> Future<[OutputType]> {
    let resultPromise = Promise<[OutputType]>()
    let resultsLock: ReadWriteLock = PThreadReadWriteLock()
    let counterLock: ReadWriteLock = PThreadReadWriteLock()
    var completedRequests = 0
    var intermediateResults = Array<OutputType?>(repeating: nil, count: keys.count)
    var batchedRequests: [Future<OutputType>] = []
    
    keys.enumerated().forEach { (iteration, key) in
      batchedRequests.append(get(key)
        .onCompletion { result in
          if let value = result.value {
            resultsLock.withWriteLock {
              intermediateResults[iteration] = value
            }
          }
          
          counterLock.withWriteLock {
            completedRequests += 1
            
            if completedRequests == keys.count {
              resultPromise.succeed(intermediateResults.flatMap { $0 })
            }
          }
        }
      )
    }
    
    resultPromise.onCancel {
      batchedRequests.forEach { request in
        request.cancel()
      }
    }
    
    return resultPromise.future
  }
}
