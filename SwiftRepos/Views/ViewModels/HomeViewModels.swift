//
//  HomeViewModels.swift
//  SwiftRepos
//
//  Created by Tochi on 25/02/2021.
//

import Foundation
import Combine
import CoreData
import Apollo

class HomeViewModel: ObservableObject{
    @Published var appState: ScreenState = .loading
    @Published var databaseHasData = false
    @Published var showToast = false
    @Published var toastMessage = ""
    
    ///LastRepositoryCusor tells the server how to offset data. If nil server will return first set of data
    var lastRepositoryCusor: String? = nil
    
    /// refreshId is used track when new repositories new to be fetched
    var refreshId: String? = nil
    
    /// hasNext indicates if there's still more Repositories to fetch from saver
    var hasNext: Bool = true
    
    
    
    /// Fetch Repositories from Server
    /// - Parameters:
    ///   - dataController: DataController instance
    ///   - manageContext: CoreData context from app environment
    func fetchGitRepository(dataController: DataController, manageContext: NSManagedObjectContext){
        if !hasNext{
            ///Stop fetch request if we already fetch last set of repositories
            return
        }
        
        ApolloNetwork.instance.apollo
            .fetch(query: SearchRepositoryQuery(
                    query: "language:Swift sort:stars-desc",
                    type: SearchType.repository,
                    first: 40,
                    after: lastRepositoryCusor)){ [self] result in
                switch result{
                case .success(let result):
                    if let errors = result.errors{
                        handleError(errors.first!)
                        
                    }
                    if let repos = result.data?.search.edges{
                        self.hasNext = result.data!.search.pageInfo.hasNextPage
                        self.lastRepositoryCusor = result.data!.search.pageInfo.endCursor
                        self.saveAllRepositories(repos, dataController: dataController, manageContext: manageContext)
                        appState = .success
                    }
                case .failure(let error):
                    handleError(error)
                }
            }
    }
    
    
    /// Handle Error
    /// If data is already showing on screen, a small toast should be displayed
    /// else app should show error page
    /// - Parameter error: Error
    func handleError(_ error: Error){
        if databaseHasData{
            toastMessage = "Failed to fetch new Data: " + error.localizedDescription
            showToast = true
        }else{
            appState = .error(error.localizedDescription)
        }
    }
    
    
    /// Save All Repositories
    /// existing repositories will be updated
    /// - Parameters:
    ///   - graphQLRepo: Repository list
    ///   - dataController: DataController
    ///   - manageContext: Database Context
    func saveAllRepositories(_ graphQLRepo: [SearchRepositoryQuery.Data.Search.Edge?],
                      dataController: DataController,
                      manageContext: NSManagedObjectContext){
        if let repo = graphQLRepo[19]{
            refreshId = repo.node!.asRepository!.id
        }
        convertToRepositoryAndSave(graphQLRepo, dataController: dataController, manageContext: manageContext)
    }
    
    
    /// Convert data from GraphQL type to CoreData type and save
    /// - Parameters:
    ///   - graphQLRepo: Repository list
    ///   - dataController: DataController
    ///   - manageContext: Database Context
    func convertToRepositoryAndSave(_ graphQLRepo: [SearchRepositoryQuery.Data.Search.Edge?],
                        dataController: DataController,
                        manageContext: NSManagedObjectContext){
        for repo in graphQLRepo{
            let repository = Repository(context: manageContext)
            repository.id = repo!.node!.asRepository!.id
            repository.name = repo!.node!.asRepository!.name
            repository.owner = repo!.node!.asRepository!.owner.login
            repository.stargazerCount = Int32(repo!.node!.asRepository!.stargazerCount)
            repository.forkCount = Int32(repo!.node!.asRepository!.forkCount)
            dataController.save()
        }
    }
    
}
