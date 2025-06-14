import UIKit

final class TrackerListSupView: UICollectionReusableView{
   let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 19,weight: .bold)
        titleLabel.textColor = .ypBlack
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
