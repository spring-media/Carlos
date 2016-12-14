extension Sequence where Iterator.Element: Async {
  /**
  Merges this sequence of Futures into a single one containing the list of the results of each Future 
   
  - returns: A Future that will succeed with the list of results of the single Futures contained in this Sequence. The resulting Future will fail or be canceled if one of the elements of this sequence fails or is canceled
   */
  @available(*, deprecated:0.9)
  public func merge() -> Future<[Iterator.Element.Value]> {
    return mergeAll()
  }
  
  /**
   Merges this sequence of Futures into a single one containing the list of the results of each Future
   
   - returns: A Future that will succeed with the list of results of the single Futures contained in this Sequence. The resulting Future will fail or be canceled if one of the elements of this sequence fails or is canceled
   */
  public func mergeAll() -> Future<[Iterator.Element.Value]> {
    let result = reduce([], combine: { accumulator, value in
      accumulator + [value]
    })
    
    result.onCancel {
      self.forEach {
        $0.future.cancel()
      }
    }
    
    return result
  }
}
