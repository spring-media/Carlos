import Foundation
import PiedPiper

extension OneWayTransformer {
  /**
  Composes the transformer with another OneWayTransformer
  
  - parameter transformer: The second OneWayTransformer to apply
  
  - returns: A new OneWayTransformer that is the result of the composition of the two OneWayTransformers
  */
  public func compose<A: OneWayTransformer where A.TypeIn == TypeOut>(transformer: A) -> OneWayTransformationBox<TypeIn, A.TypeOut> {
    return OneWayTransformationBox(transform: self.transform >>> transformer.transform)
  }
  
  /**
  Composes the transformer with a transformation closure
  
  - parameter transformerClosure: The transformation closure to apply after
  
  - returns: A new OneWayTransformer that is the result of the composition of the transformer with the transformation closure
   */
  @available(*, deprecated=0.7)
  public func compose<A>(transformerClosure: TypeOut -> Future<A>) -> OneWayTransformationBox<TypeIn, A> {
    return self.compose(wrapClosureIntoOneWayTransformer(transformerClosure))
  }
}

/**
Composes two OneWayTransformers

- parameter firstTransformer: The first transformer to apply
- parameter secondTransformer: The second transformer to apply

- returns: A new OneWayTransformer that is the result of the composition of the two OneWayTransformers
*/
@available(*, deprecated=0.5)
public func compose<A: OneWayTransformer, B: OneWayTransformer where B.TypeIn == A.TypeOut>(firstTransformer: A, secondTransformer: B) -> OneWayTransformationBox<A.TypeIn, B.TypeOut> {
  return firstTransformer.compose(secondTransformer)
}

/**
Composes a OneWayTransformer with a transformation closure

- parameter transformer: The OneWayTransformer to apply first
- parameter transformerClosure: The transformation closure to apply after

- returns: A new OneWayTransformer that is the result of the composition of the transformer with the transformation closure
*/
@available(*, deprecated=0.5)
public func compose<A: OneWayTransformer, B>(transformer: A, transformerClosure: A.TypeOut -> Future<B>) -> OneWayTransformationBox<A.TypeIn, B> {
  return transformer.compose(transformerClosure)
}

/**
Composes two transformation closures

- parameter firstTransformerClosure: The first transformation closure to apply
- parameter secondTransformerClosure: The second transformation closure to apply

- returns: A new OneWayTransformer that is the result of the composition of the two transformation closures
*/
@available(*, deprecated=0.5)
public func compose<A, B, C>(firstTransformerClosure: A -> Future<B>, secondTransformerClosure: B -> Future<C>) -> OneWayTransformationBox<A, C> {
  return wrapClosureIntoOneWayTransformer(firstTransformerClosure).compose(secondTransformerClosure)
}

/**
Composes a transformation closure with a OneWayTransformer

- parameter transformerClosure: The transformation closure to apply first
- parameter transformer: The OneWayTransformer to apply after

- returns: A new OneWayTransformer that is the result of the composition of the transformation closure with the transformer
*/
@available(*, deprecated=0.5)
public func compose<A: OneWayTransformer, B>(transformerClosure: B -> Future<A.TypeIn>, transformer: A) -> OneWayTransformationBox<B, A.TypeOut> {
  return wrapClosureIntoOneWayTransformer(transformerClosure).compose(transformer)
}

/**
Composes two OneWayTransformers

- parameter firstTransformer: The first transformer to apply
- parameter secondTransformer: The second transformer to apply

- returns: A new OneWayTransformer that is the result of the composition of the two OneWayTransformers
*/
public func >>><A: OneWayTransformer, B: OneWayTransformer where B.TypeIn == A.TypeOut>(firstTransformer: A, secondTransformer: B) -> OneWayTransformationBox<A.TypeIn, B.TypeOut> {
  return firstTransformer.compose(secondTransformer)
}

/**
Composes a OneWayTransformer with a transformation closure

- parameter transformer: The OneWayTransformer to apply first
- parameter transformerClosure: The transformation closure to apply after

- returns: A new OneWayTransformer that is the result of the composition of the transformer with the transformation closure
 */
@available(*, deprecated=0.7)
public func >>><A: OneWayTransformer, B>(transformer: A, transformerClosure: A.TypeOut -> Future<B>) -> OneWayTransformationBox<A.TypeIn, B> {
  return transformer.compose(transformerClosure)
}

/**
Composes two transformation closures

- parameter firstTransformerClosure: The first transformation closure to apply
- parameter secondTransformerClosure: The second transformation closure to apply

- returns: A new OneWayTransformer that is the result of the composition of the two transformation closures
 */
@available(*, deprecated=0.7)
public func >>><A, B, C>(firstTransformerClosure: A -> Future<B>, secondTransformerClosure: B -> Future<C>) -> OneWayTransformationBox<A, C> {
  return wrapClosureIntoOneWayTransformer(firstTransformerClosure).compose(secondTransformerClosure)
}

/**
Composes a transformation closure with a OneWayTransformer

- parameter transformerClosure: The transformation closure to apply first
- parameter transformer: The OneWayTransformer to apply after

- returns: A new OneWayTransformer that is the result of the composition of the transformation closure with the transformer
 */
@available(*, deprecated=0.7)
public func >>><A: OneWayTransformer, B>(transformerClosure: B -> Future<A.TypeIn>, transformer: A) -> OneWayTransformationBox<B, A.TypeOut> {
  return wrapClosureIntoOneWayTransformer(transformerClosure).compose(transformer)
}