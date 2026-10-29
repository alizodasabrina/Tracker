//
//  TrackerStore.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 29/10/26.
//

import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerStore)
}

@MainActor
final class TrackerStore: NSObject {

    // MARK: - Public Properties

    weak var delegate: TrackerStoreDelegate?

    // MARK: - Private Properties

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
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
            assertionFailure("Не удалось загрузить трекеры: \(error)")
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

    func addNewTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.setValue(tracker.schedule, forKey: "schedule")
        trackerCoreData.category = category
        try context.save()
    }

    func trackerCoreData(withId id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func tracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        guard let id = trackerCoreData.id,
              let title = trackerCoreData.title,
              let emoji = trackerCoreData.emoji,
              let colorHex = trackerCoreData.colorHex,
              let schedule = trackerCoreData.value(forKey: "schedule") as? [WeekDay]
        else { return nil }

        return Tracker(
            id: id,
            title: title,
            color: UIColorMarshalling.color(from: colorHex),
            emoji: emoji,
            schedule: schedule
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
