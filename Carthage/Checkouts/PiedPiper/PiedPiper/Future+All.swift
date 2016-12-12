extension Sequence where Iterator.Element: Async {
  /**
  - returns: A Future that succeeds when all the Futures contained in this sequence succeed, and fails when one of the Futures contained in this sequence fails.
   */
  public func all() -> Future<()> {
    return mergeAll().map { _ in }
  }
}
