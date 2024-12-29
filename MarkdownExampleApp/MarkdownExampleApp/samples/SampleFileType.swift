//
//  SampleFileType.swift
//  MarkdownExampleApp
//
//  Created by Colbyn Wadman on 12/28/24.
//

import Foundation

enum SampleFileType: String, CaseIterable, Identifiable {
    case sample1
    case sample2
    case sample3
    case sample4
    var resourceName: String {
        switch self {
        case .sample1: "sample1"
        case .sample2: "sample2"
        case .sample3: "sample3"
        case .sample4: "sample4"
        }
    }
    var fileURL: URL {
        Bundle.main.url(forResource: resourceName, withExtension: "md")!
    }
    var fileContents: String {
        try! String.init(contentsOf: fileURL)
    }
    var id: String { self.rawValue }
}
