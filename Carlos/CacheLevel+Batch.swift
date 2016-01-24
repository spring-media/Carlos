import Foundation

extension CacheLevel {
  /**
   Performs a batch of get requests on this CacheLevel
   
   - parameter keys: The list of keys to batch
   
   - returns: A Future that will call the success callback when ALL the keys will be fetched successfully, and the failure callback as soon as JUST ONE of the keys cannot be fetched.
   */
  public func batchGet(keys: [KeyType]) -> Future<[OutputType]> {
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
}