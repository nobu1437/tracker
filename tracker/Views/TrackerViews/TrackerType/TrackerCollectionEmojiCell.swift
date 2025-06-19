import UIKit

class TrackerCollectionEmojiCell: UICollectionViewCell {
    
    let label = UILabel()
    let backgroundColorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColorView.backgroundColor = .clear
        backgroundColorView.layer.cornerRadius = 16
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        backgroundColorView.addSubview(label)
        contentView.addSubview(backgroundColorView)
        NSLayoutConstraint.activate([
            backgroundColorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundColorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backgroundColorView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            backgroundColorView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            label.centerXAnchor.constraint(equalTo: backgroundColorView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: backgroundColorView.centerYAnchor)
        ])
    }
}
