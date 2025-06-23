import UIKit

final class NewCategoryViewController: UIViewController {
    var onCategoryCreated: (() -> Void)?
    var isNewCategory: Bool
    var categoryName: String?
    
    private let viewModel = CategoryViewModel()
    private let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypBackground
        textField.placeholder = "Введите название категории"
        textField.layer.cornerRadius = 20
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private let readyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypGray
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    init(isNewCategory: Bool, categoryName:String?) {
        self.isNewCategory = isNewCategory
        self.categoryName = categoryName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.hidesBackButton = true
        view.backgroundColor = .ypWhite
        title = isNewCategory ? "Новая Категория" : "Редактирование категории"
        textField.text = categoryName
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(textField)
        readyButton.addTarget(self, action: #selector(ReadyTapped), for: .touchUpInside)
        view.addSubview(readyButton)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            readyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func ReadyTapped() {
        guard let name = textField.text, !name.isEmpty else { return }
        if isNewCategory{
            viewModel.addCategory(named: name)
        } else if let oldName = categoryName {
            viewModel.updateCategory(named: oldName, new: name)
        }
        onCategoryCreated?()
        navigationController?.popViewController(animated: true)
    }
    @objc private func textFieldDidChange() {
        if let text = textField.text, text.count >= 1 {
            readyButton.isUserInteractionEnabled = true
            readyButton.backgroundColor = .ypBlack
        } else {
            readyButton.isUserInteractionEnabled = false
            readyButton.backgroundColor = .ypGray
        }
    }
}
extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
