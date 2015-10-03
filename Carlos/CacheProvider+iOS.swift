import Foundation
import UIKit

extension CacheProvider {
  /**
  - returns: An initialized and configured CacheLevel that takes NSURL keys and stores UIImage values. Network requests are pooled for efficiency.
  */
  public static func imageCache() -> BasicCache<NSURL, UIImage> {
    return MemoryCacheLevel() >>> DiskCacheLevel() >>> (NetworkFetcher().pooled() =>> ImageTransformer())
  }
}