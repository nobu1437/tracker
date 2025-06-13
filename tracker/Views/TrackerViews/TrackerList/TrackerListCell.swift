import UIKit

final class TrackerListCell: UICollectionViewCell {
    static let reuseIdentifier = "cell"
    
    weak var delegate: TrackerListDelegate?

    let titleLabel = UILabel()
    let emojiLabel = UILabel()
    let daysCount = UILabel()
    let addButton = UIButton()
    let backgroundColorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    private func setupUI(){
        backgroundColorView.layer.cornerRadius = 16
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColorView.clipsToBounds = true
        contentView.addSubview(backgroundColorView)

        emojiLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emojiLabel.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundColorView.addSubview(emojiLabel)

        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .ypWhite
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundColorView.addSubview(titleLabel)

        daysCount.font = .systemFont(ofSize: 12, weight: .medium)
        daysCount.textColor = .ypBlack
        daysCount.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysCount)

        addButton.layer.cornerRadius = 17
        addButton.tintColor = .ypWhite
        addButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addButton)
        addButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundColorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundColorView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: backgroundColorView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundColorView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundColorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundColorView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: backgroundColorView.bottomAnchor, constant: -12),

            daysCount.topAnchor.constraint(equalTo: backgroundColorView.bottomAnchor, constant: 16),
            daysCount.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCount.heightAnchor.constraint(equalToConstant: 18),

            addButton.centerYAnchor.constraint(equalTo: daysCount.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: daysCount.trailingAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func didTapButton(){
        delegate?.DidTapButton(self)
    }
}
