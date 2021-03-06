import Combine
import Foundation

extension TwoWayTransformer {
  /**
   Composes the transformer with another TwoWayTransformer

   - parameter transformer: The second TwoWayTransformer to apply

   - returns: A new TwoWayTransformer that is the result of the composition of the two TwoWayTransformers
   */
  public func compose<A: TwoWayTransformer>(_ transformer: A) -> TwoWayTransformationBox<TypeIn, A.TypeOut> where A.TypeIn == TypeOut {
    TwoWayTransformationBox(
      transform: transform >>> transformer.transform,
      inverseTransform: transformer.inverseTransform >>> inverseTransform
    )
  }
}
