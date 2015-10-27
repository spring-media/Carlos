import Foundation

// Expose later on when the library is more async-computation oriented
/**
Composes two sync closures

- parameter f: A closure taking an A parameter and returning an Optional<B>
- parameter g: A closure taking a B parameter and returning an Optional<C>

- returns: A closure taking an A parameter and returning an Optional<C> obtained by combining f and g in a way similar to g(f(x))
*/
internal func >>> <A, B, C>(f: A -> B?, g: B -> C?) -> A -> C? {
  return { x in
    if let fx = f(x) {
      return g(fx)
    } else {
      return nil
    }
  }
}

// Expose later when transformers will to be async and caches will be chainable in a similar way
/**
Composes two async (Result) closures

- parameter f: A closure taking an A parameter and returning a Result<B> (basically a future for a B return type)
- parameter g: A closure taking a B parameter and returning a Result<C> (basically a future for a C return type)

- returns: A closure taking an A parameter and returning a Result<C> (basically a future for a C return type) obtained by combining f and g in a way similar to g(f(x)) (if the closures were sync)
*/
internal func >>> <A, B, C>(f: A -> Result<B>, g: B -> Result<C>) -> A -> Result<C> {
  return { param in
    let resultingRequest = Result<C>()
    
    f(param)
      .onSuccess { result in
        g(result)
          .onSuccess { result in
            resultingRequest.succeed(result)
          }
          .onFailure { error in
            resultingRequest.fail(error)
          }
      }
      .onFailure { error in
        resultingRequest.fail(error)
      }
    
    return resultingRequest
  }
}

// Expose later if needed with async transformers
/**
Composes two async closures

- parameter f: A closure taking an A parameter and a completion callback taking an Optional<B> and returning Void
- parameter g: A closure taking a B parameter and a completion callback taking an Optional<C> and returning Void

- returns: A closure taking an A parameter and a completion callback taking an Optional<C> and returning Void obtained by combining f and g in a way similar to g(f(x)) (if the closures were sync)
*/
internal func >>> <A, B, C>(f: (A, B? -> Void) -> Void, g: (B, C? -> Void) -> Void) -> (A, C? -> Void) -> Void {
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