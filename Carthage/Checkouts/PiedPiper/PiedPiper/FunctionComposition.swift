import Foundation

infix operator >>>: CompositionPrecedence
precedencegroup CompositionPrecedence {
  associativity: left
  higherThan: AssignmentPrecedence
}

/**
Composes two sync closures

- parameter f: A closure taking an A parameter and returning an Optional<B>
- parameter g: A closure taking a B parameter and returning an Optional<C>

- returns: A closure taking an A parameter and returning an Optional<C> obtained by combining f and g in a way similar to g(f(x))
*/
public func >>> <A, B, C>(f: @escaping (A) -> B?, g: @escaping (B) -> C?) -> (A) -> C? {
  return { x in
    if let fx = f(x) {
      return g(fx)
    } else {
      return nil
    }
  }
}

/**
 Composes two sync closures
 
 - parameter f: A closure taking an A parameter and returning a value of type B
 - parameter g: A closure taking a B parameter and returning a value of type C
 
 - returns: A closure taking an A parameter and returning a value of type C obtained by combining f and g through g(f(x))
 */
public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  return { x in
    g(f(x))
  }
}

/**
Composes two async (Future) closures

- parameter f: A closure taking an A parameter and returning a Future<B> (basically a future for a B return type)
- parameter g: A closure taking a B parameter and returning a Future<C> (basically a future for a C return type)

- returns: A closure taking an A parameter and returning a Future<C> (basically a future for a C return type) obtained by combining f and g in a way similar to g(f(x)) (if the closures were sync)
*/
public func >>> <A, B, C>(f: @escaping (A) -> Future<B>, g: @escaping (B) -> Future<C>) -> (A) -> Future<C> {
  return { param in
    return f(param).flatMap(g)
  }
}

//Expose later if it makes sense to
/**
Composes two async closures

- parameter f: A closure taking an A parameter and a completion callback taking an Optional<B> and returning Void
- parameter g: A closure taking a B parameter and a completion callback taking an Optional<C> and returning Void

- returns: A closure taking an A parameter and a completion callback taking an Optional<C> and returning Void obtained by combining f and g in a way similar to g(f(x)) (if the closures were sync)
*/
internal func >>> <A, B, C>(f: @escaping (A, (B?) -> Void) -> Void, g: @escaping (B, (C?) -> Void) -> Void) -> (A, (C?) -> Void) -> Void {
  return { x, completion in
    f(x) { fx in
      if let fx = fx {
        g(fx) { result in
          completion(result)
        }
      } else {
        completion(nil)
      }
    }
  }
}
