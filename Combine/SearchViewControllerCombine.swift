import UIKit
import Combine

/// A view controller that demonstrates debounced search using Combine framework
final class SearchViewControllerCombine: UIViewController {
    
    private let textField = UITextField()
    private let resultLabel = UILabel()
    /// Stores Combine subscriptions to manage memory
    private var cancellables = Set<AnyCancellable>()
    /// Publishes user input text for the Combine pipeline
    private let searchSubject = PassthroughSubject<String, Never>()
    /// A static list of mock product names used to simulate search results
    private let mockData = ["MacBook", "iMac", "iPad", "iPhone", "Mac Mini"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCombine()
    }
    
    /// Sets up the interface layout and input handling
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
    
    /// Called on every text field change to emit the new input through Combine
    @objc private func textDidChange() {
        if let text = textField.text {
            searchSubject.send(text)
        }
    }

    /// Configures the Combine pipeline for observing and processing search input
    private func setupCombine() {
        searchSubject
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .flatMap { [weak self] query -> AnyPublisher<[String], Never> in
                /// Triggers a mock search and returns a publisher
                self?.performSearch(for: query) ?? Just([]).eraseToAnyPublisher()
            }
            /// Ensures UI updates occur on main thread
            .receive(on: RunLoop.main)
            .sink { [weak self] results in
                self?.updateResults(with: results)
            }
            .store(in: &cancellables)
    }

    /// Simulates a network-based search by filtering mock data with delay
    private func performSearch(for query: String) -> AnyPublisher<[String], Never> {
        guard !query.isEmpty else {
            return Just([]).eraseToAnyPublisher()
        }
        
        /// Filters results that contain the query (case-insensitive)
        let filtered = mockData.filter { $0.localizedCaseInsensitiveContains(query) }

        /// Simulates network delay and returns results as a Combine publisher
        return Just(filtered)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
    }

    /// Updates the UI with search results
    private func updateResults(with items: [String]) {
        resultLabel.text = items.isEmpty 
        ? "🔍 No results"
        : "✅ Found: \(items.joined(separator: ", "))"
    }
    
}
