//
//  MarkdownExampleAppApp.swift
//  MarkdownExampleApp
//
//  Created by Colbyn Wadman on 12/27/24.
//

import SwiftUI
import FastMarkdownParser

@main
struct MarkdownExampleAppApp: App {
    var body: some Scene {
        WindowGroup {
            Text("TODO").onAppear {
                print("RUNNING")
                FastMarkdownParser.testTelloWorld()
            }
        }
    }
}
