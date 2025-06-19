import UIKit
import CoreData

class TrackerRecordStore: NSObject{
    let context:NSManagedObjectContext
    
    convenience override init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    weak var delegate: TrackerRecordStoreDelegate?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordStoreUpdate.Move>?
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.trackerId, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    var trackerRecords: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackerRecords = try? objects.map({ try self.trackerRecord(from: $0) })
        else { return [] }
        return trackerRecords
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, with: trackerRecord)
        try context.save()
    }
    
    func addOrUpdateTrackerRecord(trackerId: UUID, newDate: Date, firstCompletionDate: Date?) throws {
        if let existingRecord = findRecord(by: trackerId) {
            updateDatesForTrackerRecord(existingRecord, with: newDate)
            if existingRecord.firstComletionDate == nil, let firstDate = firstCompletionDate {
                existingRecord.firstComletionDate = firstDate
            }
        } else {
            let newRecord = TrackerRecordCoreData(context: context)
            newRecord.trackerId = trackerId
            newRecord.date = [newDate.stripped()!] as NSObject
            newRecord.firstComletionDate = firstCompletionDate
        }
        try context.save()
    }
    private func updateDatesForTrackerRecord(_ record: TrackerRecordCoreData, with newDate: Date) {
        guard let strippedDate = newDate.stripped() else { return }

        var existingDates = (record.date as? [Date]) ?? []
        
        if !existingDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: strippedDate) }) {
            existingDates.append(strippedDate)
            record.date = existingDates as NSArray
        }
    }
    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData, with trackerRecord: TrackerRecord) {
        trackerRecordCoreData.firstComletionDate = trackerRecord.firstComletionDate
        trackerRecordCoreData.date = trackerRecord.date as NSObject 
        trackerRecordCoreData.trackerId = trackerRecord.trackerId
    }
    func findRecord(by trackerId: UUID) -> TrackerRecordCoreData? {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Ошибка поиска записи: \(error)")
            return nil
        }
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        guard let recordCoreData = findRecord(by: trackerRecord.trackerId) else {
            return
        }
        
        context.delete(recordCoreData)
        try context.save()
    }
    
    func trackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.trackerId else {
            throw TrackerRecordStoreError.decodingError
        }
        guard let date = trackerRecordCoreData.date else {
           throw TrackerRecordStoreError.decodingError
       }
        guard let firstDate = trackerRecordCoreData.firstComletionDate else {
           throw TrackerRecordStoreError.decodingError
       }
        return TrackerRecord(trackerId: id, date: date as! [Date], firstComletionDate: firstDate)
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerRecordStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store(
            self,
            didUpdate: TrackerRecordStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!,
                updatedIndexes: updatedIndexes!,
                movedIndexes: movedIndexes!
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

enum TrackerRecordStoreError: Error {
    case decodingError
}

struct TrackerRecordStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func store(
        _ store: TrackerRecordStore,
        didUpdate update: TrackerRecordStoreUpdate
    )
}
