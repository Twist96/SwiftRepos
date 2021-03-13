//
//  RepoLocalStore.swift
//  SwiftRepos
//
//  Created by Tochi on 11/03/2021.
//

import Foundation
import CoreData

class RepoLocalStore {
    
    let dataController: DataController
    let managedContext: NSManagedObjectContext
    
    init(dataController: DataController, managedContext: NSManagedObjectContext) {
        self.dataController = dataController
        self.managedContext = managedContext
    }
    
    func fetchAllData(result: @escaping (Result<[MRepository], Error>) -> Void){
        let fetchRequest = NSFetchRequest<Repository>()
        let entity = NSEntityDescription.entity(forEntityName: "Repository", in: managedContext)!
        fetchRequest.entity = entity
        let resultValue: Result<[MRepository], Error>
        
        defer {
            result(resultValue)
        }
        do{
            let mRepos = try managedContext.fetch(fetchRequest).map(MRepository.init)
            resultValue = .success(mRepos)
        }catch{
            resultValue = .failure(error)
        }
    }
}
