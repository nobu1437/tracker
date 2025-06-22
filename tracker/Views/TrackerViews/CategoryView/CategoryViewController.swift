import UIKit

class CategoryViewController: UIViewController{
    let viewModel = CategoryViewModel()
    private var categories: [TrackerCategory] = []
    let checkedCategory: String?
    var categoriesPicked: ((String) -> Void)?
    
    var addCategoryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.setTitle(NSLocalizedString("categoryview.addcategory.button", comment: ""), for: .normal)
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
        label.text = NSLocalizedString("categoryview.placeholder.title", comment: "")
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
        title = NSLocalizedString("createhabit.category.title", comment: "")
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
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func addCategory() {
        let vc = NewCategoryViewController(isNewCategory: true, categoryName: nil)
        vc.onCategoryCreated = { [weak self] in
            self?.viewModel.loadCategories()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    private func configureCorners(for cell: UITableViewCell, at indexPath: IndexPath) {
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == categories.count - 1

        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.cornerRadius = 0
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        if isFirst && isLast {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                                     .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.contentView.layer.cornerRadius = 0
        }
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
        print(categories.count)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        cell.checkmark.isHidden = !(category.name == checkedCategory) 
       configureCorners(for: cell, at: indexPath)
        if indexPath.row == categories.count - 1 {
            print("прячу сепаратор")
            cell.separatorView.isHidden = true
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
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = categories[indexPath.row]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: NSLocalizedString("categoryview.edit.title", comment: "")) { [weak self] _ in
                    guard let self = self else { return }
                    let vc = NewCategoryViewController(isNewCategory: true, categoryName: category.name)
                    vc.onCategoryCreated = { [weak self] in
                        self?.viewModel.loadCategories()
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                },
                UIAction(title: NSLocalizedString("categoryview.delete.title", comment: ""), attributes: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    let alert = viewModel.makeAlert(category: category.name)
                    present(alert, animated: true)
                }
            ])
        })
    }
}
extension CategoryViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        tableView.reloadData()
    }
}
