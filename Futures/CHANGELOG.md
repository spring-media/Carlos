# Changelog

## 0.8

**Breaking changes**
- The codebase has been migrated to Swift 2.2

**New features**
- It's now possible to `map` `Future`s through:
  - a simple closure
  - a closure that `throws`
  - a closure that returns an `Optional`
  - a closure that returns another `Future`
  - a closure that returns a `Result`  
- It's now possible to `mimic` a `Result`

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