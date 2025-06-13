import UIKit

final class ScheduleViewController: UIViewController{
    
    let backgroundView = UIView()
    let tableView = UITableView()
    let readyButton = UIButton()
    var schedule:Set<Weekday>
    var onSchedulePicked: ((Set<Weekday>) -> Void)?
    let week = ["Понедельник","Вторник","Среда","Четверг","Пятница","Суббота","Воскресенье"]
    init(schedule:Set<Weekday>) {
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
    @objc func readyButtonTapped(){
        onSchedulePicked?(schedule)
        navigationController?.popViewController(animated: true)
    }
    
    func setupUI(){
        title = "Расписание"
        view.backgroundColor = .ypWhite
        navigationItem.hidesBackButton = true
        setupReadyButton()
        setupBackgroundView()
        setupTableView()
    }
    
    func setupReadyButton(){
        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitleColor(.ypWhite, for: .normal)
        readyButton.backgroundColor = .ypBlack
        readyButton.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        readyButton.layer.cornerRadius = 16
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(readyButton)
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            readyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupBackgroundView(){
        backgroundView.backgroundColor = .ypGray
        backgroundView.layer.cornerRadius = 16
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            backgroundView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -47)
        ])
    }
    
    func setupTableView(){
        tableView.register(ScheduleViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
        ])
    }
}
extension ScheduleViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        week.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ScheduleViewCell
        let weekday = Weekday.allCases[indexPath.row]
        cell.configure(with: weekday, isOn: schedule.contains(weekday))
        tableView.rowHeight = 75
        
        if indexPath.row == 0 {
            cell.divider.isHidden = true
        }
        
        cell.switchChanged = { [weak self] isOn in
            if isOn {
                self?.schedule.insert(weekday)
            } else {
                self?.schedule.remove(weekday)
            }
        }
        return cell
    }
}
extension ScheduleViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let weekday = Weekday.allCases[indexPath.row]
        if schedule.contains(weekday) {
            schedule.remove(weekday)
        } else {
            schedule.insert(weekday)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
