//
//  MarkdownRenderer.swift
//  MarkdownExampleApp
//
//  Created by Colbyn Wadman on 12/28/24.
//

import Foundation
import SwiftUI
import FastMarkdownParser
import SwiftPrettyTree

struct MarkdownRenderer: View {
    @AppStorage("MarkdownRenderer.currentTabView") private var currentTabView: SampleFileType = SampleFileType.sample1
    var body: some View {
        TabView(selection: $currentTabView) {
            ForEach(SampleFileType.allCases) { sample in
                Self.tabView(sampleFile: sample)
            }
        }
    }
    @ViewBuilder private static func tabView(sampleFile: SampleFileType) -> some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    Text(sampleFile.fileContents)
                    Spacer()
                }
            }
        }
        .tabItem {
            Text(sampleFile.resourceName)
        }
        .tag(sampleFile)
    }
}

import UIKit


