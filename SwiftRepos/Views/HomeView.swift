//
//  HomeView.swift
//  SwiftRepos
//
//  Created by Tochi on 24/02/2021.
//

import SwiftUI
import CoreData
import Apollo

let gitToken = "a56e62f01f6d2d28c9fa2c00f15e07ff6fa879d9"

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var viewModel = HomeViewModel()
    @FetchRequest(entity: Repository.entity(),
                  sortDescriptors: [])
        var repositories: FetchedResults<Repository>
    
    var body: some View {
        NavigationView {
            if let repositories = repositories {
                ScrollView {
                    LazyVStack {
                        ForEach(repositories) { item in
                            RepositoryItem(repository: item)
                                .onAppear{
                                    if item.id == viewModel.refreshId{
                                        viewModel.addRepos(dataController: dataController,
                                                           manageContext: managedObjectContext)
                                    }
                                }
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
            viewModel.addRepos(dataController: dataController, manageContext: managedObjectContext)
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var dataController = DataController.preview
//    static var previews: some View {
//        HomeView()
//            .environment(\.managedObjectContext, dataController.container.viewContext)
//            .environmentObject(dataController)
//    }
//}

class HomeViewModel: ObservableObject{
    var lastRepoCusor: String? = nil
    var refreshId: String? = nil
    var hasNext: Bool = true
    
    
    func addRepos(dataController: DataController, manageContext: NSManagedObjectContext){
        if !hasNext{
            return
        }
        
        ApolloNetwork.instance.apollo
            .fetch(query: SearchRepositoryQuery(
                    query: "language:Swift sort:stars-desc",
                    type: SearchType.repository,
                    first: 40,
                    after: lastRepoCusor)){ result in
                switch result{
                case .success(let result):
                    if let errors = result.errors{
                        print(errors.first.debugDescription)
                    }
                    if let repos = result.data?.search.edges{
                        self.hasNext = result.data!.search.pageInfo.hasNextPage
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
        if refreshId == nil {
            //Clear after for every possible old data
            dataController.deleteAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                convertToRepositoryAndSave(graphQLRepo, dataController: dataController, manageContext: manageContext)
            }
        }else{
            convertToRepositoryAndSave(graphQLRepo, dataController: dataController, manageContext: manageContext)
        }
        lastRepoCusor = graphQLRepo.last!!.cursor
        refreshId = graphQLRepo[19]?.node!.asRepository!.id
        
    }
    
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
            repository.cursor = repo!.cursor
            dataController.save()
        }
    }
    
}
