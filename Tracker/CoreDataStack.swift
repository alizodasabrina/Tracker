//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Sabrina Mavlyanova on 29/10/26.
//

import CoreData

final class CoreDataStack {

    // MARK: - Public Properties

    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // MARK: - Init

    private init() {}

    // MARK: - Public Methods

    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }
}
