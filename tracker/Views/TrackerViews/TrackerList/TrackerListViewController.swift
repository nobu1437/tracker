import UIKit

final class TrackerListViewController: UIViewController{
    private lazy var collectionView = UICollectionView()
    private var currentDate = Date()
    private var addTracker = UIButton()
    private var datePicker = UIDatePicker()
    private var titleLabel = UILabel()
    private var searchBar = UISearchBar()
    private var imageView = UIImageView()
    private var emptyLabel = UILabel()
    private var completedTrackers: [TrackerRecord] = []
    private var categories: [TrackerCategory] = []
    private var firstCategory: TrackerCategory = .init(name: "first", trackers: [])
    private var visibleCategories: [TrackerCategory] {
        let weekday = currentDate.weekday
        let selectedDate = currentDate.stripped()
        return categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                if tracker.isRegular {
                    return tracker.schedule.contains(weekday)
                } else {
                    if let completed = completedTrackers.first(where: { $0.trackerId == tracker.id }) {
                        return completed.firstComletionDate == selectedDate
                    } else {
                        return true
                    }
                }
            }
            return TrackerCategory(name: category.name, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories.append(firstCategory)
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
        addVC.delegate = self
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
        
        cell.addButton.backgroundColor = tracker.color
        cell.addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        
        if datePicker.date > Date(){
            cell.addButton.isUserInteractionEnabled = false
        } else {
            cell.addButton.isUserInteractionEnabled = true
        }
        
        for completedTracker in completedTrackers {
            if completedTracker.trackerId == tracker.id {
                for date in completedTracker.date {
                    if date.stripped() == datePicker.date.stripped() {
                            cell.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                            cell.addButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
                            break
                    }
                }
            }
        }
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
        
        let indexPath = indexPaths[0]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Закрепить") { [weak self] _ in
                    //                    self?.categories[indexPath.section].trackers[indexPath.item].isPinned.toggle()
                },
                UIAction(title: "Редактировать") { [weak self] _ in
                    
                },
                UIAction(title: "Удалить") { [weak self] _ in
                    //                    self?.categories[indexPath.section].trackers.remove(at: indexPath.item)
                },
            ])
        })
    }
}
extension TrackerListViewController: TrackerListDelegate {
    func didTapButton(_ cell: TrackerListCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        guard let selectedDate = datePicker.date.stripped() else { return }

        if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id }) {
            let oldRecord = completedTrackers[index]
            var updatedDates = oldRecord.date

            if let dateIndex = updatedDates.firstIndex(of: selectedDate) {
                updatedDates.remove(at: dateIndex)

                if updatedDates.isEmpty {
                    completedTrackers.remove(at: index)
                } else {
                    let newFirstCompletionDate = updatedDates.min()
                    let updatedRecord = TrackerRecord(trackerId: tracker.id, date: updatedDates, firstComletionDate: newFirstCompletionDate)
                    completedTrackers[index] = updatedRecord
                }

                cell.addButton.setImage(UIImage(systemName: "plus"), for: .normal)
                cell.addButton.backgroundColor = tracker.color
                cell.daysCount.text = "\(updatedDates.count) дней"

            } else {
                updatedDates.append(selectedDate)
                let newFirstCompletionDate: Date
                if let oldFirst = oldRecord.firstComletionDate {
                                newFirstCompletionDate = min(oldFirst, selectedDate)
                } else {
                    newFirstCompletionDate = selectedDate
                }
                let updatedRecord = TrackerRecord(trackerId: tracker.id, date: updatedDates, firstComletionDate: newFirstCompletionDate)
                completedTrackers[index] = updatedRecord
                
                cell.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                cell.addButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
                cell.daysCount.text = "\(updatedDates.count) дней"
            }
        } else {
            let newRecord = TrackerRecord(trackerId: tracker.id, date: [selectedDate], firstComletionDate: selectedDate)
            completedTrackers.append(newRecord)

            cell.addButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            cell.addButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
            cell.daysCount.text = "1 дней"
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackerListViewController: AddTrackerDelegate {
    func didAddTracker(_ tracker: Tracker) {
        guard !categories.isEmpty else { return }
                let category = categories[0]
                let newCategory = TrackerCategory(
                    name: category.name,
                    trackers: category.trackers + [tracker])
        categories[0] = newCategory
        collectionView.reloadData()
        hidePlaceholderView()
    }
}
