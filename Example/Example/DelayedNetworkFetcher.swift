import Foundation
import Carlos
import PiedPiper

class DelayedNetworkFetcher: NetworkFetcher {
  private static let delay = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC) // 2 seconds
  
  override func get(_ key: KeyType) -> Future<OutputType> {
    let request = Promise<OutputType>()
    
    super.get(key)
      .onSuccess({ value in
        DispatchQueue.main.asyncAfter(deadline: DelayedNetworkFetcher.delay) {
          request.succeed(value)
        }
      })
      .onFailure({ error in
        DispatchQueue.main.asyncAfter(deadline: DelayedNetworkFetcher.delay) {
          request.fail(error)
        }
      })
    
    return request.future
  }
}
