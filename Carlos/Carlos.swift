import Foundation

internal struct CarlosGlobals {
  static let QueueNamePrefix = "com.carlos."
  static let Caches = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String
}

internal func wrapClosureIntoCacheLevel<A, B>(closure: (key: A) -> CacheRequest<B>) -> BasicCache<A, B> {
  return BasicCache<A, B>(getClosure: { key in
    return closure(key: key)
  }, setClosure: { (_, _) in }, clearClosure: { }, memoryClosure: { })
}

internal func wrapClosureIntoOneWayTransformer<A, B>(transformerClosure: A -> B) -> OneWayTransformationBox<A, B> {
  return OneWayTransformationBox<A, B>(transform: transformerClosure)
}