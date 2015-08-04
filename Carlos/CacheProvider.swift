import Foundation

public class CacheProvider {
  /**
  :returns: An initialized and configured CacheLevel that takes NSURL keys and stores NSData values
  */
  public static func dataCache() -> BasicCache<NSURL, NSData> {
    return ({ $0.absoluteString! } =>> (MemoryCacheLevel() >>> DiskCacheLevel())) >>> pooled(NetworkFetcher())
  }
  
  /**
  :returns: An initialized and configured CacheLevel that takes NSURL keys and stores UIImage values
  
  :discussion: The code is not safe at the moment. This means if you try to store in this cache something that is not a UIImage (e.g. a NSURL pointing to a JSON or an HTML document), the app will crash (this will be fixed in a future release)
  */
  public static func imageCache() -> BasicCache<NSURL, UIImage> {
    return dataCache() =>> TwoWayTransformationBox<NSData, UIImage>(transform: { UIImage(data: $0)! }, inverseTransform: { UIImagePNGRepresentation($0) })
  }
}