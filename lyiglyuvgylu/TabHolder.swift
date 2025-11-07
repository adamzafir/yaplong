//
//  TabHolder.swift
//  lyiglyuvgylu
//
//  Created by Chan Yap Long on 7/11/25.
//

import SwiftUI

struct TabHolder: View {
    var body: some View {
        TabView {
            Screen1()
                .tabItem {
                    Label("Scripts", systemImage: "swirl.circle.righthalf.filled")
                }
            Settings()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    TabHolder()
}
