import Foundation
import PiedPiper

extension TwoWayTransformer {
  /**
  Composes the transformer with another TwoWayTransformer
  
  - parameter transformer: The second TwoWayTransformer to apply
  
  - returns: A new TwoWayTransformer that is the result of the composition of the two TwoWayTransformers
  */
  public func compose<A: TwoWayTransformer>(_ transformer: A) -> TwoWayTransformationBox<TypeIn, A.TypeOut> where A.TypeIn == TypeOut {
    return TwoWayTransformationBox(
      transform: self.transform >>> transformer.transform,
      inverseTransform: transformer.inverseTransform >>> self.inverseTransform
    )
  }
}

/**
Composes two TwoWayTransformers

- parameter firstTransformer: The first TwoWayTransformer to apply
- parameter secondTransformer: The second TwoWayTransformer to apply

- returns: A new TwoWayTransformer that is the result of the composition of the two TwoWayTransformers
*/
public func >>><A: TwoWayTransformer, B: TwoWayTransformer>(firstTransformer: A, secondTransformer: B) -> TwoWayTransformationBox<A.TypeIn, B.TypeOut> where B.TypeIn == A.TypeOut {
  return firstTransformer.compose(secondTransformer)
}
