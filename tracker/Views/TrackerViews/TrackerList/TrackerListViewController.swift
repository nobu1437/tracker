import UIKit

final class TrackerListViewController: UIViewController{
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    
    private lazy var collectionView = UICollectionView()
    private var currentDate = Date()
    private var addTracker = UIButton()
    private var datePicker = UIDatePicker()
    private var titleLabel = UILabel()
    private var searchBar = UISearchBar()
    private var imageView = UIImageView()
    private var emptyLabel = UILabel()
    
    private var completedTrackers: [TrackerRecord]{
        trackerRecordStore.trackerRecords
    }
    private var categories: [TrackerCategory]{
        trackerCategoryStore.trackerCategories
    }
    private var visibleCategories: [TrackerCategory] {
        let weekday = currentDate.weekday
        guard let selectedDate = currentDate.stripped() else { return [] }
        return categories
            .map { category in
                let trackers = category.trackers.filter { isTrackerVisible($0, weekday: weekday, selectedDate: selectedDate) }
                return TrackerCategory(name: category.name, trackers: trackers)
            }
            .filter { !$0.trackers.isEmpty }
    }
    
    private func isTrackerVisible(_ tracker: Tracker, weekday: Weekday, selectedDate: Date) -> Bool {
        if tracker.isRegular {
            return tracker.schedule.contains(weekday)
        } else if let completed = completedTrackers.first(where: { $0.trackerId == tracker.id }) {
            return completed.firstComletionDate == selectedDate
        } else {
            return true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        setupUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        hidePlaceholderView()
        collectionView.reloadData()
    }
    
    private func setupUI() {
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
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        hidePlaceholderView()
        collectionView.reloadData()
    }
    
    @objc private func buttonTapped() {
        let addVC = AddTrackerViewController()
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
    
    private func hidePlaceholderView() {
        if !visibleCategories.isEmpty {
            imageView.isHidden = true
            emptyLabel.isHidden = true
        } else {
            imageView.isHidden = false
            emptyLabel.isHidden = false
        }
    }
    
    private func setupCollectionView() {
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
    
    private  func layoutCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 16 - 16 - 9) / 2, height: 148)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 18)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    private  func setupTitleLabel() {
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
    
    private  func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.locale = Locale(identifier: "ru_RU")
        let dateBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = dateBarButtonItem
    }
    
    private func setupSearchbar() {
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupImageView() {
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
    
    private  func setupEmptyLabel() {
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //логика фильтрации
    }
}

extension TrackerListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerListCell else {
            assertionFailure("no cell at TrackerListCell")
            return UICollectionViewCell()
        }
        cell.delegate = self
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        if datePicker.date > Date(){
            cell.addButton.isUserInteractionEnabled = false
        } else {
            cell.addButton.isUserInteractionEnabled = true
        }
        
        var isCompletedToday = false
        
        for completedTracker in completedTrackers {
            if completedTracker.trackerId == tracker.id,
               completedTracker.date.contains(where: { $0.stripped() == datePicker.date.stripped() }) {
                isCompletedToday = true
                break
            }
        }
        cell.addButton.setImage(UIImage(systemName: isCompletedToday ? "checkmark": "plus"), for: .normal)
        cell.addButton.backgroundColor = tracker.color.withAlphaComponent(isCompletedToday ? 0.3 : 1)
        
        cell.titleLabel.text = "\(tracker.name)"
        cell.backgroundColorView.backgroundColor = tracker.color
        cell.emojiLabel.text = tracker.emoji
        var count = 0
        for trackers in completedTrackers{
            if tracker.id == trackers.trackerId{
                count = trackers.date.count
            }
        }
        cell.daysCount.text = "\(count) дней"
        return cell
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
            
            let categoryName = visibleCategories[indexPath.section].name
            header.titleLabel.text = categoryName
            return header
        }
        
        return UICollectionReusableView()
    }
}
extension TrackerListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        guard let indexPath = indexPaths.first, let cell = collectionView.cellForItem(at: indexPath) as? TrackerListCell else { return nil }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Закрепить") { [weak self] _ in
                    
                },
                UIAction(title: "Редактировать") { [weak self] _ in
//                    guard let self = self else { return }
//                    self.didTapBackground(cell)
                },
                UIAction(title: "Удалить") { [weak self] _ in
//                    guard let self = self else { return }
//                    try? self.trackerStore.deleteTracker(tracker)
                },
            ])
        })
    }
}

extension TrackerListViewController: TrackerListDelegate {
//    func didTapBackground(_ cell: TrackerListCell) {
//        guard let indexPath = collectionView.indexPath(for: cell) else { return }
//        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
//        let vc = TrackerEditViewController(tracker: tracker, countLabeltext: cell.daysCount.text ?? "0 дней")
//        let nav = UINavigationController(rootViewController: vc)
//        present(nav, animated: true)
//        
//    }
    
    func didTapButton(_ cell: TrackerListCell) {
        print("tapTap")
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        print(tracker.id)
        guard let selectedDate = datePicker.date.stripped() else { return }
        
        if let record = trackerRecordStore.trackerRecords.first(where: { $0.trackerId == tracker.id }) {
            var dates = record.date
            if let idx = dates.firstIndex(of: selectedDate) {
                dates.remove(at: idx)
                if dates.isEmpty {
                    try? trackerRecordStore.deleteTrackerRecord(record)
                } else {
                    let newFirst = dates.min()
                    guard let recordCoreData = trackerRecordStore.findRecord(by: record.trackerId) else {return}
                    trackerRecordStore.updateExistingTrackerRecord(recordCoreData, with: TrackerRecord(trackerId: tracker.id, date: dates, firstComletionDate: newFirst))
                }
            } else {
                if !dates.contains(selectedDate) {
                    dates.append(selectedDate)
                }
                let newFirst: Date
                if let firstCompletion = record.firstComletionDate {
                    newFirst = min(firstCompletion, selectedDate)
                } else {
                    newFirst = selectedDate
                }
                guard let recordCoreData = trackerRecordStore.findRecord(by: record.trackerId) else { return }
                trackerRecordStore.updateExistingTrackerRecord(recordCoreData, with: TrackerRecord(trackerId: tracker.id, date: dates, firstComletionDate: newFirst))
            }
        }
        else {
            try? trackerRecordStore.addOrUpdateTrackerRecord(trackerId: tracker.id, newDate: selectedDate, firstCompletionDate: selectedDate)
        }
        print("completedTrackers after update:", completedTrackers)
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackerListViewController: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        collectionView.reloadData()
        hidePlaceholderView()
    }
}
extension TrackerListViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
        collectionView.reloadData()
        hidePlaceholderView()
    }
}
