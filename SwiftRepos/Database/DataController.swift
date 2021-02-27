//
//  DataController.swift
//  SwiftRepos
//
//  Created by Tochi on 25/02/2021.
//

import Foundation
import CoreData

class DataController:ObservableObject{
    
    let container: NSPersistentContainer
    private var dbStoreURL: URL? = nil
    private var dbStoreType: String? = nil
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory{
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error{
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            self.dbStoreURL = storeDescription.url
            self.dbStoreType = storeDescription.type
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    
    func save() {
        if container.viewContext.hasChanges{
            try? container.viewContext.save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }
    
    func deleteAll(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Repository.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? container.viewContext.execute(deleteRequest)
    }
    
    func deletePersistantStore(){
        do{
            
            try container.persistentStoreCoordinator.destroyPersistentStore(at: dbStoreURL!, ofType: dbStoreType!)
            container.loadPersistentStores { (storeDescription, error) in
                if let error = error{
                    fatalError("Fatal error loading store: \(error.localizedDescription)")
                }
                self.dbStoreURL = storeDescription.url
                self.dbStoreType = storeDescription.type
            }
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        }catch{
            print(error.localizedDescription)
        }
    }
    
}


