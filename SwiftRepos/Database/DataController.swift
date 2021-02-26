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
    static let instance = DataController()
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory{
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error{
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    static var preview: DataController = {
       let dataController = DataController()
        
//        do{
//            try dataController.createSampleData()
//        }catch{
//            fatalError("Fatel error creating preview: \(error.localizedDescription)")
//        }
        
        return dataController
    }()
    
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
    
    func dummyRepo(){
        let repository = Repository(context: container.viewContext)
        repository.id = "123abc"
        repository.name = "Tommys Repo"
        repository.owner = "Tommy Udoka"
        repository.stargazerCount = 22012
        repository.forkCount = 3613
    }
    
}


