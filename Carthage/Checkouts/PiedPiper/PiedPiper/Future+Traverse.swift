extension Sequence {
  /**
  Maps this sequence with the provided closure generating Futures, then merges the created Futures into a single one
   
  - parameter generator: The closure that generates a Future for each element in this sequence
  
  - returns: A new Future containing the list of results of the single Futures generated through the closure. The resulting Future will fail or be canceled if one of the Futures generated through the closure fails or is canceled
  */
  public func traverse<U>(_ generator: (Iterator.Element) -> Future<U>) -> Future<[U]> {
    return map(generator).mergeAll()
  }
}
