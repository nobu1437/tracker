import UIKit
import CoreData

final class TrackerStore: NSObject{
    let context:NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    weak var delegate: TrackerStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    let colorArray: [UIColor] = [.selection1,.selection2,.selection3,.selection4,.selection5,.selection6,.selection7,.selection8,.selection9,.selection10,.selection11,.selection12,.selection13,.selection14,.selection15,.selection16,.selection17,.selection18]
    
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
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
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
    
    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let trackers = try? objects.map({ try self.tracker(from: $0) })
        else { return [] }
        return trackers
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        guard let trackerCoreData = findTracker(by: tracker.id) else { return }
        
        context.delete(trackerCoreData)
        try context.save()
    }
    func findColorId(by trackerID: UUID) -> Int{
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do{
            let results = try context.fetch(fetchRequest)
            guard let index = results.first?.colorIndex else { return 0 }
            return Int(index)
        } catch{
            print("Ошибка поиска записи: \(error)")
            return 0
        }
    }
    func togglePin(for tracker: Tracker) {
        guard let trackerCoreData = findTracker(by: tracker.id) else { return }
        trackerCoreData.isPinned.toggle()
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении isPinned: \(error)")
        }
    }
    func findTracker(by trackerId: UUID) -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Ошибка поиска записи: \(error)")
            return nil
        }
    }
    
    func addNewTracker(_ tracker: Tracker, to categoryName: String) throws {
        let categoryFetchRequest = TrackerCategoryCoreData.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        let categoryResults = try context.fetch(categoryFetchRequest)

        let category: TrackerCategoryCoreData
        if let existingCategory = categoryResults.first {
            category = existingCategory
        } else {
            category = TrackerCategoryCoreData(context: context)
            category.title = categoryName
        }

        let trackerCoreData: TrackerCoreData
        if let existingTracker = findTracker(by: tracker.id) {
            trackerCoreData = existingTracker
        } else {
            trackerCoreData = TrackerCoreData(context: context) 
        }

        updateExistingTracker(trackerCoreData, with: tracker)
        trackerCoreData.category = category

        try context.save()
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.name = tracker.name
        trackerCoreData.id = tracker.id
        trackerCoreData.schedule = tracker.schedule as NSObject
        trackerCoreData.isRegular = tracker.isRegular
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.isPinned = tracker.isPinned
        
        if let colorIndex = colorArray.firstIndex(of: tracker.color) {
            trackerCoreData.colorIndex = Int16(colorIndex)
        } else {
            trackerCoreData.colorIndex = 0
        }
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let name = trackerCoreData.name else {
            throw TrackerStoreError.decodingError
        }
        
        let colorIndex = Int(trackerCoreData.colorIndex)
        
        let color = colorArray[colorIndex]
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingError
        }
        guard let schedule = trackerCoreData.schedule else {
            throw TrackerStoreError.decodingError
        }
        guard let castedSchedule = schedule as? [Weekday] else {
            throw TrackerStoreError.decodingError
        }
        let isRegular = trackerCoreData.isRegular
        guard let id = trackerCoreData.id else {
            throw TrackerStoreError.decodingError
        }
         let isPinned = trackerCoreData.isPinned
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: castedSchedule, isRegular: isRegular, isPinned: isPinned)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerStoreUpdate(
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

enum TrackerStoreError: Error {
    case decodingError
}

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}
