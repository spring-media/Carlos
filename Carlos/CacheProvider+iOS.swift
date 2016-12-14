import Foundation
import UIKit

extension CacheProvider {
  /// A shared image cache instance
  public static let sharedImageCache: BasicCache<URL, UIImage> = CacheProvider.imageCache()
  
  /**
  - returns: An initialized and configured CacheLevel that takes NSURL keys and stores UIImage values. Network requests are pooled for efficiency. Keep in mind that calling this method twice returns two different instances. You should take care of retaining the result or use `sharedImageCache` instead
  */
  public static func imageCache() -> BasicCache<URL, UIImage> {
    return MemoryCacheLevel<URL, UIImage>()
      .compose(DiskCacheLevel<URL, UIImage>())
      .compose(
        NetworkFetcher()
          .pooled()
          .transformValues(ImageTransformer())
      )
  }
}
