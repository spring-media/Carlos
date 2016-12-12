extension Sequence where Iterator.Element: Async {
  /**
  Reduces a sequence of Future`<T>` into a single Future`<U>` through a closure that takes a value T and the current accumulated value of the previous iterations (starting from initialValue and following the order of the sequence) and returns a value of type U
   
  - parameter initialValue: The initial value for the reduction of this sequence
  - parameter combine: The closure used to reduce the sequence
   
  - returns: a new Future`<U>` that will succeed when all the Future`<T>` of this array will succeed, with a value obtained through the execution of the combine closure on each result of the original Futures in the same order. The result will fail or get canceled if one of the original futures fails or gets canceled
  */
  public func reduce<U>(_ initialValue: U, combine: @escaping (U, Iterator.Element.Value) -> U) -> Future<U> {
    let result = reduce(Future(initialValue)) { accumulator, value in
      accumulator.flatMap { reduced in
        value.future.map { mapped in
          combine(reduced, mapped)
        }
      }
    }
    
    result.onCancel {
      self.forEach {
        $0.future.cancel()
      }
    }
    
    return result
  }
}
