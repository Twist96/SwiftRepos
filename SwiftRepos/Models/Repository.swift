//
//  Repository.swift
//  SwiftRepos
//
//  Created by Tochi on 24/02/2021.
//

import Foundation
import CoreData

extension Repository{
    static var dummyData: Repository {
        let dataController = DataController(inMemory: true)
        let context = dataController.container.viewContext
        let repository = Repository(context: context)
        repository.id = "123abc"
        repository.name = "Tommys Repo"
        repository.owner = "Tommy Udoka"
        repository.stargazerCount = 22012
        repository.forkCount = 3613
        return repository
    }
}
