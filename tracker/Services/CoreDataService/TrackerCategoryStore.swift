import UIKit
import CoreData

final class TrackerCategoryStore: NSObject{
    let context:NSManagedObjectContext
    
    let trackerStore = TrackerStore()
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    weak var delegate: TrackerCategoryStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    override convenience init() {
        let context: NSManagedObjectContext
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            context = delegate.persistentContainer.viewContext
        } else {
            let container = NSPersistentContainer(name: "tracker")
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to load store: \(error)")
                }
            }
            context = container.viewContext
        }
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try? controller.performFetch()
    }
    
    var trackerCategories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let trackerRecords = try? objects.map({ try self.trackerCategory(from: $0) })
        else { return [] }
        return trackerRecords
    }
    
    func addNewTrackerCategory(_ trackerCategory: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExistingTrackerCategory(trackerCategoryCoreData, with: trackerCategory)
        try context.save()
    }
    func deleteCategory(_ category: String) throws {
        guard let trackerCategoryCoreData = findCategoryCoreData(by: category) else { return }
        
        context.delete(trackerCategoryCoreData)
        try context.save()
    }
    func findCategory(by name: String) -> TrackerCategory? {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", name)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            guard let categoryCoreData = results.first else { return nil }
            return try trackerCategory(from: categoryCoreData)
        } catch {
            print("Ошибка поиска категории: \(error)")
            return nil
        }
    }
    func findCategoryCoreData(by name: String) -> TrackerCategoryCoreData? {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", name)
        fetchRequest.fetchLimit = 1
        
        let results = try? context.fetch(fetchRequest)
        guard let categoryCoreData = results?.first else { return nil }
        return categoryCoreData
    }
    
    func addTrackerToCategory(_ tracker: Tracker, categoryName: String) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let existingCategory = results.first {
                let trackerFetchRequest = TrackerCoreData.fetchRequest()
                trackerFetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
                
                let trackerResults = try context.fetch(trackerFetchRequest)
                if let existingTrackerCoreData = trackerResults.first {
                    existingTrackerCoreData.category = existingCategory
                } else {
                    let newTrackerCoreData = TrackerCoreData(context: context)
                    trackerStore.updateExistingTracker(newTrackerCoreData, with: tracker)
                    newTrackerCoreData.category = existingCategory
                }
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = categoryName
                
                let newTrackerCoreData = TrackerCoreData(context: context)
                trackerStore.updateExistingTracker(newTrackerCoreData, with: tracker)
                newTrackerCoreData.category = newCategory
            }
            
            try context.save()
        } catch {
            throw error
        }
    }
    func updateExistingTrackerCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData, with trackerCategory: TrackerCategory) {
        trackerCategoryCoreData.title = trackerCategory.name
    }
    
    func findCategoryName(for tracker: Tracker) -> String? {
        for category in trackerCategories {
            if category.trackers.contains(where: { $0.id == tracker.id }) {
                return category.name
            }
        }
        return nil
    }
    
    func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = trackerCategoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingError
        }
        let trackers = (trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData])?.compactMap { trackerCoreData in
            try? trackerStore.tracker(from: trackerCoreData)
        } ?? []
        return TrackerCategory(name: name, trackers: trackers)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet(),
                movedIndexes: movedIndexes ?? Set()
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
        movedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}

enum TrackerCategoryStoreError: Error {
    case decodingError
    case delegateError(Error)
}

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(
        _ store: TrackerCategoryStore,
        didUpdate update: TrackerCategoryStoreUpdate
    )
}
