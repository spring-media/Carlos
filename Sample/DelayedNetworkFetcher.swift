import Foundation
import Carlos

class DelayedNetworkFetcher: NetworkFetcher {
  private static let delay = dispatch_time(DISPATCH_TIME_NOW,
    Int64(2 * Double(NSEC_PER_SEC))) // 2 seconds
  
  override func get(key: KeyType) -> Result<OutputType> {
    let request = Result<OutputType>()
    
    super.get(key)
      .onSuccess({ value in
        dispatch_after(DelayedNetworkFetcher.delay, dispatch_get_main_queue()) {
          request.succeed(value)
        }
      })
      .onFailure({ error in
        dispatch_after(DelayedNetworkFetcher.delay, dispatch_get_main_queue()) {
          request.fail(error)
        }
      })
    
    return request
  }
}
