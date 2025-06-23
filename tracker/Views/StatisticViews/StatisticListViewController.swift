import UIKit

final class StatisticListViewController: UIViewController {
    private let store = TrackerRecordStore()
    private var Record: [TrackerRecord]{
        store.trackerRecords
    }
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let placeholderImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .noStats)
        image.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    private let viewCornerColor: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(resource: .selection1).cgColor,
            UIColor(resource: .selection5).cgColor,
            UIColor(resource: .selection3).cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        return gradient
    }()
    private let borderStatView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let statView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34,weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let statLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.text = "Трекеров завершено"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .ypWhite
        setupUI()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewCornerColor.frame = borderStatView.bounds
        if viewCornerColor.superlayer == nil {
            borderStatView.layer.insertSublayer(viewCornerColor, at: 0)
            borderStatView.layer.cornerRadius = 16
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkRecordCount()
    }
    fileprivate func checkRecordCount() {
        countLabel.text = "\(Record.count)"
        if Record.count > 0 {
            placeholderImage.isHidden = true
            placeholderLabel.isHidden = true
            statLabel.isHidden = false
            countLabel.isHidden = false
            borderStatView.isHidden = false
            statView.isHidden = false
        } else {
            statLabel.isHidden = true
            countLabel.isHidden = true
            borderStatView.isHidden = true
            statView.isHidden = true
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
        }
    }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [countLabel,statLabel])
        stack.axis = .vertical
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(borderStatView)
        view.addSubview(titleLabel)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        borderStatView.addSubview(statView)
        statView.addSubview(stack)
        checkRecordCount()
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor,constant: 8),
            
            borderStatView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            borderStatView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            borderStatView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            borderStatView.heightAnchor.constraint(equalToConstant: 90),
            
            statView.topAnchor.constraint(equalTo: borderStatView.topAnchor, constant: 1),
            statView.leadingAnchor.constraint(equalTo: borderStatView.leadingAnchor, constant: 1),
            statView.trailingAnchor.constraint(equalTo: borderStatView.trailingAnchor, constant: -1),
            statView.bottomAnchor.constraint(equalTo: borderStatView.bottomAnchor, constant: -1),
            
            stack.leadingAnchor.constraint(equalTo: statView.leadingAnchor, constant: 12),
            stack.centerYAnchor.constraint(equalTo: statView.centerYAnchor)
        ])
    }
}

extension StatisticListViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        checkRecordCount()
    }
}
