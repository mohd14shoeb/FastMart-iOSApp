import UIKit

// MARK: - SideMenu ViewController

final class SideMenuViewController: UIViewController {

    private let viewModel: SideMenuViewModel
    private var tableView: UITableView!
    private var dataSource: UITableViewDiffableDataSource<Int, SideMenuItem>!

    // MARK: - Header

    private let headerView   = UIView()
    private let avatarView   = UIView()
    private let avatarLabel  = UILabel()
    private let nameLabel    = UILabel()
    private let emailLabel   = UILabel()

    init(viewModel: SideMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
        applySnapshot()
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // ── Header ─────────────────────────────────────────────────
        headerView.backgroundColor = .systemIndigo
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        // Avatar circle
        avatarView.backgroundColor = .white
        avatarView.layer.cornerRadius = 30
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(avatarView)

        avatarLabel.text = "SK"
        avatarLabel.font = .systemFont(ofSize: 22, weight: .bold)
        avatarLabel.textColor = .systemIndigo
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarLabel)

        nameLabel.text = viewModel.userName
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(nameLabel)

        emailLabel.text = viewModel.userEmail
        emailLabel.font = .systemFont(ofSize: 13)
        emailLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(emailLabel)

        // ── TableView ──────────────────────────────────────────────
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        view.addSubview(tableView)

        // ── Logout Button ──────────────────────────────────────────
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        view.addSubview(logoutButton)

        // ── Layout ─────────────────────────────────────────────────
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 160),

            avatarView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            avatarView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            avatarView.widthAnchor.constraint(equalToConstant: 60),
            avatarView.heightAnchor.constraint(equalToConstant: 60),

            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            // Table
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Logout
            logoutButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    // MARK: - DataSource

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, SideMenuItem>(
            tableView: tableView
        ) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var config = UIListContentConfiguration.cell()
            config.text = item.title
            config.image = UIImage(systemName: item.icon)
            config.imageProperties.tintColor = .systemIndigo
            cell.contentConfiguration = config
            cell.backgroundColor = .clear
            cell.selectionStyle = .none

            // Highlight indicator
            let bg = UIView()
            bg.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.08)
            bg.layer.cornerRadius = 10
            cell.selectedBackgroundView = bg

            return cell
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SideMenuItem>()
        for (index, section) in viewModel.sections.enumerated() {
            snapshot.appendSections([index])
            snapshot.appendItems(section.items)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Actions

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Logout", message: "Are you sure?", preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.viewModel.onLogout?()
        })
        present(alert, animated: true)
    }
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[section].title
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.onSelect?(item)
    }
}
