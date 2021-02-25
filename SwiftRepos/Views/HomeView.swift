//
//  HomeView.swift
//  SwiftRepos
//
//  Created by Tochi on 24/02/2021.
//

import SwiftUI
import CoreData
import Apollo

let gitToken = "7b5434eed97e1f956f0d815a0e67e7573c52065b"

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var viewModels = HomeViewModel()
    @FetchRequest(entity: Repository.entity(), sortDescriptors: []) var repositories: FetchedResults<Repository>
    
    var body: some View {
        NavigationView {
            if let repositories = repositories {
                ScrollView {
                    LazyVStack {
                        ForEach(repositories) { item in
                            RepositoryItem(repository: item)
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Repositories")
            }else{
                Text("Loading. . .")
            }
        }
        .onAppear{
            viewModels.addRepos(dataController: dataController, manageContext: managedObjectContext)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

class HomeViewModel: ObservableObject{
    var lastItemCusor: String? = nil
    
    
    func addRepos(dataController: DataController, manageContext: NSManagedObjectContext){
        ApolloNetwork.instance.apollo
            .fetch(query: SearchRepositoryQuery(
                    query: "language:Swift sort:stars-desc",
                    type: SearchType.repository,
                    first: 40)){ result in
                switch result{
                case .success(let result):
                    if let errors = result.errors{
                        print(errors.first.debugDescription)
                    }
                    if let repos = result.data?.search.edges{
                        //let newRepos = repos.map{Repositoryy($0!)}
                        //self.repositories?.append(contentsOf: newRepos)
                        self.saveAllItems(repos, dataController: dataController, manageContext: manageContext)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    func deleteAllRepos(dataController: DataController){
        dataController.deleteAll()
    }
    
    func saveAllItems(_ graphQLRepo: [SearchRepositoryQuery.Data.Search.Edge?],
                      dataController: DataController,
                      manageContext: NSManagedObjectContext){
        _ = graphQLRepo.map{ toRepo($0!, manageContext: manageContext)}
        dataController.save()
        
    }
    
    func toRepo(_ graphQLRepo: SearchRepositoryQuery.Data.Search.Edge,
                manageContext: NSManagedObjectContext) -> Repository{
        let repository = Repository(context: manageContext)
        repository.id = graphQLRepo.node!.asRepository!.id
        repository.name = graphQLRepo.node!.asRepository!.name
        repository.owner = graphQLRepo.node!.asRepository!.owner.login
        repository.stargazerCount = Int32(graphQLRepo.node!.asRepository!.stargazerCount)
        repository.forkCount = Int32(graphQLRepo.node!.asRepository!.forkCount)
        return repository
    }
}
