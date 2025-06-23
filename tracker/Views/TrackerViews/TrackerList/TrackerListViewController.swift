import UIKit

final class TrackerListViewController: UIViewController{
    private let analytics = AnalyticsService()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    
    private lazy var collectionView = UICollectionView()
    private var currentDate = Date()
    private var addTracker = UIButton()
    private var datePicker = UIDatePicker()
    private var titleLabel = UILabel()
    private var searchBar = UISearchBar()
    private var placeholderImageView = UIImageView()
    private var placeholderLabel = UILabel()
    private var currentSearchText: String = ""
    private var trackerFilter: TrackerFilter = .todayTrackers
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("trackerList.filter.title", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var completedTrackers: [TrackerRecord]{
        trackerRecordStore.trackerRecords
    }
    private var categories: [TrackerCategory]{
        trackerCategoryStore.trackerCategories
    }
    
    private var visibleCategories: [TrackerCategory] {
        let weekday = currentDate.weekday
        guard let selectedDate = currentDate.stripped() else { return [] }
        
        func shouldInclude(_ tracker: Tracker) -> Bool {
            let matchesSchedule = isTrackerVisible(tracker, weekday: weekday, selectedDate: selectedDate)
            let matchesSearch = currentSearchText.isEmpty || tracker.name.lowercased().contains(currentSearchText.lowercased())
            let matchesFilter = isTrackerMatchingFilter(tracker, selectedDate: selectedDate)
            return matchesSchedule && matchesSearch && matchesFilter
        }
        var resultCategories: [TrackerCategory] = []
        
        let pinnedTrackers = categories
            .flatMap { $0.trackers }
            .filter { $0.isPinned && shouldInclude($0) }
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(name: NSLocalizedString("trackerList.pinned.title", comment: ""), trackers: pinnedTrackers)
            resultCategories.append(pinnedCategory)
        }
        let otherCategories = categories
            .map { category in
                let trackers = category.trackers.filter { !$0.isPinned && shouldInclude($0) }
                return TrackerCategory(name: category.name, trackers: trackers)
            }
            .filter { !$0.trackers.isEmpty }
        resultCategories.append(contentsOf: otherCategories)
        return resultCategories
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
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        return completedTrackers.contains {
            $0.trackerId == tracker.id && $0.date.contains(date)
        }
    }
    private func isTrackerMatchingFilter(_ tracker: Tracker, selectedDate: Date) -> Bool {
        switch trackerFilter {
        case .alltrackers:
            return true
        case .todayTrackers:
            return true
        case .completedTrackers:
            return isTrackerCompleted(tracker, on: selectedDate)
        case .uncompletedTrackers:
            return !isTrackerCompleted(tracker, on: selectedDate)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.logMainScreenEvent(event: .open)
        hidePlaceholderView()
        collectionView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analytics.logMainScreenEvent(event: .close)
    }
    private func makeAlert(tracker: Tracker) -> UIAlertController{
        let alert = UIAlertController(title: "", message:NSLocalizedString("trackerList.alert.title", comment: ""), preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: NSLocalizedString("categoryview.delete.title", comment: ""), style: .destructive){[weak self] _ in
            guard let self = self else { return }
            try? self.trackerStore.deleteTracker(tracker)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("trackerList.alert.cancel", comment: "") , style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        return alert
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
        view.backgroundColor = .ypWhite
        setupTitleLabel()
        setupDatePicker()
        setupSearchbar()
        setupCollectionView()
        setupImageView()
        setupEmptyLabel()
        setupFilterButton()
    }
    @objc private func filersTapped() {
        let filterVC = TrackerFilterViewController(checkedFilter: trackerFilter)
        filterVC.onFilterSelected = { [weak self] filter in
            self?.trackerFilter = filter
            if self?.trackerFilter == .todayTrackers {
                self?.currentDate = Date()
                self?.datePicker.date = Date()
            }
            self?.collectionView.reloadData()
            self?.hidePlaceholderView()
            print (self?.trackerFilter)
        }
        analytics.logMainScreenEvent(event: .click, item: .filter)
        let nav = UINavigationController(rootViewController: filterVC)
        present(nav, animated: true)
    }
    
    @objc private func dateChanged() {
        if filterButton.alpha == 0{
            UIView.animate(withDuration: 0.2) {
                self.filterButton.alpha = 1.0
            }
        }
        currentDate = datePicker.date
        if !(trackerFilter == .completedTrackers) && !(trackerFilter == .uncompletedTrackers) {
            if currentDate == Date(){
                trackerFilter = .todayTrackers
            } else {
                trackerFilter = .alltrackers
            }
        }
        hidePlaceholderView()
        collectionView.reloadData()
    }
    
    @objc private func buttonTapped() {
        analytics.logMainScreenEvent(event: .click, item: .addTtrack)
        let addVC = AddTrackerViewController()
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
    private func setupFilterButton() {
        filterButton.addTarget(self, action: #selector(filersTapped), for: .touchUpInside)
        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 114)
        ])
    }
    private func hidePlaceholderView() {
        if !visibleCategories.isEmpty {
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
        } else {
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
        }
    }
    
    private func setupCollectionView() {
        collectionView = layoutCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .ypWhite
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
        titleLabel.text = NSLocalizedString("trackerList.title" , comment: "")
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
        searchBar.placeholder = NSLocalizedString("trackerList.search.placeholder", comment: "")
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
        placeholderImageView.image = UIImage(resource: .noTracked)
        view.addSubview(placeholderImageView)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private  func setupEmptyLabel() {
        placeholderLabel.text = NSLocalizedString("trackerList.placeholder.text", comment: "")
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textAlignment = .center
        view.addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
}

extension TrackerListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        collectionView.reloadData()
        if currentSearchText.isEmpty{
            placeholderLabel.text = NSLocalizedString("trackerList.placeholder.text", comment: "")
            placeholderImageView.image = UIImage(resource: .noTracked)
        } else {
            placeholderLabel.text = visibleCategories.isEmpty ?
            NSLocalizedString("trackerList.placeholder.nothing", comment: "") : NSLocalizedString("trackerList.placeholder.text", comment: "")
            placeholderImageView.image = UIImage(resource: visibleCategories.isEmpty ? .think : .noTracked)
        }
        hidePlaceholderView()
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
        cell.addButton.backgroundColor = tracker.color.withAlphaComponent(isCompletedToday ? 0.5 : 1)
        
        cell.titleLabel.text = "\(tracker.name)"
        cell.backgroundColorView.backgroundColor = tracker.color
        cell.emojiLabel.text = tracker.emoji
        cell.pinImage.isHidden = !tracker.isPinned
        var count = 0
        for trackers in completedTrackers{
            if tracker.id == trackers.trackerId{
                count = trackers.date.count
            }
        }
        cell.daysCount.text = String.localizedStringWithFormat(NSLocalizedString("tracker.days.count", comment: ""), count)
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
                UIAction(title:  NSLocalizedString(tracker.isPinned ? "trackerList.pinned.unpin" : "trackerList.pinned.pin" , comment: "")) { [weak self] _ in
                    self?.trackerStore.togglePin(for: tracker)
                    print(tracker)
                },
                UIAction(title: NSLocalizedString( "categoryview.edit.title", comment: "")) { [weak self] _ in
                    guard let self = self else { return }
                    self.analytics.logMainScreenEvent(event: .click, item: .edit)
                    self.didTapBackground(cell)
                },
                UIAction(title: NSLocalizedString( "categoryview.delete.title", comment: ""),attributes: .destructive) { [weak self] _ in
                    guard let self = self else { return }
                    self.analytics.logMainScreenEvent(event: .click, item: .edit)
                    let alert = makeAlert(tracker: tracker)
                    present(alert, animated: true)
                },
            ])
        })
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        if contentHeight <= scrollViewHeight {
            UIView.animate(withDuration: 0.2) {
                self.filterButton.alpha = 1.0
            }
            return
        }
        if offsetY + scrollViewHeight >= contentHeight - 20 {
            UIView.animate(withDuration: 0.2) {
                self.filterButton.alpha = 0.0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.filterButton.alpha = 1.0
            }
        }
    }
}

extension TrackerListViewController: TrackerListDelegate {
    func didTapBackground(_ cell: TrackerListCell) {
        analytics.logMainScreenEvent(event: .click, item: .track)
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let vc = TrackerEditViewController(tracker: tracker, countLabeltext: cell.daysCount.text ?? "0 дней")
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
        
    }
    
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
        collectionView.reloadData()
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
extension TrackerListViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        collectionView.reloadData()
        hidePlaceholderView()
    }
}
