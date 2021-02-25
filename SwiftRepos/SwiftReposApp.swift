//
//  SwiftReposApp.swift
//  SwiftRepos
//
//  Created by Tochi on 24/02/2021.
//

import SwiftUI

@main
struct SwiftReposApp: App {
    @StateObject var dataController: DataController
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: save)

        }
    }
    
    func save(_ note: Notification){
        dataController.save()
    }
}
