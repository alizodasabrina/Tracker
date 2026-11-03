//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 29/10/26.
//

import CoreData
import UIKit

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerRecordStore)
}

@MainActor
final class TrackerRecordStore: NSObject {

    // MARK: - Public Properties

    weak var delegate: TrackerRecordStoreDelegate?

    var records: [TrackerRecord] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap { recordCoreData in
            guard let date = recordCoreData.date, let trackerId = recordCoreData.tracker?.id else { return nil }
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }

    // MARK: - Private Properties

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            assertionFailure("Не удалось загрузить записи: \(error)")
        }
        return controller
    }()

    // MARK: - Init

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    convenience override init() {
        self.init(context: CoreDataStack.shared.persistentContainer.viewContext)
    }

    // MARK: - Public Methods

    func addNewRecord(_ record: TrackerRecord, for tracker: TrackerCoreData) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.date = Calendar.current.startOfDay(for: record.date)
        recordCoreData.tracker = tracker
        try context.save()
    }

    /// Ищем по диапазону [начало дня, начало следующего дня), а не по точному равенству даты —
    /// иначе запись, сохранённая в один момент времени, не найдётся по Date() из другого вызова того же дня.
    func deleteRecord(trackerId: UUID, date: Date) throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND %K >= %@ AND %K < %@",
            trackerId as CVarArg,
            #keyPath(TrackerRecordCoreData.date), startOfDay as CVarArg,
            #keyPath(TrackerRecordCoreData.date), startOfNextDay as CVarArg
        )
        try context.fetch(request).forEach { context.delete($0) }
        try context.save()
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
