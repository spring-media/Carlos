import Foundation

/**
 Retries a given Future for a given number of times
 
 - parameter count: How many times you want the future to be retried if failed (No retries: 0)
 - parameter every: How much you want to wait before retrying
 - parameter futureClosure: The closure generating a new instance of the future to retry
 
 - returns: A future that fails if all the generated futures have failed, or succeeds if one of the generated futures succeeds
 */
public func retry<T>(_ count: Int, every delay: TimeInterval, futureClosure: @escaping (Void) -> Future<T>) -> Future<T> {
  if count <= 0 {
    return futureClosure()
  }
  
  let result = Promise<T>()
  
  result.mimic(
    futureClosure()
      .recover { Void -> Future<T> in
        let delayed = Promise<T>()
        
        GCD.delay(delay, closure: {}).onSuccess {
          delayed.mimic(retry(count - 1, every: delay, futureClosure: futureClosure))
        }
        
        return delayed.future
      }
  )
  
  return result.future
}
