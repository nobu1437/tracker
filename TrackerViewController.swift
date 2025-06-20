private func setupScrollView() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(scrollView)
    scrollView.addSubview(contentView)

    NSLayoutConstraint.activate([
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
    ])
}

private func setupCollectionView() {
    collectionView = layoutCollectionView()
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .clear
    contentView.addSubview(collectionView)
    collectionView.register(TrackerCollectionEmojiCell.self, forCellWithReuseIdentifier: "emojiCell")
    collectionView.register(TrackerCollectioinColorCell.self, forCellWithReuseIdentifier: "colorCell")
    collectionView.register(TrackerListSupView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    NSLayoutConstraint.activate([
        collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        collectionView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -16),
        collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200) // Минимальная высота для отображения контента
    ])
}

private func layoutCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 5
    layout.minimumLineSpacing = 0 // Добавляем минимальный отступ между строками
    layout.sectionInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
    
    // Рассчитываем ширину ячейки с учетом отступов
    let availableWidth = UIScreen.main.bounds.width - 32 // 16 points отступ с каждой стороны
    let spacingBetweenItems: CGFloat = 5 // отступ между ячейками
    let numberOfItemsInRow: CGFloat = 6 // количество ячеек в ряду
    let totalSpacing = spacingBetweenItems * (numberOfItemsInRow - 1)
    let itemWidth = (availableWidth - totalSpacing) / numberOfItemsInRow
    
    layout.itemSize = CGSize(width: itemWidth, height: 52)
    layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 18)
    return UICollectionView(frame: .zero, collectionViewLayout: layout)
} 