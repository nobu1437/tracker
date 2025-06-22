import UIKit

final class CategoryViewModel {
    private let store: TrackerCategoryStore

    var categoriesBinding: Binding<[TrackerCategory]>?
    
    private(set) var selectedCategoryName: String?
    
    var categories: [TrackerCategory] {
        store.trackerCategories
    }

    init(store: TrackerCategoryStore = TrackerCategoryStore()) {
        self.store = store
        store.delegate = self
        categoriesBinding?(store.trackerCategories)
    }

    func loadCategories() {
        categoriesBinding?(store.trackerCategories)
    }

    func addCategory(named name: String) {
        let newCategory = TrackerCategory(name: name, trackers: [])
        try? store.addNewTrackerCategory(newCategory)
    }

    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategoryName = categories[index].name
        categoriesBinding?(categories)
    }
    func deleteCategory(named name: String) {
       try? store.deleteCategory(name)
    }
    func updateCategory(named oldName: String, new name: String) {
       guard let categoryCorData =  store.findCategoryCoreData(by: oldName),
             let category =  store.findCategory(by: name) else { return }
        store.updateExistingTrackerCategory(categoryCorData, with: category)
    }
    func makeAlert(category: String) -> UIAlertController {
        let alert = UIAlertController(title: "", message: "Эта категория точно не нужна?", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Отменить", style: .cancel)
        let action2 = UIAlertAction(title: "Удалить", style: .destructive){[weak self] _ in
            self?.deleteCategory(named: category)
        }
            alert.addAction(action2)
            alert.addAction(action)
        return alert
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categoriesBinding?(store.trackerCategories)
    }
}
