//
//  RepoGraphQLStore.swift
//  SwiftRepos
//
//  Created by Tochi on 11/03/2021.
//

import Foundation
import CoreData

struct MRepository {
    let id: String
    let name: String
    let owner: String
    let stargazerCount: Int
    let forkCount: Int
    
    init(graphQlRepo: SearchRepositoryQuery.Data.Search.Edge) {
        id = graphQlRepo.node!.asRepository!.id
        name = graphQlRepo.node!.asRepository!.name
        owner = graphQlRepo.node!.asRepository!.owner.login
        stargazerCount = graphQlRepo.node!.asRepository!.stargazerCount
        forkCount = graphQlRepo.node!.asRepository!.forkCount
    }
    
    init(repository: Repository) {
        id = repository.id!
        name = repository.name!
        owner = repository.owner!
        stargazerCount = Int(repository.stargazerCount)
        forkCount = Int(repository.forkCount)
    }
}

class RepoGraphQLStore{
    
    func fetchGitRepository(lastRepositoryCusor: String?, result: @escaping (Result<[MRepository], Error>) -> Void){
        ApolloNetwork.instance.apollo
            .fetch(query: SearchRepositoryQuery(
                    query: "language:Swift sort:stars-desc",
                    type: SearchType.repository,
                    first: 40,
                    after: lastRepositoryCusor)){ queryResult in
                var resultValue: Result<[MRepository], Error>!
                defer {
                    result(resultValue)
                }
                
                switch queryResult{
                case .success(let graphQLresult):
                    if let error = graphQLresult.errors?.first{
                        resultValue = .failure(error)
                    }
                    if let repos = graphQLresult.data?.search.edges{
                        let mRepos = repos.map{MRepository(graphQlRepo: $0!)}
                        resultValue = .success(mRepos)
                    }
                case .failure(let error):
                    resultValue = .failure(error)
                }
            }
    }
    
}
