import UIKit

final class ScheduleViewController: UIViewController {
    
    let tableView = UITableView()
    let readyButton = UIButton()
    var schedule:[Weekday]
    var onSchedulePicked: (([Weekday]) -> Void)?
    
    let week = ["Понедельник","Вторник","Среда","Четверг","Пятница","Суббота","Воскресенье"]
    
    init(schedule:[Weekday]) {
        self.schedule = schedule
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    @objc func readyButtonTapped() {
        onSchedulePicked?(schedule)
        navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        title = "Расписание"
        view.backgroundColor = .ypWhite
        navigationItem.hidesBackButton = true
        setupReadyButton()
        setupTableView()
    }
    
    func setupReadyButton() {
        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitleColor(.ypWhite, for: .normal)
        readyButton.backgroundColor = .ypBlack
        readyButton.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        readyButton.layer.cornerRadius = 16
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(readyButton)
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            readyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupTableView() {
        tableView.register(ScheduleViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
            tableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor,constant: -47)
        ])
    }
}
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(week.count)
       return week.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ScheduleViewCell else
        { assertionFailure("no cell at scheduleViewCell")
            return UITableViewCell()
        }
        let weekday = Weekday.allCases[indexPath.row]
        cell.configure(with: weekday, isOn: schedule.contains(weekday))
        if indexPath.row == 0{
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if indexPath.row == week.count - 1 {
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        
        }
        print("cellForRowAt", indexPath.row)
        cell.switchChanged = { [weak self] isOn in
            if isOn {
                self?.schedule.append(weekday)
            } else {
                self?.schedule.remove(at: self?.schedule.firstIndex(of: weekday) ?? 0)
            }
        }
        return cell
    }
}
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let weekday = Weekday.allCases[indexPath.row]
        if schedule.contains(weekday) {
            self.schedule.remove(at: self.schedule.firstIndex(of: weekday) ?? 0)
        } else {
            schedule.append(weekday)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
