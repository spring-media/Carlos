# Changelog

## 0.3

- Added support for `WatchOS 2`
- Added basic support for `Mac OS X 10.9+`
- Migrated the codebase to `Swift 2.0`
- Added `onCompletion` to `CacheRequest`
- Uses `ErrorType` instead of `NSError` in `CacheRequest`


## 0.2

- Added support for conditioning fetch closures (#49)
- Added a way to switch 2 caches with a given condition (#47)
- Transformers can return optional values, so the transformations are inherently safer (#45)
- Added a `CacheProvider` class with `dataCache()` and `imageCache()` methods to initialize most common caches (#44)
- Fixed a bug where simultaneuos requests for the same URL won't work on the `NetworkFetcher` level (#43)
- Made `MemoryCacheLevel` and `DiskCacheLevel` more generic by using a protocol for the keys (#38)
- Included a Playground into the project (#33)

## 0.1

- First release