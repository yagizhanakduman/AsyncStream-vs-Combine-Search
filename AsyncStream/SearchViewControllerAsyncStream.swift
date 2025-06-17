import UIKit

/// A view controller that demonstrates debounced search using AsyncStream
final class SearchViewControllerAsyncStream: UIViewController {
    private let textField = UITextField()
    private let resultLabel = UILabel()
    /// The continuation used to feed values into the AsyncStream
    private var continuation: AsyncStream<String>.Continuation?
    /// A static list of mock product names used to simulate search results
    private let data = ["MacBook", "iMac", "iPad", "Mac Mini", "iPhone"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAsyncStream()
    }
    
    /// Sets up the UI: a UITextField and a UILabel
    private func setupUI() {
        view.backgroundColor = .white
        
        textField.borderStyle = .roundedRect
        textField.placeholder = "Type to search..."
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        resultLabel.textColor = .black
        resultLabel.numberOfLines = 0
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        view.addSubview(resultLabel)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            resultLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            resultLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            resultLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor)
        ])
    }
    
    /// Triggered whenever the text field content changes.
    /// Sends the new value into the AsyncStream.
    @objc private func textDidChange() {
        if let text = textField.text {
            continuation?.yield(text)
        }
    }
    
    /// Initializes the AsyncStream and processes values with debounce logic
    private func setupAsyncStream() {
        let stream = AsyncStream<String> { continuation in
            self.continuation = continuation
        }
        
        Task {
            /// Process values with 0.5 second debounce delay
            for await query in stream.debounced(for: 0.5) {
                await performSearch(for: query)
            }
        }
    }
    
    /// Simulates an async search operation with delay and filtering
    private func performSearch(for query: String) async {
        guard !query.isEmpty else {
            updateResults(with: [])
            return
        }
        /// Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        
        let filtered = data.filter { $0.localizedCaseInsensitiveContains(query) }
        
        updateResults(with: filtered)
    }
    
    /// Updates the result label on the main thread
    @MainActor
    private func updateResults(with items: [String]) {
        resultLabel.text = items.isEmpty 
        ? "🔍 No results"
        : "✅ Found: \(items.joined(separator: ", "))"
    }
    
}
