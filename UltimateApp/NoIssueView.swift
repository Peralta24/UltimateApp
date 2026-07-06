//
//  NoIssueView.swift
//  UltimateAppApp
//
//  Created by Jose Rafael Peralta Martinez  on 04/07/26.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)
        
        Button("New Issue") {
            
        }
    }
}

#Preview {
    NoIssueView()
}
