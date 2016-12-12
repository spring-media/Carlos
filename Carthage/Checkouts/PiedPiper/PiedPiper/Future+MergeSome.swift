extension Sequence where Iterator.Element: Async {
  /**
   Merges this sequence of Futures into a single one containing the list of the results of each Future

   - returns: A Future that will succeed with the list of results of the single Futures contained in this Sequence. The resulting Future will fail or be canceled if one of the elements of this sequence fails or is canceled
   */
  public func mergeSome() -> Future<[Iterator.Element.Value]> {
    let result = reduce(Future([])) { accumulator, value in
      accumulator.flatMap { reduced in
        value.future.map { mapped in
          reduced + [mapped]
        }.recover(reduced)
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
