//
//  WrapView.swift
//  MarkdownExampleApp
//
//  Created by Colbyn Wadman on 12/28/24.
//

import Foundation
import UIKit
import SwiftUI

public struct WrapView<WrappedView: UIView>: View {
    private let newView: () -> WrappedView
    private let updateView: (WrappedView) -> ()
    public init(newView: @escaping () -> WrappedView, updateView: @escaping (WrappedView) -> Void) {
        self.newView = newView
        self.updateView = updateView
    }
    public init(newView: @escaping () -> WrappedView) {
        self.newView = newView
        self.updateView = { _ in ()}
    }
    public var body: some View {
        WrapViewRepresentable(newView: newView, updateView: updateView)
    }
}

fileprivate struct WrapViewRepresentable<WrappedView: UIView>: UIViewRepresentable {
    let newView: () -> WrappedView
    let updateView: (WrappedView) -> ()
    public func makeUIView(context: Context) -> WrappedView {
        return newView()
    }
    
    public func updateUIView(_ uiView: WrappedView, context: Context) {
        updateView(uiView)
    }
    
    public typealias UIViewType = WrappedView
}
