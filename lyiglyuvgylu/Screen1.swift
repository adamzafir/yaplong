//
//  Screen1.swift
//  lyiglyuvgylu
//
//  Created by Chan Yap Long on 7/11/25.
//

import SwiftUI

struct Screen1: View {
    
    var body: some View {
        NavigationStack{
            Form{
                NavigationStack {
                    NavigationLink {
                        Screen2()
                    } label: {
                        Text("Demo Script")
                    }
                }
            }
            .navigationTitle("Scripts")        }
    }
}

#Preview {
    Screen1()
}
