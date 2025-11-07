//
//  TabHolder.swift
//  lyiglyuvgylu
//
//  Created by Chan Yap Long on 7/11/25.
//

import SwiftUI

enum Tabs {
    case scripts
    case settings
    case add
}

struct TabHolder: View {
    @State private var selectedTab: Tabs = .scripts

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Scripts", systemImage: "swirl.circle.righthalf.filled", value: Tabs.scripts) {
                Screen1()
            }

            Tab("Settings", systemImage: "gear", value: Tabs.settings) {
                Settings()
            }

            Tab("Add", systemImage: "plus", value: Tabs.add, role: .search) {
                Text("hi")
            }
            
        }
    }
}

#Preview {
    TabHolder()
}
