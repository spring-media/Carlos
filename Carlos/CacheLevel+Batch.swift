import Foundation
import PiedPiper

extension CacheLevel {
  /**
   Performs a batch of get requests on this CacheLevel
   
   - parameter keys: The list of keys to batch
   
   - returns: A Future that will call the success callback when ALL the keys will be fetched successfully, and the failure callback as soon as JUST ONE of the keys cannot be fetched.
   */
  public func batchGetAll(keys: [KeyType]) -> Future<[OutputType]> {
    let result = Promise<[OutputType]>()
    let lock: ReadWriteLock = PThreadReadWriteLock()
    var intermediateResults = Array<OutputType?>(count: keys.count, repeatedValue: nil)
    
    var batchedRequests: [Future<OutputType>] = []
    
    keys.enumerate().forEach { (iteration, key) in
      batchedRequests.append(get(key)
        .onSuccess { value in
          lock.withWriteLock {
            intermediateResults[iteration] = value
          
            let successfulFetches = intermediateResults.flatMap { $0 }
            if successfulFetches.count == keys.count {
              result.succeed(successfulFetches)
            }
          }
        }
        .onFailure(result.fail)
        .onCancel(result.cancel))
    }
    
    result.onCancel {
      batchedRequests.forEach { request in
        request.cancel()
      }
    }
    
    return result.future
  }
  
  /**
   Performs a batch of get requests on this CacheLevel
   
   - parameter keys: The list of keys to batch
   
   - returns: A Future that will call the success callback when all the keys will be either fetched or failed, passing a list containing just the successful results
   */
  public func batchGetSome(keys: [KeyType]) -> Future<[OutputType]> {
    let resultPromise = Promise<[OutputType]>()
    let resultsLock: ReadWriteLock = PThreadReadWriteLock()
    let counterLock: ReadWriteLock = PThreadReadWriteLock()
    var completedRequests = 0
    var intermediateResults = Array<OutputType?>(count: keys.count, repeatedValue: nil)
    var batchedRequests: [Future<OutputType>] = []
    
    keys.enumerate().forEach { (iteration, key) in
      batchedRequests.append(get(key)
        .onCompletion { result in
          if case .Success(let value) = result {
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