//
//  MarkdownExampleAppApp.swift
//  MarkdownExampleApp
//
//  Created by Colbyn Wadman on 12/27/24.
//

import SwiftUI
import FastMarkdownParser
import SwiftPrettyTree

@main
struct MarkdownExampleApp: App {
    @AppStorage("MarkdownExampleApp.currentTabView") var currentTabView: Int = 1
    var body: some Scene {
        WindowGroup {
            TabView(selection: $currentTabView) {
                MarkdownDebugEditor()
                    .tabItem { Text("Debug Editor") }
                    .tag(1)
                MarkdownRenderer()
                    .tabItem { Text("Sample Previews") }
                    .tag(2)
                ActiveWorkspace()
                    .tabItem { Text("Active Workspace") }
                    .tag(3)
            }
        }
        .windowResizability(.contentMinSize)
    }
}
