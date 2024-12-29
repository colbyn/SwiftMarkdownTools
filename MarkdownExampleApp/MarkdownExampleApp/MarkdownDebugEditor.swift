//
//  MarkdownDebugEditor.swift
//  MarkdownExampleApp
//
//  Created by Colbyn Wadman on 12/28/24.
//

import Foundation
import SwiftUI
import FastMarkdownParser
import SwiftPrettyTree

struct MarkdownDebugEditor: View {
    @AppStorage("MarkdownDebugEditor.currentTabView") var currentTabView: Int = 1
    @AppStorage("MarkdownDebugEditor.textBuffer") private var textBuffer: String = "# Hello World!"
    @State private var parsedMarkdownOutput: String?
    @State private var parsedMarkdownOutputError: String?
    @State private var parsedMarkdownAST: [ MarkdownNode ]?
    @State private var parsedMarkdownASTError: String?
    @State private var panicOnError: Bool = false
    @State private var showEditorOptionsPopover: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                editorPane
                Divider()
                TabView(selection: $currentTabView) {
                    parsedMarkdownASTDisplay.tabItem { Text("Parsed AST") }.tag(Int(1))
                    internalParsedMarkdownDisplay.tabItem { Text("Internal") }.tag(Int(2))
                }
            }
            Divider()
        }
    }
    @ViewBuilder private var editorPane: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Button("Options", action: { showEditorOptionsPopover = true }).popover(isPresented: $showEditorOptionsPopover) {
                    VStack(alignment: .center, spacing: 10) {
                        ForEach(SampleFileType.allCases) { sample in
                            Button(sample.rawValue) {
                                textBuffer = sample.fileContents
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .padding(10)
            Divider()
            TextEditor(text: $textBuffer)
        }
    }
    @ViewBuilder private var internalParsedMarkdownDisplay: some View {
        let parseMarkdownButton = Button("Parse Markdown") {
            parsedMarkdownOutput = nil
            parsedMarkdownOutputError = nil
            switch FastMarkdownParser.internalParseToJsonStringSlow(source: textBuffer, prettyPrint: true) {
            case .failure(let error): parsedMarkdownOutputError = error.message
            case .success(let output): parsedMarkdownOutput = output
            }
        }
        if let parsedMarkdownOutputError = parsedMarkdownOutputError {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 10) {
                    parseMarkdownButton
                    Divider()
                    Text(parsedMarkdownOutputError)
                        .textSelection(.enabled)
                }
                .frame(minWidth: 200)
                .padding(10)
            }
        } else if let parsedMarkdownOutput = parsedMarkdownOutput {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 10) {
                    parseMarkdownButton
                    Divider()
                    Text(parsedMarkdownOutput)
                        .textSelection(.enabled)
                }
                .frame(minWidth: 200)
                .padding(10)
            }
        } else {
            VStack(alignment: .center, spacing: 0) {
                parseMarkdownButton
            }
            .padding(10)
        }
    }
    @ViewBuilder private var parsedMarkdownASTDisplay: some View {
        let parseMarkdownButton = Button("Parse Markdown") {
            parsedMarkdownAST = nil
            parsedMarkdownASTError = nil
            do {
                let result = panicOnError ? try! FastMarkdownParser.parse(source: textBuffer) : try FastMarkdownParser.parse(source: textBuffer)
                switch result {
                case .failure(let error):
                    parsedMarkdownASTError = error.message
                case .success(let nodes):
                    parsedMarkdownAST = nodes
                }
            } catch let error {
                parsedMarkdownASTError = "\(error)"
            }
        }
        let header = HStack(alignment: .center, spacing: 10) {
            Toggle("Panic On Error", isOn: $panicOnError).fixedSize(horizontal: true, vertical: false)
            Spacer()
            parseMarkdownButton
        }
        if let parsedMarkdownASTError = parsedMarkdownASTError {
            VStack(alignment: .leading, spacing: 0) {
                header.padding(10)
                Divider()
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 0) {
                            Text(parsedMarkdownASTError)
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                .textSelection(.enabled)
                            Spacer()
                        }
                    }
                    .padding(10)
                    .frame(minWidth: 200)
                }
            }
        } else if let parsedMarkdownAST = parsedMarkdownAST {
            VStack(alignment: .leading, spacing: 0) {
                header.padding(10)
                Divider()
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 0) {
                            Text(parsedMarkdownAST.asPrettyTree.format())
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                .textSelection(.enabled)
                            Spacer()
                        }
                    }
                    .padding(10)
                    .frame(minWidth: 200)
                }
            }
        } else {
            VStack(alignment: .trailing, spacing: 0) {
                header.padding(10)
                Divider()
                Spacer()
            }
        }
    }

}
