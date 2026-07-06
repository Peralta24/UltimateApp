//
//  UltimateAppApp.swift
//  UltimateApp
//
//  Created by Jose Rafael Peralta Martinez  on 01/07/26.
//

import SwiftUI
internal import CoreData

@main
struct UltimateAppApp: App {
    @StateObject var dataController = DataController()
    @Environment(\.scenePhase) var scenePhase
    
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
            .onChange(of: scenePhase){ phase in
                if phase != .active {
                    dataController.save()
                }
            }
        }
    }
}
