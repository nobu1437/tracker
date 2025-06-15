import UIKit

final class AddTrackerViewController: UIViewController {
    private let regularButton = UIButton()
    private  let irregularButton = UIButton()
    private var isRegular = false
    weak var delegate: AddTrackerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        view.backgroundColor = .ypWhite
        title = "Создание Трекера"
        regularButton.tintColor = .ypWhite
        regularButton.setTitle("Привычка", for: .normal)
        regularButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        regularButton.backgroundColor = .ypBlack
        regularButton.layer.cornerRadius = 16
        regularButton.translatesAutoresizingMaskIntoConstraints = false
        regularButton.addTarget(self, action: #selector(regularButtonTapped), for: .touchUpInside)
        
        irregularButton.tintColor = .ypWhite
        irregularButton.setTitle("Нерегулярные событие", for: .normal)
        irregularButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        irregularButton.backgroundColor = .ypBlack
        irregularButton.layer.cornerRadius = 16
        irregularButton.translatesAutoresizingMaskIntoConstraints = false
        irregularButton.addTarget(self, action: #selector(irregularButtonTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [regularButton,irregularButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            regularButton.heightAnchor.constraint(equalToConstant: 60),
            irregularButton.heightAnchor.constraint(equalToConstant: 60),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    @objc private func regularButtonTapped() {
        isRegular = true
        let vc = TrackerTypeViewController(isRegular: isRegular)
        vc.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func irregularButtonTapped() {
        isRegular = false
        let vc = TrackerTypeViewController(isRegular: isRegular)
        vc.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
    }
}
