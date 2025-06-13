import UIKit

class TrackerListViewController: UIViewController{
    lazy var collectionView = UICollectionView()
    var currentDate = Date()
    var addTracker = UIButton()
    var datePicker = UIDatePicker()
    var titleLabel = UILabel()
    var searchBar = UISearchBar()
    var imageView = UIImageView()
    var emptyLabel = UILabel()
    var firstCategory:TrackerCategory = .init(name: "first", trackers: [.init(name: "name", color: UIColor._1, emoji: "😃", schedule: [.monday,.sunday,.friday,.saturday],)])
    
    var completedTrackers: [TrackerRecord] = []
    var categories: [TrackerCategory] = []
    var visibleCategories: [TrackerCategory] {
        let weekday = currentDate.weekday
        return categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(weekday)
            }
            return TrackerCategory(name: category.name, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstCategory.trackers.append(.init(name: "second", color: UIColor.green, emoji: "🤣", schedule: [.friday]))
        categories.append(firstCategory)
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        hidePlaceholderView()
        collectionView.reloadData()
    }
    
    func setupUI() {
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(buttonTapped)
        )
        addButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = addButton
        self.view.backgroundColor = .ypWhite
        setupTitleLabel()
        setupDatePicker()
        setupSearchbar()
        setupCollectionView()
        setupImageView()
        setupEmptyLabel()
    }
    
    @objc func dateChanged(){
        currentDate = datePicker.date
        hidePlaceholderView()
        collectionView.reloadData()
    }
    
    @objc func buttonTapped() {
        let addVC = AddTrackerViewController()
        addVC.delegate = self
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
    
    private func hidePlaceholderView(){
        if !visibleCategories.isEmpty {
            imageView.isHidden = true
            emptyLabel.isHidden = true
        } else {
            imageView.isHidden = false
            emptyLabel.isHidden = false
        }
    }
    
    func setupCollectionView(){
        collectionView = layoutCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.register(TrackerListCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(TrackerListSupView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    func layoutCollectionView() -> UICollectionView{
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 60) / 2, height: 148)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 18)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    func setupTitleLabel(){
        titleLabel.text = "Трекеры"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .ypBlack
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
    }
    
    func setupDatePicker(){
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: 110),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    func setupSearchbar(){
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    func setupImageView(){
        imageView.image = UIImage(resource: .noTracked)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func setupEmptyLabel(){
        emptyLabel.text = "Что будем отслеживать?"
        emptyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptyLabel.textAlignment = .center
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            emptyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}

extension TrackerListViewController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //логика фильтрации
    }
}

extension TrackerListViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerListCell
        cell?.delegate = self
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        cell?.addButton.backgroundColor = tracker.color
        cell?.addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        
        for completedTracker in completedTrackers{
            if completedTracker.trackerId == tracker.id {
                for date in completedTracker.date{
                    if date.stripped() == datePicker.date.stripped(){
                        cell?.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                        cell?.addButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
                        break
                    }
                }
            }
        }
        
        cell?.titleLabel.text = "\(tracker.name)"
        cell?.backgroundColorView.backgroundColor = tracker.color
        cell?.emojiLabel.text = tracker.emoji
        var count = 0
        for trackers in completedTrackers{
            if tracker.id == trackers.trackerId{
                count = trackers.date.count
            }
        }
        cell?.daysCount.text = "\(count) дней"
        return cell!
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as! TrackerListSupView
            
            let categoryName = visibleCategories[indexPath.section].name
            header.titleLabel.text = categoryName
            return header
        }
        
        return UICollectionReusableView()
    }
}
extension TrackerListViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        
        let indexPath = indexPaths[0]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Закрепить") { [weak self] _ in                // 6
//                    self?.categories[indexPath.section].trackers[indexPath.item].isPinned.toggle()
                },
                UIAction(title: "Редактировать") { [weak self] _ in              // 7
                    
                },
                UIAction(title: "Удалить") { [weak self] _ in
//                    self?.categories[indexPath.section].trackers.remove(at: indexPath.item)
                },
            ])
        })
    }
}
extension TrackerListViewController: TrackerListDelegate{
    func DidTapButton(_ cell: TrackerListCell) {
        let cellIndexPath = collectionView.indexPath(for: cell)!
        
        let tracker = visibleCategories[cellIndexPath.section].trackers[cellIndexPath.item]
        
        cell.addButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
        cell.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        cell.addButton.isUserInteractionEnabled = false
        print("метод сработал")
        collectionView.reloadData()
        var count = 0
        for completedTracker in self.completedTrackers {
            if completedTracker.trackerId == tracker.id {
                completedTracker.date.append(datePicker.date)
                count = completedTracker.date.count
                cell.daysCount.text = "\(count) дней"
                return
            }
        }
        completedTrackers.append(.init(trackerId: tracker.id, date:[ datePicker.date.stripped()]))
    }
}

extension TrackerListViewController: AddTrackerDelegate {
    func didAddTracker(_ tracker: Tracker) {
        categories[0].trackers.append(tracker)
        collectionView.reloadData()
    }
}
