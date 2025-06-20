import UIKit

final class TrackerTypeViewController: UIViewController {
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private var schedule: [Weekday] = []
    private let emojiArray = ["🙂","😻","🌺","🐶","️❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝","😪"]
    private let colorArray: [UIColor] = [._1,._2,._3,._4,._5,._6,._7,._8,._9,._10,._11,._12,._13,._14,._15,._16,._17,._18]
    private let categoryNames = ["Emoji","Цвет"]
    private var checkedEmoji: String?
    private var checkedCategory: String?
    private var checkedColor: UIColor?
    private let textField = UITextField()
    private let deleteButton = UIButton()
    private let addButton = UIButton()
    private let tableView = UITableView()
    private let bottomStack = UIStackView()
    private lazy var collectionView = UICollectionView()
    
    var isRegular: Bool
    
    init(isRegular: Bool) {
        self.isRegular = isRegular
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
    
    @objc private func categoryButtonTapped() {
        
    }
    
    @objc private func scheduleButtonTapped() {
        let scheduleVC = ScheduleViewController(schedule: schedule)
        scheduleVC.onSchedulePicked = { [weak self] selectedDays in
            self?.schedule = selectedDays
            self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addButtonTapped() {
        print("buttonTapped")
        guard let text = textField.text else { return }
        guard let checkedEmoji = checkedEmoji else { return }
        guard let checkedColor = checkedColor else { return }
        
        let tracker = Tracker(name: text,
                              color: checkedColor,
                              emoji: checkedEmoji,
                              schedule: isRegular ? self.schedule : [.monday,.tuesday,.wednesday,.thursday,.friday,.saturday,.sunday], isRegular: isRegular ? true : false)
        
        let categoryName = checkedCategory ?? "Новая категория"
        try? trackerStore.addNewTracker(tracker, to: categoryName)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(){
        if let text = textField.text, text.count >= 1 {
            addButton.isUserInteractionEnabled = true
            addButton.backgroundColor = .ypBlack
        } else {
            addButton.isUserInteractionEnabled = false
            addButton.backgroundColor = .ypGray
        }
    }
    
    private func  setupUI(){
        navigationItem.hidesBackButton = true
        view.backgroundColor = .ypWhite
        title = isRegular ? "Новая привычка" : "Новое нерегулярное событие"
        setupTextField()
        setupBottomStackView()
        setupTableView()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView = layoutCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.register(TrackerCollectionEmojiCell.self, forCellWithReuseIdentifier: "emojiCell")
        collectionView.register(TrackerCollectioinColorCell.self, forCellWithReuseIdentifier: "colorCell")
        collectionView.register(TrackerListSupView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor,constant: 16),
            collectionView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor,constant: -16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
    }
    
    private  func layoutCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - (16 * 2 + 5 * 5)) / 6, height: 52)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 18)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    private func  setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .ypBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TrackerTypeCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor,constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: isRegular ? 150 : 75)
        ])
    }
    private  func  setupTextField() {
        textField.backgroundColor = .ypBackground
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 20
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func  setupBottomStackView() {
        setupDeleteButton()
        setupAddButton()
        bottomStack.axis = .horizontal
        bottomStack.distribution = .fillEqually
        bottomStack.spacing = 8
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.addArrangedSubview(deleteButton)
        bottomStack.addArrangedSubview(addButton)
        view.addSubview(bottomStack)
        NSLayoutConstraint.activate([
            bottomStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 20),
            bottomStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    private func  setupDeleteButton() {
        deleteButton.setTitle("Отменить", for: .normal)
        deleteButton.setTitleColor(.ypRed, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped),
                               for: .touchUpInside)
        deleteButton.layer.cornerRadius = 16
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = CGColor(red: 0.96, green: 0.42, blue: 0.42, alpha: 1)
        deleteButton.backgroundColor = .clear
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
    }
    private func setupAddButton() {
        addButton.setTitle("Создать", for: .normal)
        addButton.setTitleColor(.ypWhite, for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped),
                            for: .touchUpInside)
        addButton.backgroundColor = .ypGray
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.isUserInteractionEnabled = false
    }
}
extension TrackerTypeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
extension TrackerTypeViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isRegular{
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TrackerTypeCell else
        { assertionFailure("no cell at TrackerTypeCell")
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.titleLabel.text = "Категория"
            cell.subtitleLabel.text = ""
            cell.subtitleLabel.isHidden = true
        } else {
            cell.titleLabel.text = "Расписание"
            if schedule.isEmpty{
                cell.subtitleLabel.isHidden = true
            } else {
                cell.subtitleLabel.text = schedule.map{$0.shortTitle}.joined(separator: ", ")
            }
        }
        if indexPath.row == (isRegular ? 1 : 0) {
            cell.separatorInset.left = .greatestFiniteMagnitude
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
extension TrackerTypeViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            scheduleButtonTapped()
        }
    }
}
extension TrackerTypeViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? TrackerCollectionEmojiCell
            else {
                assertionFailure("no cell at TrackerListCell")
                return UICollectionViewCell()
            }
            cell.label.text = emojiArray[indexPath.item]
            cell.backgroundColorView.backgroundColor = emojiArray[indexPath.item] == checkedEmoji ? .ypLightGray : .clear
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? TrackerCollectioinColorCell else {
                assertionFailure("no cell at TrackerListCell")
                return UICollectionViewCell()
            }
            cell.colorView.backgroundColor = colorArray[indexPath.item]
            let isSelected = colorArray[indexPath.item] == checkedColor
            cell.borderView.layer.borderWidth = isSelected ? 3 : 0
            cell.borderView.layer.borderColor = isSelected ? colorArray[indexPath.item].cgColor : UIColor.clear.cgColor
            
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categoryNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? TrackerListSupView else {
                assertionFailure("no suppView at TrackerListSupView")
                return UICollectionReusableView()
            }
            
            let categoryName = categoryNames[indexPath.section]
            header.titleLabel.text = categoryName
            return header
        }
        
        return UICollectionReusableView()
    }
}

extension TrackerTypeViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            checkedEmoji = emojiArray[indexPath.item]
            collectionView.reloadSections(IndexSet(integer: 0))
        } else {
            checkedColor = colorArray[indexPath.item]
            collectionView.reloadSections(IndexSet(integer: 1))
        }
    }
}
