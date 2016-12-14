import Foundation
import PiedPiper

extension OneWayTransformer {
  /**
  Composes the transformer with another OneWayTransformer
  
  - parameter transformer: The second OneWayTransformer to apply
  
  - returns: A new OneWayTransformer that is the result of the composition of the two OneWayTransformers
  */
  public func compose<A: OneWayTransformer>(_ transformer: A) -> OneWayTransformationBox<TypeIn, A.TypeOut> where A.TypeIn == TypeOut {
    return OneWayTransformationBox(transform: self.transform >>> transformer.transform)
  }
}
