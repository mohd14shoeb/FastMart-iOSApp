import UIKit
import Combine

// MARK: - Home ViewController (Skeleton)

final class HomeViewController: UIViewController {
   
    private let label = UILabel()

    private let viewModel: HomeViewModel?

        private var cancellables =
            Set<AnyCancellable>()

        init(viewModel: HomeViewModel?) {
            self.viewModel = viewModel
            super.init(
                nibName: nil,
                bundle: nil
            )
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("Use init(viewModel:)")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemGroupedBackground
            navigationItem.title = "Home"
            configureUI()
            bindViewModel()
        }

        private func bindViewModel() {
            viewModel?.$dashboardData
                .receive(on: DispatchQueue.main)
                .sink { [weak self] data in
                    self?.render(data)
                }
                .store(in: &cancellables)
        }

        private func render(
            _ data:
                DashboardPrefetcher.DashboardData?
        ) {
            guard let data else {
                showEmptyOrLoadingState()
                return
            }

            // Update labels, collection views, etc.
        }

        private func configureUI() {
            view.backgroundColor =
                .systemBackground
        }

        private func showEmptyOrLoadingState() {
            label.text = "🏠 Home Dashboard"
            label.font = .systemFont(ofSize: 24, weight: .medium)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)

            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        }
}
