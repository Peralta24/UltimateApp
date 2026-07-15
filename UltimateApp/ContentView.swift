//
//  ContentView.swift
//  UltimateApp
//
//  Created by Jose Rafael Peralta Martinez  on 01/07/26.
//

import SwiftUI
internal import CoreData
internal import Combine

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    
    var body: some View {
        List(selection: $dataController.selectedIssue) {
            ForEach(dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Issue")
    }
    
    func delete(_ offsets: IndexSet) {
        let issues = dataController.issuesForSelectedFilter()
        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataController.preview)
}
