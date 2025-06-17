import Foundation
import Combine

/// Adds a debounce operator to any AsyncSequence
/// Only emits the latest value after the specified delay
extension AsyncSequence {
    
    /// Debounces values emitted by the sequence, suppressing intermediate values.
    ///
    /// - Parameter seconds: The delay in seconds before emitting the latest value.
    /// - Returns: A debounced async stream of elements.
    func debounced(
        for seconds: Double
    ) -> AsyncStream<Element> {
        AsyncStream { continuation in
            var task: Task<Void, Never>?
            Task {
                for try await value in self {
                    /// Cancel any existing delay
                    task?.cancel()
                    task = Task {
                        /// Wait for the debounce duration/
                        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                        continuation.yield(value)
                    }
                }
            }
        }
    }
    
}
