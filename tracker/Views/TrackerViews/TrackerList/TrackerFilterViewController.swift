import UIKit

final class TrackerFilterViewController: UIViewController{
    private let filters = ["Все Трекеры","Трекеры на сегодня","Завершенные","Не завершенные"]
    private var checkedFilter: TrackerFilter
    var onFilterSelected: ((TrackerFilter) -> Void)?
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(checkedFilter: TrackerFilter) {
        self.checkedFilter = checkedFilter
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .ypWhite
        title = "Фильтры"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryTableVIewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension TrackerFilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryTableVIewCell else
        { assertionFailure("no cell at CategoryTableVIewCell")
            return UITableViewCell()
        }
        let filter = filters[indexPath.row]
        let checkmarkFiletr = checkedFilter.rawValue
        cell.textLabel?.text = filter
        cell.checkmark.isHidden = !(indexPath.row == checkmarkFiletr)
        if indexPath.row == 0{
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if indexPath.row == filters.count - 1 {
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset.right = .greatestFiniteMagnitude
        }
        cell.contentView.backgroundColor = .ypBackground
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension TrackerFilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkedFilter = TrackerFilter(rawValue: indexPath.row) ?? checkedFilter
        onFilterSelected?(checkedFilter)
        dismiss(animated: true)
    }
}
