//
//  ContentView.swift
//  UltimateApp
//
//  Created by Jose Rafael Peralta Martinez  on 01/07/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } content: {
            ContentView()
        } detail: {
            DetailView()
        }

    }
}

#Preview {
    ContentView()
    
}
