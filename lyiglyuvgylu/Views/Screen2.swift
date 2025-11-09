//
//  Screen2.swift
//  lyiglyuvgylu
//
//  this part was coded by adam
//

import SwiftUI
import FoundationModels

struct Screen2: View {
    @Binding var title: String
    @Binding var script: String
    @State private var showScreen = false
    @FocusState private var isEditingScript: Bool
    
    @State private var rewriting = false
    @State private var rewritePrompt = """
    Rewrite this script. Reply with ONLY the rewritten version of this script...
    """
    
    @State private var showPromptDialog = false
    @State private var rewriteError: String? = nil
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    TextField("Untitled Script", text: $title)
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                    
                    TextEditor(text: $script)
                        .focused($isEditingScript)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showScreen = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button {
                            showPromptDialog = true
                        } label: {
                            Image(systemName: "wand.and.stars")
                        }
                        Spacer()
                        Button {
                            isEditingScript = false
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .alert("Rewrite Failed", isPresented: Binding(get: { rewriteError != nil }, set: { if !$0 { rewriteError = nil } })) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(rewriteError ?? "Unknown error")
                }
                .confirmationDialog("Rewrite with AI", isPresented: $showPromptDialog, titleVisibility: .visible) {
                    TextField("Prompt for rewriting", text: $rewritePrompt)
                    Button("Rewrite Now") {
                        rewriting = true
                        Task {
                            do {
                                let session = LanguageModelSession()
                                let result = try await session.respond(to: "Rewrite this text using these instructions: \(rewritePrompt)\n\nOriginal:\n\(script)")
                                script = result.content
                            } catch {
                                rewriteError = error.localizedDescription
                            }
                            rewriting = false
                        }
                    }.disabled(rewriting)
                    Button("Cancel", role: .cancel) {}
                }
                .overlay {
                    if rewriting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial)
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
        .fullScreenCover(isPresented: $showScreen) {
            Screen3()
        }
    }
}

