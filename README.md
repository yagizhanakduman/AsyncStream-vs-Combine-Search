# UIKit Debounced Search Example (AsyncStream vs Combine)

This project demonstrates how to implement debounced text search in a `UITextField` using two different approaches in UIKit:

- Swift Concurrency with `AsyncStream`
- Reactive programming with `Combine`

---

## Features

- Realtime search triggered by typing in a text field  
- Debounced input: waits 0.5 seconds after typing stops before triggering a search  
- Filters results from a mock local data source  
- Displays matched results in a `UILabel`

---

## Technologies

| Technique      | Key APIs Used                               |
|----------------|---------------------------------------------|
| AsyncStream    | `AsyncStream`, `Task.sleep`, debounce helper |
| Combine        | `PassthroughSubject`, `.debounce`, `.flatMap`, `Just` |

---

## AsyncStream Version

- Uses `AsyncStream<String>` to stream user input.
- Adds a `debounced(for:)` extension to delay emission.
- Simple and clean `async/await` syntax without external dependencies.

### Pros:
- Readable and modern with Swift Concurrency
- Ideal for one-to-one consumption flows
- Minimal overhead, fully native

### Cons:
- Requires custom debounce implementation
- No native support for complex operators (e.g. combineLatest)

---

## Combine Version

- Uses `PassthroughSubject` to capture `UITextField` input.
- Applies `.removeDuplicates()` and `.debounce()` operators.
- Uses `.flatMap` to perform asynchronous search simulation.

### Pros:
- Powerful reactive operators built-in
- Better suited for complex event stream composition
- Mature and extensible for multi-subscriber use

### Cons:
- Slightly more complex code
- Requires understanding of reactive flow

---

## Example Search Terms

Try typing:

- `"Mac"` → matches **MacBook**, **Mac Mini**, etc.
- `"i"` → matches **iMac**, **iPhone**, **iPad**
- Typing quickly will debounce intermediate inputs

---

## Requirements

- iOS 15+
- Swift 5.7+
- Xcode 14+

---
