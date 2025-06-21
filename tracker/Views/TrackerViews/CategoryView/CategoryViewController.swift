import UIKit

class CategoryViewController: UIViewController{
    let viewModel = CategoryViewModel()
    private var categories: [TrackerCategory] = []
    let checkedCategory: String?
    var categoriesPicked: ((String) -> Void)?
    
    var addCategoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitle("Добавить Категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .noTracked
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    init(checkedCategory: String?){
        self.checkedCategory = checkedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadCategories()
        setupUI()
    }
    
    private func bindViewModel() {
        viewModel.categoriesBinding = { [weak self] categories in
            self?.categories = categories
            self?.tableView.reloadData()
            self?.updatePlaceholderVisibility()
        }
    }
    private func updatePlaceholderVisibility() {
        let isEmpty = categories.isEmpty
        placeholderLabel.isHidden = !isEmpty
        placeholderImageView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func setupUI(){
        navigationItem.hidesBackButton = true
        view.backgroundColor = .ypWhite
        title = "Категория"
        addCategoryButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryTableVIewCell.self, forCellReuseIdentifier: "cell")
        updatePlaceholderVisibility()
        view.addSubview(tableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(addCategoryButton)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func addCategory() {
        let vc = NewCategoryViewController()
        vc.onCategoryCreated = { [weak self] in
            self?.viewModel.loadCategories()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoryViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryTableVIewCell else
        { assertionFailure("no cell at CategoryTableVIewCell")
            return UITableViewCell()
        }
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        cell.checkmark.isHidden = !(category.name == checkedCategory) 
        if indexPath.row == 0{
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if indexPath.row == categories.count - 1 {
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset.right = .greatestFiniteMagnitude
        }
        cell.contentView.backgroundColor = .ypBackground
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        guard let name = viewModel.selectedCategoryName else { return }
        print(name)
        categoriesPicked?(name)
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
}
