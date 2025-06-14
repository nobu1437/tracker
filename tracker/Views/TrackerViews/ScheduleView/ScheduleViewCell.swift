import UIKit

final class ScheduleViewCell:UITableViewCell {
    let title = UILabel()
    let dateSwitch = UISwitch()
    
    var switchChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        title.font = .systemFont(ofSize: 17, weight: .regular)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        dateSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        dateSwitch.onTintColor = .ypBlue
        dateSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.addSubview(title)
        contentView.addSubview(dateSwitch)
        
        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: centerYAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dateSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    @objc private func switchValueChanged() {
        switchChanged?(dateSwitch.isOn)
    }
    func configure(with weekday: Weekday, isOn: Bool) {
        title.text = weekday.title
        dateSwitch.isOn = isOn
        contentView.backgroundColor = .ypBackground
    }
}
