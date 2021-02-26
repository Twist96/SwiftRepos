//
//  HomeView.swift
//  SwiftRepos
//
//  Created by Tochi on 24/02/2021.
//

import SwiftUI
import CoreData
import Apollo

let gitToken = "c519335bd1cce2b9a9b0b5dfe290b94e5a58a074"

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var viewModel = HomeViewModel()
    @FetchRequest(entity: Repository.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Repository.stargazerCount, ascending: false)])
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
            dataController.deleteAll()
        }
        lastRepoCusor = graphQLRepo.last!!.cursor
        refreshId = graphQLRepo[19]?.node!.asRepository!.id
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
