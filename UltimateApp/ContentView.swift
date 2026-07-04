//
//  ContentView.swift
//  UltimateApp
//
//  Created by Jose Rafael Peralta Martinez  on 01/07/26.
//

import SwiftUI
internal import CoreData

struct ContentView: View {
     @EnvironmentObject var dataController: DataController
    
    var issue: [Issue] {
        let filter = dataController.selectedFilter ?? .all
        var allIssues: [Issue]
        
        if let tag = filter.tag {
            allIssues = tag.issues?.allObjects as? [Issue] ?? []
        } else {
            let request = Issue.fetchRequest()
            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }
        
        return allIssues.sorted()
    }
    var body: some View {
        List {
            ForEach(issue) { issue in
                Text(issue.issueTitle)
            }
        }
        .navigationTitle("Issue")
    }
}

#Preview {
    ContentView()
        .environmentObject(DataController.preview)
}
