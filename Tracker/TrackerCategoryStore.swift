//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 29/10/26.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerCategoryStore)
}

@MainActor
final class TrackerCategoryStore: NSObject {

    // MARK: - Public Properties

    weak var delegate: TrackerCategoryStoreDelegate?

    var categories: [TrackerCategory] {
        (fetchedResultsController.fetchedObjects ?? []).map { categoryCoreData in
            let trackers = (categoryCoreData.trackers as? Set<TrackerCoreData> ?? [])
                .compactMap(TrackerStore.tracker(from:))
                .sorted { $0.title < $1.title }
            return TrackerCategory(title: categoryCoreData.title ?? "", trackers: trackers)
        }
    }

    // MARK: - Private Properties

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
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
            assertionFailure("Не удалось загрузить категории: \(error)")
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

    @discardableResult
    func addNewCategory(_ category: TrackerCategory) throws -> TrackerCategoryCoreData {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        try context.save()
        return categoryCoreData
    }

    func categoryCoreData(withTitle title: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
