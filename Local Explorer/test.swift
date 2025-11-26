//
//  test.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/13/25.
//
import SwiftUI
import UIKit
import FoundationModels
struct TestView: View {
    var body: some View {
        @State var question = ""
        @State var reply = ""
        TabView {
            Tab("First", systemImage: "1.circle"){
                Form{
                    Section("LLM"){
                        TextField("question", text: $question)
                        Button("ASK"){
                            let session = LanguageModelSession()
                            Task {
                                do{
                                    let response = try await session.respond(to: question)
                                    reply = response.content
                                } catch {
                                    print(error)
                                }
                            }
                        }
                        Text(reply)
                    }
                }
            }
            //    .tabItem { Label("One", systemImage: "1.circle") }
            
            //Text("Second")
            //   .tabItem { Label("Two", systemImage: "2.circle") }
        }
    }
}

#Preview {
    TestView()
}
