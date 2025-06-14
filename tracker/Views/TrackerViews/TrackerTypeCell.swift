import UIKit

final class TrackerTypeCell:UITableViewCell{
      let titleLabel = UILabel()
      let subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .ypBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textColor = .ypGray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
        
        accessoryType = .disclosureIndicator
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
