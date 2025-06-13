import UIKit

class TrackerTypeViewController: UIViewController {
    
    var task: Tracker = .init(name: "", color: .clear, emoji: "", schedule: [])
    
    let scrollView = UIScrollView() //nextsprint
    let firstButtonImage = UIImageView()
    let secondButtonImage = UIImageView()
    let firstButtonSubtitle = UILabel() //next sprint
    let secondButtonSubtitle = UILabel()
    let errorLabel = UILabel()
    let backgroundView = UIView()
    let divider = UIView()
    let textField = UITextField()
    let firstButton = UIButton()
    let secondButton = UIButton()
    let deleteButton = UIButton()
    let addButton = UIButton()
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
        setupUI()
    }
    
    @objc func categoryButtonTapped(){
        
    }
    
    @objc func scheduleButtonTapped(){
        let scheduleVC = ScheduleViewController(schedule: task.schedule)
        scheduleVC.onSchedulePicked = { [weak self] selectedDays in
            self?.task.schedule = selectedDays
            self?.secondButtonSubtitle.text = selectedDays.map { $0.shortTitle }.joined(separator: ", ")
            self?.secondButtonSubtitle.isHidden = false
            self?.view.layoutIfNeeded()
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc func deleteButtonTapped(){
        dismiss(animated: true)
    }
    
    @objc func addButtonTapped() {
        let tracker = Tracker(name: textField.text!, color: .blue, emoji: "🤪", schedule: self.task.schedule)
        delegate?.didAddTracker(tracker)
        dismiss(animated: true)
    }
    
    func setupUI(){
        navigationItem.hidesBackButton = true
        view.backgroundColor = .ypWhite
        title = isRegular ? "Новая привычка" : "Новое нерегулярное событие"
        setupTextField()
        setupBottomStackView()
        setupBackgroundView()
        setupDivder()
        setupFirstButton()
        setupSecondButton()
        setupFirstImage()
    }
    
    func setupTextField(){
        textField.backgroundColor = .ypBackground
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 20
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    func setupBackgroundView(){
        backgroundView.backgroundColor = .ypBackground
        backgroundView.layer.cornerRadius = 20
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            backgroundView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backgroundView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            backgroundView.heightAnchor.constraint(equalToConstant: isRegular ? 150 : 75)
        ])
    }
    
    func setupDivder(){
        divider.backgroundColor = .systemGray.withAlphaComponent(0.3)
        divider.translatesAutoresizingMaskIntoConstraints = false
        if isRegular{
            backgroundView.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
                divider.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
                divider.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
                divider.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
    
    func setupFirstButton(){
        firstButton.setAttributedTitle(NSAttributedString(string: "Категория",
                                                          attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular)]), for: .normal)
        firstButton.contentHorizontalAlignment = .left
        firstButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        firstButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        firstButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(firstButton)
        NSLayoutConstraint.activate([
            firstButton.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            firstButton.bottomAnchor.constraint(equalTo: isRegular ? divider.topAnchor : backgroundView.bottomAnchor),
            firstButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor)
        ])
    }
    func setupSecondButton(){
        secondButton.setAttributedTitle(NSAttributedString(string: "Расписание",
                                                           attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular)]), for: .normal)
        secondButton.contentHorizontalAlignment = .left
        secondButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        secondButton.translatesAutoresizingMaskIntoConstraints = false
        
        secondButtonSubtitle.text = task.schedule.map {$0.shortTitle}.joined(separator: ", ")
        secondButtonSubtitle.textColor = .ypGray
        secondButtonSubtitle.font = .systemFont(ofSize: 17, weight: .regular)
        secondButtonSubtitle.translatesAutoresizingMaskIntoConstraints = false
        secondButtonSubtitle.numberOfLines = 1
        
        let secondStack = UIStackView()
        secondStack.axis = .vertical
        secondStack.addArrangedSubview(secondButton)
        secondStack.addArrangedSubview(secondButtonSubtitle)
        secondStack.translatesAutoresizingMaskIntoConstraints = false
        if task.schedule.isEmpty{
            secondButtonSubtitle.isHidden = true
        }
        if isRegular{
            backgroundView.addSubview(secondStack)
            NSLayoutConstraint.activate([
                secondStack.topAnchor.constraint(equalTo: divider.topAnchor),
                secondStack.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
                secondStack.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor,constant: 16)
            ])
            setupSecondImage(stackView: secondStack)
        }
    }
    func setupFirstImage(){
        firstButtonImage.image = UIImage(systemName: "chevron.right")
        firstButtonImage.tintColor = .ypGray
        firstButtonImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(firstButtonImage)
        NSLayoutConstraint.activate([
            firstButtonImage.heightAnchor.constraint(equalToConstant: 12),
            firstButtonImage.widthAnchor.constraint(equalToConstant: 7),
            firstButtonImage.centerYAnchor.constraint(equalTo: firstButton.centerYAnchor),
            firstButtonImage.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16)
        ])
    }
    func setupSecondImage(stackView:UIStackView){
        secondButtonImage.image = UIImage(systemName: "chevron.right")
        secondButtonImage.tintColor = .ypGray
        secondButtonImage.translatesAutoresizingMaskIntoConstraints = false
        if isRegular{
            backgroundView.addSubview(secondButtonImage)
            NSLayoutConstraint.activate([
                secondButtonImage.heightAnchor.constraint(equalToConstant: 12),
                secondButtonImage.widthAnchor.constraint(equalToConstant: 7),
                secondButtonImage.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
                secondButtonImage.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16)
            ])
        }
    }
    func setupBottomStackView(){
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
    func setupDeleteButton(){
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
    func setupAddButton(){
        addButton.setTitle("Создать", for: .normal)
        addButton.setTitleColor(.ypWhite, for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped),
                            for: .touchUpInside)
        addButton.backgroundColor = .ypGray
        addButton.layer.cornerRadius = 16
        addButton.translatesAutoresizingMaskIntoConstraints = false
    }
}
