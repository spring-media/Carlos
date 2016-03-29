## Migrating from 0.7 to 0.8

### `Promise` now has only an empty `init`. 

If you used one of the convenience `init` (with `value:`, with `error:` or with `value:error:`), they now moved to `Future`.

```swift
// Before
let future = Promise(value: 10).future

// Now
let future = Future(10)
```

```swift
// Before
let future = Promise(error: MyError.SomeError).future

// Now
let future = Future(MyError.SomeError)
```

```swift
// Before
let future = Promise(value: someOptionalInt, error: MyError.InvalidConversion).future

// Now
let future = Future(value: someOptionalInt, error: MyError.InvalidConversion)
```