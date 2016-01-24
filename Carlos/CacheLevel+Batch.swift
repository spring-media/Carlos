import Foundation

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
    
    keys.enumerate().forEach { (iteration, key) in
      get(key)
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
        .onCancel(result.cancel)
    }
    
    return result.future
  }
  
  /**
   Performs a batch of get requests on this CacheLevel
   
   - parameter keys: The list of keys to batch
   
   - returns: A Future that will call the success callback when all the keys will be either fetched or failed, passing a list containing just the successful results
   */
  public func batchGetSome(keys: [KeyType]) -> Future<[OutputType]> {
    let result = Promise<[OutputType]>()
    let resultsLock: ReadWriteLock = PThreadReadWriteLock()
    let counterLock: ReadWriteLock = PThreadReadWriteLock()
    var completedRequests = 0
    var intermediateResults = Array<OutputType?>(count: keys.count, repeatedValue: nil)
    
    keys.enumerate().forEach { (iteration, key) in
      get(key)
        .onCompletion { value, _ in
          if let value = value {
            resultsLock.withWriteLock {
              intermediateResults[iteration] = value
            }
          }
          
          counterLock.withWriteLock {
            completedRequests += 1
            
            if completedRequests == keys.count {
              result.succeed(intermediateResults.flatMap { $0 })
            }
          }
        }
    }
    
    return result.future
  }
}