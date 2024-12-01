//
//  TransferDaoImpl.swift
//  FileBrowser
//
//  Created by Bozhidar Mihaylov
//

import CoreData

struct TransferDaoImpl: TransferDao {
    private var container: NSPersistentContainer {
        CoreDataStack.shared.persistentContainer
    }
    
    private func predicate(taskId: Int) -> NSPredicate {
        NSPredicate(format: "taskIdentifier == %d", taskId)
    }
    
    private func predicate(
        path: String,
        bucketName: String
    ) -> NSPredicate {
        NSPredicate(format: "path == %@ && bucketName == %@", path, bucketName)
    }
    
    private func predicate(
        taskIdsNotIn taskIds: [Int]
    ) -> NSPredicate {
        NSPredicate(format: "NOT (taskIdentifier IN %@)", taskIds)
    }
    
    private func fetchModels(
        predicate: NSPredicate?,
        in context: NSManagedObjectContext
    ) throws -> [TransferModel] {
        let fetchRequest = {
            let fr = NSFetchRequest<TransferModel>(
                entityName: "Transfer"
            )
            fr.predicate = predicate
            return fr
        }()
        
        return try context.fetch(fetchRequest)
    }
    
    private func get(predicate: NSPredicate?) async throws -> [Transfer] {
        try await container.performBackgroundTask { context in
            try fetchModels(
                predicate: predicate,
                in: context
            ).map { $0.toTransfer() }
        }
    }
    
    func getAll() async throws -> [Transfer] {
        try await get(
            predicate: nil
        )
    }
    
    func get(taskId: Int) async throws -> Transfer? {
        try await get(
            predicate: predicate(taskId: taskId)
        ).first
    }
    
    func get(
        path: String,
        bucketName: String
    ) async throws -> Transfer? {
        try await get(
            predicate: predicate(
                path: path,
                bucketName: bucketName
            )
        ).first
    }
    
    func insertOrUpdate(transfer: Transfer) async throws -> Transfer {
        let predicate = predicate(
            path: transfer.relativeFilePath,
            bucketName: transfer.bucketName
        )
        
        try await container.performBackgroundTask { context in
            let transferModel = try fetchModels(
                predicate: predicate,
                in: context
            ).first ?? TransferModel(context: context)
            
            transferModel.map(transfer: transfer)
            
            try context.save()
        }
        
        return transfer
    }    
    
    func delete(predicate: NSPredicate) async throws -> Transfer? {
        var transfer: Transfer? = nil
        
        try await container.performBackgroundTask { context in
            let transferModel = try fetchModels(
                predicate: predicate,
                in: context
            ).first
            
            guard let transferModel else {
                return
            }
            
            transfer = transferModel.toTransfer()
            
            context.delete(transferModel)
            
            try context.save()
        }
        
        return transfer
    }
    
    func delete(taskId: Int) async throws -> Transfer? {
        try await delete(predicate: predicate(taskId: taskId))
    }
    
    func delete(
        path: String,
        bucketName: String
    ) async throws -> Transfer? {
        try await delete(
            predicate: predicate(
                path: path,
                bucketName: bucketName
            )
        )
    }
    
    func deleteTransfersWithTaskIdsNotIn(
        taskIds: [Int]
    ) async throws -> [Transfer] {
        let predicate = predicate(
            taskIdsNotIn: taskIds
        )
        
        var transfers: [Transfer] = []
        
        try await container.performBackgroundTask { context in
            let transferModels = try fetchModels(
                predicate: predicate,
                in: context
            )
            transfers = transferModels.map { $0.toTransfer() }
            
            transferModels.forEach { transferModel in
                context.delete(transferModel)
            }
            
            try context.save()
        }
        
        return transfers
    }
}
