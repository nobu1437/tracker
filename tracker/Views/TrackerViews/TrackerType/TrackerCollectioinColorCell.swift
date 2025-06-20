import UIKit

class TrackerCollectioinColorCell: UICollectionViewCell {
    let borderView = UIView()
    let colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        borderView.backgroundColor = .clear
        borderView.layer.cornerRadius = 8
        borderView.translatesAutoresizingMaskIntoConstraints = false
        
        colorView.layer.cornerRadius = 8
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        borderView.addSubview(colorView)
        contentView.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            borderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            borderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            borderView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            borderView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            colorView.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
