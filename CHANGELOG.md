# Changelog

## 0.7
**Breaking changes**
- `onCompletion` argument now is a closure accepting a `Result<T>` as a parameter instead of a tuple `(value: T?, error: ErrorType?)`. `Result<T>` is the usual `enum` (aka `Either`) that can be `.Success(T)`, `.Error(ErrorType)` or `NotComputed` in case of canceled computations.

**New features**
- It's now possible to batch a set of fetch requests. You can use `batchGetAll` if you want to pass a list of keys and get the success callback when **all** of them succeed and the failure callback **as soon as one** of them fails, or `batchGetSome` if you want to pass a list of keys and get the success callback when all of them completed (successfully or not) but only get the list of successful responses back.

**Fixes**
- Correctly updates access date on the disk cache when calling `set` on a `DiskCacheLevel`

**Improvements**
- `Promise`s are now safer to use with GCD and in multi-thread scenarios.


## 0.6

**New features**
- It's now possible to conditionally post-process values fetched from `CacheLevel`s (or fetch closures) on the key used to fetch the value. Use the function `conditionedPostProcess` or consult the `README.md` for more information
- It's now possible to conditionally transform values fetched from (or set on) `CacheLevel`s on the key used to fetch (or set) the value. Use the function `conditionedValueTransformation` or consult the `README.md` for more information

**Fixes**
- `Carthage` integration works again

**Minor improvements**
- `CacheProvider` now has accessors to retrieve shared instances of the built-in caches (`sharedImageCache`, `sharedDataCache` and `sharedJSONCache`)

## 0.5

**New features**
- `Promise` can now be canceled. Call `cancel()` to cancel a `Promise`. Be notified of a canceled operation with the `onCancel` function. Use `onCancel` to setup the cancel behavior of your custom operation. Remember that an operation can only be canceled once, and can only be *executing*, *canceled*, *failed* or *succeeded* at any given time.
- It's now possible to apply a condition to a `OneWayTransformer`. You can call `conditioned` on the instance of `OneWayTransformer` to decorate and pass the condition on the input. This means you can effectively implement conditioned key transformations on `CacheLevel`s. Moreover, you can implement conditioned post processing transformations as well. For this, though, keep in mind that the input of the `OneWayTransformer` will be the output of the cache, not the key.
- It's now possible to apply a condition to a `TwoWayTransformer`. You can call `conditioned` on the instance of `TwoWayTransformer` to decorate and pass two conditions: the one to apply for the forward transformation and the one to apply for the inverse transformation, that will take of course different input types. This means you can effectively implement conditioned value transformations on `CacheLevel`s. 
- A new `NSUserDefaultsCacheLevel` is now included in `Carlos`. You can use this `CacheLevel` to persist values on `NSUserDefaults`, and you can even use multiple instances of this level to persist sandboxed sets of values
- It's now possible to dispatch a `CacheLevel` or a fetch closure on a given GCD queue. Use the `dispatch` protocol extension or the `~>>` operator and pass the  specific `dispatch_queue_t`. Global functions are not provided since we're moving towards a global-functions-free API for `Carlos 1.0`

**Major changes**
- **API Breaking**: `CacheRequest` is now renamed to `Future`. All the public API return `Future` instances now, and you can use `Promise` for your custom cache levels and fetchers
- **API Breaking**: `OneWayTransformer` and `TwoWayTransformer` are now asynchronous, i.e. they return a `Future<T>` instead of a `T` directly
- **API Breaking**: all the `conditioned` variants now take an asynchronous condition closure, i.e. the closure has to return a `Future<Bool>` instead of a `(Bool, ErrorType)` tuple
- All the global functions are now **deprecated**. They will be removed from the public API with the release of `Carlos 1.0`

**Minor improvements**
- `Promise` can now be initialized with an `Optional<T>` and an `ErrorType`, correctly behaving depending on the optional value
- `Promise` now has a `mimic` function that takes a `Future<T>` and succeeds or fails when the given `Future` does so
- `ImageTransformer` now applies its tranformations on a background queue
- `JSONTransformer` now passes the right error when the transformations fail 
- `CacheProvider.dataCache` now pools requests on the network **and** disk levels, so pooled requests don't result in multiple `set` calls on the disk level
- It's now possible to `cancel` operations coming from a `NetworkFetcher`
- `Int`, `Float`, `Double` and `Character` conform to `ExpensiveObject` now with a unit (`1`) cost
- Added a `MIGRATING.md` to the repo and to the Wiki that explains how to migrate to new versions of `Carlos` (only for breaking changes)


## 0.4

**Major changes**
- Adds a `Fetcher` protocol that you can use to create your custom fetchers.
- Adds the possibility to transform values coming out of `Fetcher` instances through `OneWayTransformer` objects without forcing them to be `TwoWayTransformer` as in the case of transforming values of `CacheLevel` instances 
- Adds a `JSONCache` function to `CacheProvider`
- Adds output processers to process/sanitize values coming out of `CacheLevel`s (see `postProcess`) 
- Adds a way to compose multiple `OneWayTransformer`s through functions, operators and protocol extensions
- Adds a way to compose multiple `TwoWayTransformer`s through functions, operators and protocol extensions
- Adds a `normalize` function and protocol extension transforming `CacheLevel` instances into `BasicCache` ones to make it easier to store instance properties
- Adds a `JSONTransformer` class conforming to `TwoWayTransformer`
- Adds a `ImageTransformer` class for the iOS and WatchOS 2 frameworks conforming to `TwoWayTransformer`
- Adds a `StringTransformer` class conforming to `TwoWayTransformer`

**Minor improvements**
- `invert` is now available as a protocol extension to the `TwoWayTransformer` protocol

**WatchOS 2**
- Adds `WatchOS 2` support through `CocoaPods`

**tvOS**
- Adds framework support for `tvOS`

## 0.3

**Major changes**
- Codebase converted to `Swift 2.0`
- Adds `WatchOS 2` support
- Adds `Mac OS X 10.9+` support

**API-Breaking changes**
- `CacheRequest.onFailure` now passes an `ErrorType` instead of an `NSError`

**Minor improvements**
- Adds an `onCompletion` method to the `CacheRequest` class, that will be called in both success and failure cases

## 0.2

**Major changes**
- Includes a `CacheProvider` class to create commonly used caches
- Includes a Playground to quickly test Carlos and custom cache architectures
- includes a new `switchLevels` function to have multiple cache lanes

**Minor improvements**
- Improves `DiskCacheLevel` and `MemoryCacheLevel` by having protocol-based keys
- Defines safer Transformers (either `OneWayTransformer` or `TwoWayTransformer`) that return Optionals. If a conversion fails, set operations silently fail and get operations fail with a meaningful error.
- Extends the `conditioned` function and the `<?>` operator to support fetch closures
- Improves the code documentation

**Bugfixes**
- Fixes an issue where the `NetworkFetcher` would not correctly handle multiple get requests for the same URL

## 0.1

- First release
