//
//  UltimateAppApp.swift
//  UltimateApp
//
//  Created by Jose Rafael Peralta Martinez  on 16/02/26.
//

import SwiftUI
internal import CoreData

@main
struct UltimateAppApp: App {
    @StateObject var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
        }
    }
}
