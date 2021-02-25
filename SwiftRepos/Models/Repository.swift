//
//  Repository.swift
//  SwiftRepos
//
//  Created by Tochi on 24/02/2021.
//

import Foundation
import CoreData

struct Repositoryy: Identifiable{
    let id: String
    let name: String
    let owner: String
    let stargazerCount: Int
    let forkCount: Int

    init(_ repo: SearchRepositoryQuery.Data.Search.Edge) {
        id = repo.node!.asRepository!.id
        name = repo.node!.asRepository!.name
        owner = repo.node!.asRepository!.owner.login
        stargazerCount = repo.node!.asRepository!.stargazerCount
        forkCount = repo.node!.asRepository!.forkCount
    }

    internal init(id: String, name: String, owner: String, stargazerCount: Int, forkCount: Int) {
        self.id = id
        self.name = name
        self.owner = owner
        self.stargazerCount = stargazerCount
        self.forkCount = forkCount
    }
}

extension Repositoryy{
    static let dummyData = Repositoryy(id: "123abc", name: "Tommys Repo", owner: "Tommy Udoka", stargazerCount: 22012, forkCount: 3613)
}

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
