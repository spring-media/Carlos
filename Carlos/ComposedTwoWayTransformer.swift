import Foundation

extension TwoWayTransformer {
  /**
  Composes the transformer with another TwoWayTransformer
  
  - parameter transformer: The second TwoWayTransformer to apply
  
  - returns: A new TwoWayTransformer that is the result of the composition of the two TwoWayTransformers
  */
  public func compose<A: TwoWayTransformer where A.TypeIn == TypeOut>(transformer: A) -> TwoWayTransformationBox<TypeIn, A.TypeOut> {
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
@available(*, deprecated=0.5)
public func compose<A: TwoWayTransformer, B: TwoWayTransformer where B.TypeIn == A.TypeOut>(firstTransformer: A, secondTransformer: B) -> TwoWayTransformationBox<A.TypeIn, B.TypeOut> {
  return firstTransformer.compose(secondTransformer)
}

/**
Composes two TwoWayTransformers

- parameter firstTransformer: The first TwoWayTransformer to apply
- parameter secondTransformer: The second TwoWayTransformer to apply

- returns: A new TwoWayTransformer that is the result of the composition of the two TwoWayTransformers
*/
public func >>><A: TwoWayTransformer, B: TwoWayTransformer where B.TypeIn == A.TypeOut>(firstTransformer: A, secondTransformer: B) -> TwoWayTransformationBox<A.TypeIn, B.TypeOut> {
  return firstTransformer.compose(secondTransformer)
}