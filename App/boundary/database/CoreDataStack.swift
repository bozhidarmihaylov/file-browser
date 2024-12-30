//
//  CoreDataStack.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import Foundation
import CoreData

public final class CoreDataStack {
    public static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(
            name: "Model",
            managedObjectModel: managedObjectModel!
        )
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    let managedObjectModel: NSManagedObjectModel? = {
        let bundle = Bundle(for: FileModel.self)
        
        guard let url = bundle.url(forResource: "Model", withExtension: "momd") else {
            return nil
        }
        
        let model = NSManagedObjectModel(
          contentsOf: url
        )

        return model
    }()
}
