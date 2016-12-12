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

/**
Composes two OneWayTransformers

- parameter firstTransformer: The first transformer to apply
- parameter secondTransformer: The second transformer to apply

- returns: A new OneWayTransformer that is the result of the composition of the two OneWayTransformers
*/
public func >>><A: OneWayTransformer, B: OneWayTransformer>(firstTransformer: A, secondTransformer: B) -> OneWayTransformationBox<A.TypeIn, B.TypeOut> where B.TypeIn == A.TypeOut {
  return firstTransformer.compose(secondTransformer)
}
