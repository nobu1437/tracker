import UIKit

final class TrackerTypeViewController: UIViewController {
   private var schedule = Set<Weekday>()
    
  private let scrollView = UIScrollView()
   private let textField = UITextField()
  private  let deleteButton = UIButton()
  private  let addButton = UIButton()
  private  let tableView = UITableView()
    weak var delegate: AddTrackerDelegate?
    
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
            self?.schedule = Set(selectedDays)
            self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addButtonTapped() {
        guard let text = textField.text else { return }
             let tracker = Tracker(name: text,
                              color: .blue,
                              emoji: "🤪",
                              schedule: isRegular ? self.schedule : Set(arrayLiteral: .monday,.tuesday,.wednesday,.thursday,.friday,.saturday,.sunday), 
                                   isRegular: isRegular ? true : false)
        delegate?.didAddTracker(tracker)
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
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 8
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.addArrangedSubview(deleteButton)
        hStack.addArrangedSubview(addButton)
        view.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 20),
            hStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hStack.heightAnchor.constraint(equalToConstant: 60)
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
