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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
        }
    }
}
