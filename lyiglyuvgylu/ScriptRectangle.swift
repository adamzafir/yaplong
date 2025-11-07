//
//  ScriptRectangle.swift
//  lyiglyuvgylu
//
//  Created by Chan Yap Long on 7/11/25.
//

import SwiftUI

struct ScriptRectangle: View {
    @Binding var title: String
    @Binding var text: String
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(75)
                    .padding(.horizontal)
                    .foregroundStyle(.blue)
                    
                    
                
                VStack {
                    HStack {
                        Text(title)
                            .fontWeight(.bold)
                            .font(.title)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.horizontal)
                    
                    HStack {
                        Text(text)
                            .foregroundStyle(.gray)
                            .background()
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            
        }
    }
}

#Preview {
    ScriptRectangle(title: .constant("Title"), text: .constant("Ethan is gay and anyway.."))
}
