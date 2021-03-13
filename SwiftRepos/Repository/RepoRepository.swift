//
//  RepoRepository.swift
//  SwiftRepos
//
//  Created by Tochi on 11/03/2021.
//

import Foundation
import Combine

class RepoRepository{
    var repos: CurrentValueSubject<[MRepository],Error> = CurrentValueSubject([])
    
    let repoLocalStore: RepoLocalStore
    let repoGraphQLStore: RepoGraphQLStore
    
    init(repoLocalStore: RepoLocalStore, repoGraphQLStore: RepoGraphQLStore) {
        self.repoLocalStore = repoLocalStore
        self.repoGraphQLStore = repoGraphQLStore
        
        repoLocalStore.fetchAllData { CDResult in
            switch CDResult{
            case .success(let result):
                self.repos.value = result
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        repoGraphQLStore.fetchGitRepository(lastRepositoryCusor: nil) { (graphQLResult) in
            switch graphQLResult{
            case .success(let result):
                self.repos.value = result
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchRepo(){
        
    }
}
