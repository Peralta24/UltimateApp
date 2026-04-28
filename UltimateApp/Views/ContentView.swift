//
//  ContentView.swift
//  UltimateApp
//
//  Created by Jose Rafael Peralta Martinez  on 16/02/26.
//

import SwiftUI
internal import CoreData

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var issues: [Issue] {
        let filter = dataController.selectedFilter ?? .all
        var allIssues: [Issue]

        if let tag = filter.tag {
            allIssues = tag.issues?.allObjects as? [Issue] ?? []
        } else {
            let request = Issue.fetchRequest()
            request.predicate = NSPredicate(format: "modificationDate > %@",filter.minModificationDate as NSDate)
            allIssues = (try? dataController.container.viewContext.fetch(request)) ?? []
        }

        return allIssues.sorted()
    }
    var body: some View {
        VStack {
            List {
                ForEach(issues) { issue in
                    IssueRowView(issue: issue)
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Issues")
        }
    }
    
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
}
