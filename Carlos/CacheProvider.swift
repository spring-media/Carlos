import Foundation

/**
A simple class with the purpose of providing standard caches
*/
public class CacheProvider {
  /**
  - returns: An initialized and configured CacheLevel that takes NSURL keys and stores NSData values. Network requests are pooled for efficiency
  */
  public static func dataCache() -> BasicCache<NSURL, NSData> {
    return MemoryCacheLevel() >>> DiskCacheLevel() >>> NetworkFetcher().pooled()
  }
  
  /**
  - returns: An initialized and configured CacheLevel that takes NSURL keys and stores UIImage values. Network requests are pooled for efficiency.
  
  :discussion: The code is not safe at the moment. This means if you try to store in this cache something that is not a UIImage (e.g. a NSURL pointing to a JSON or an HTML document), the app will crash (this will be fixed in a future release)
  */
  public static func imageCache() -> BasicCache<NSURL, UIImage> {
    return MemoryCacheLevel() >>> DiskCacheLevel() >>> (NetworkFetcher().pooled() =>> TwoWayTransformationBox<NSData, UIImage>(transform: { UIImage(data: $0) }, inverseTransform: { UIImagePNGRepresentation($0) /* This is a waste of bytes, we should probably use a lower-level framework */ }))
  }
}