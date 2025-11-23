//
//  test.swift
//  Local Explorer
//
//  Created by Tony Liu on 11/13/25.
//
import SwiftUI

//@main
//struct TabViewTestApp: App {
//    var body: some Scene {
//        WindowGroup {
//            TestView()
//        }
//    }
//}

struct TestView: View {
    var body: some View {
        TabView {
            Text("First")
                .tabItem { Label("One", systemImage: "1.circle") }

            Text("Second")
                .tabItem { Label("Two", systemImage: "2.circle") }
        }
    }
}

#Preview {
    TestView()
}
