//
//  Screen2.swift
//  lyiglyuvgylu
//
//  this part was coded by adam, who is gay
//

import SwiftUI

struct Screen2: View {
    @State private var title: String = "Unnamed Title"
    @State private var script: String = "Type something..."
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    TextField("Unnamed Title", text: $title)
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                    
                    TextEditor(text: $script)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            print("hello")
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .tabViewBottomAccessory {
            Text("Word Count: \(script.split { $0.isWhitespace }.count)")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
        }
    }
}


#Preview {
    Screen2()
}
