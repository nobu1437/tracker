import UIKit

final class CategoryTableVIewCell: UITableViewCell{
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let checkmark: UIImageView = {
        let image = UIImageView ()
        image.image = UIImage(systemName: "checkmark")
        image.tintColor = .systemBlue
        image.isHidden = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(label)
        contentView.addSubview(checkmark)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            checkmark.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            checkmark.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
