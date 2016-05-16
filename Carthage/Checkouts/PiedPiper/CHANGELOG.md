# Changelog

## 0.8

**Breaking changes**
- The codebase has been migrated to Swift 2.2
- `Promise` now has only an empty `init`. If you used one of the convenience `init` (with `value:`, with `error:` or with `value:error:`), they now moved to `Future`.

**New features**
- Adds `value` and `error` properties to `Result`
- Added a way to initialize `Future`s through closures
- It's now possible to `map` `Future`s through:
  - a simple transformation closure
  - a closure that `throws`
- It's now possible to `flatMap` `Future`s through:
  - a closure that returns an `Optional`
  - a closure that returns another `Future`
  - a closure that returns a `Result`  
- It's now possible to `filter` `Future`s through:
  - a simple condition closure
  - a closure that returns a `Future<Bool>`
- It's now possible to `reduce` a `SequenceType` of `Future`s into a new `Future` through a `combine` closure 
- It's now possible to `zip` a `Future` with either another `Future` or with a `Result`
- Added `merge` to a `SequenceType` of `Future`s to collapse a list of `Future`s into a single one
- Added `traverse` to `SequenceType` to generate a list of `Future`s through a given closure and `merge` them together
- Added `recover` to `Future` so that it's possible to provide a default value the `Future` can use instead of failing
- It's now possible to `map` `Result`s through:
  - a simple transformation closure
  - a closure that `throws`
- It's now possible to `flatMap` `Result`s through:
  - a closure that returns an `Optional`
  - a closure that returns a `Future`
  - a closure that returns another `Result`
- It's now possible to `filter` `Result`s through a simple condition closure  
- Added `mimic` to `Result`


## 0.7

First release of `Pied Piper` as a separate framework.

**Breaking changes**
- As documented in the `MIGRATING.md` file, you will have to add a `import PiedPiper` line everywhere you make use of Carlos' `Future`s or `Promise`s.

**New features**
- It's now possible to compose async functions and `Future`s through the `>>>` operator.
- The implementation of `ReadWriteLock` taken from [Deferred](https://github.com/bignerdranch/Deferred) is now exposed as `public`.
- It's now possible to take advantage of the `GCD` struct to execute asynchronous computation through the functions `main` and `background` for GCD built-in queues and `async` for GCD serial or custom queues.

**Improvements**
- `Promise`s are now safer to use with GCD and in multi-thread scenarios.

**Fixes**
- Fixes a bug where calling `succeed`, `fail` or `cancel` on a `Promise` or a `Future` didn't correctly release all the attached listeners.
- Fixes a retain cycle between `Promise` and `Future` objects.