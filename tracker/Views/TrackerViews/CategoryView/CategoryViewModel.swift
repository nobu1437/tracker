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
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categoriesBinding?(store.trackerCategories)
    }
}
