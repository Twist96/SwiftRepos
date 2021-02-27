//
//  HomeView.swift
//  SwiftRepos
//
//  Created by Tochi on 24/02/2021.
//

import SwiftUI
import CoreData
import Apollo

let gitToken = "1a9b7fbe4739103b2075122e45413003607cd44e"

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var viewModel = HomeViewModel()
    @FetchRequest(entity: Repository.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Repository.stargazerCount, ascending: false)])
        var repositories: FetchedResults<Repository>
    
    
    var body: some View {
        NavigationView {
            ZStack{
                switch viewModel.appState{
                case .loading:
                    Text("Loading...")
                case .error(let error):
                    ErrorPageView(errorMessage: error)
                case .success:
                    repositoryListView
                }
                
                if viewModel.showToast{
                    ToastView(message: viewModel.toastMessage, show: $viewModel.showToast)
                }
            }
        }
        .onAppear{
            viewModel.fetchGitRepository(dataController: dataController, manageContext: managedObjectContext)
            if !repositories.isEmpty{
                viewModel.appState = .success
                viewModel.databaseHasData = true
            }
        }
    }
    
    
    @ViewBuilder
    var repositoryListView: some View{
        ScrollView {
            LazyVStack {
                ForEach(repositories) { item in
                    RepositoryItem(repository: item)
                        .onAppear{
                            ///checks if this is the right time to fetch more repositories from the server
                            if item.id == viewModel.refreshId{
                                viewModel.fetchGitRepository(dataController: dataController,
                                                   manageContext: managedObjectContext)
                            }
                        }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Repositories")
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

