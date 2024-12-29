//
//  DocumentView.swift
//  MarkdownExampleApp
//
//  Created by Colbyn Wadman on 12/28/24.
//

import Foundation
import UIKit
import SwiftUI

fileprivate let sampleText: String = """
0123456789ABCD Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque consequat felis nec turpis aliquet tincidunt. Fusce nisi lorem, laoreet at purus nec, interdum vehicula lacus. Aenean facilisis elit in tincidunt sagittis. Vestibulum vulputate porttitor mauris, vitae luctus lacus laoreet nec. Fusce id enim non felis suscipit dictum sit amet sit amet turpis. Nunc massa velit, sodales sit amet posuere at, facilisis at orci. Quisque eu porttitor tortor. Integer nec ornare lorem, a vulputate felis. Cras et eleifend tellus. Mauris sed nisi quis tortor rutrum placerat. Nullam iaculis scelerisque ipsum, in tincidunt diam laoreet at. Phasellus mi erat, commodo a velit quis, tincidunt molestie elit. Morbi vel interdum diam, vel finibus lacus. Fusce auctor massa ligula, at egestas ex rhoncus at.

Integer risus libero, interdum eget sagittis quis, ullamcorper non nulla. Suspendisse potenti. Duis ut ultricies turpis. Aliquam gravida aliquet lacus, gravida congue enim sagittis eget. Sed blandit, dolor et euismod ultrices, ante felis feugiat nisi, ac semper dolor est eu quam. Mauris metus mauris, euismod egestas lacinia sed, hendrerit sit amet sapien. Morbi purus mauris, posuere sed nisi vel, gravida volutpat nunc. Maecenas viverra viverra volutpat. Nam feugiat lobortis quam, at suscipit purus maximus nec. Suspendisse eleifend neque vel libero laoreet viverra.
"""

fileprivate final class RootDocumentView: UIView, UITextInput, UITextSelectionDisplayInteractionDelegate, UITextInputTokenizer, UIContextMenuInteractionDelegate {
    private var textStorage: NSTextStorage
    private var layoutManager: NSLayoutManager
    private var textContainer: NSTextContainer
    private var textSelectionInteraction: UITextSelectionDisplayInteraction?
    
    private var contextMenuInteraction: UIContextMenuInteraction?
    
    private let defaultFontAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.monospacedSystemFont(ofSize: 20, weight: .regular),
    ]

    override init(frame: CGRect) {
        // Initialize TextKit components
        textStorage = NSTextStorage(string: sampleText, attributes: defaultFontAttributes)
        layoutManager = NSLayoutManager()
        textContainer = NSTextContainer(size: frame.size)
        textContainer.widthTracksTextView = true

        super.init(frame: frame)

        // Set up TextKit components
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        selectedTextRange = UITextRange()

        setupTextSelectionInteraction()

        // Set the initial highlighted range
        let highlightedRange: NSRange = NSRange(location: 2, length: 5)
        let start = CustomTextPosition(offset: highlightedRange.location)
        let end = CustomTextPosition(offset: NSMaxRange(highlightedRange))
        selectedTextRange = CustomTextRange(start: start, end: end)
        
        // CONTEXT MENU SUPPORT
        contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        if let interaction = contextMenuInteraction {
            addInteraction(interaction)
        }

        backgroundColor = .white
    }

    // Custom UITextPosition
    fileprivate class CustomTextPosition: UITextPosition {
        var offset: Int
        init(offset: Int) {
            self.offset = offset
        }
    }

    // Custom UITextRange
    fileprivate class CustomTextRange: UITextRange {
        private var startPosition: CustomTextPosition!
        private var endPosition: CustomTextPosition!
        override var start: CustomTextPosition {
            get { startPosition }
            set { startPosition = newValue }
        }
        override var end: CustomTextPosition {
            get { endPosition }
            set { endPosition = newValue }
        }

        override var isEmpty: Bool {
            return start.offset == end.offset
        }

        init(start: CustomTextPosition, end: CustomTextPosition) {
            super.init()
            self.start = start
            self.end = end
        }
        var nsRange: NSRange {
            NSRange(location: start.offset, length: end.offset - start.offset)
        }
    }

    // Custom UITextSelectionRect
    fileprivate class CustomTextSelectionRect: UITextSelectionRect {
        var customRect: CGRect
        var customContainsStart: Bool
        var customContainsEnd: Bool
        var customWritingDirection: NSWritingDirection

        override var rect: CGRect {
            return customRect
        }

        override var containsStart: Bool {
            return customContainsStart
        }

        override var containsEnd: Bool {
            return customContainsEnd
        }

        override var writingDirection: NSWritingDirection {
            return customWritingDirection
        }

        init(rect: CGRect, containsStart: Bool, containsEnd: Bool, writingDirection: NSWritingDirection) {
            self.customRect = rect
            self.customContainsStart = containsStart
            self.customContainsEnd = containsEnd
            self.customWritingDirection = writingDirection
        }
    }

    // Setup Text Selection Interaction
    private func setupTextSelectionInteraction() {
        textSelectionInteraction = UITextSelectionDisplayInteraction(textInput: self, delegate: self)
        if let interaction = textSelectionInteraction {
            addInteraction(interaction)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var selectedTextRange: UITextRange? {
        didSet {
            // Notify the delegate that the selection will change
            inputDelegate?.selectionWillChange(self)
            
            textSelectionInteraction?.setNeedsSelectionUpdate()
            setNeedsDisplay()
            // Ensure the caret position is updated
//            if let selectedRange = selectedTextRange as? CustomTextRange {
//                let caretRect = caretRect(for: selectedRange.end)
//                // Scroll to the caret position if necessary
//                scrollRectToVisible(caretRect, animated: true)
//            }
            // Notify the delegate that the selection has changed
            inputDelegate?.selectionDidChange(self)
        }
    }
    var markedTextRange: UITextRange?
    var markedTextStyle: [NSAttributedString.Key : Any]? {
        get {
//            return nil
            fatalError("TODO: WHEN IS THIS CALLED?")
        }
        set {
            // No-op
            fatalError("TODO: WHEN IS THIS CALLED?")
        }
    }
    weak var inputDelegate: (any UITextInputDelegate)? {
        didSet {
            // Optionally, you can perform some actions when the delegate is set
        }
    }
    var beginningOfDocument: UITextPosition { CustomTextPosition(offset: 0) }
    var endOfDocument: UITextPosition { CustomTextPosition(offset: textStorage.length) }
    var tokenizer: any UITextInputTokenizer { self }
    var hasText: Bool { !textStorage.string.isEmpty }

    func text(in range: UITextRange) -> String? {
        guard let range = range as? CustomTextRange else { return nil }
        let nsRange = range.nsRange
        return (textStorage.string as NSString).substring(with: nsRange)
    }

    func replace(_ range: UITextRange, withText text: String) {
        guard let range = range as? CustomTextRange else { return }
        let nsRange = range.nsRange
        
        // Notify the delegate that the text will change
        inputDelegate?.textWillChange(self)
        
        textStorage.replaceCharacters(in: nsRange, with: text)
        selectedTextRange = CustomTextRange(start: CustomTextPosition(offset: nsRange.location + text.count), end: CustomTextPosition(offset: nsRange.location + text.count))
        textSelectionInteraction?.setNeedsSelectionUpdate()
        
        // Notify the delegate that the text has changed
        inputDelegate?.textDidChange(self)
        
        // Clear the marked text range if the replacement affects it
        if let markedRange = markedTextRange as? CustomTextRange, nsRange.intersection(markedRange.nsRange) != nil {
            unmarkText()
        }
    }

    func setMarkedText(_ markedText: String?, selectedRange: NSRange) {
        // Remove any existing marked text
        unmarkText()

        guard let markedText = markedText else { return }

        // Insert the marked text into the text storage
        let attributedMarkedText = NSAttributedString(string: markedText, attributes: markedTextStyle)
        textStorage.replaceCharacters(in: selectedRange, with: attributedMarkedText)

        // Set the marked text range
        let startPosition = CustomTextPosition(offset: selectedRange.location)
        let endPosition = CustomTextPosition(offset: selectedRange.location + markedText.count)
        markedTextRange = CustomTextRange(start: startPosition, end: endPosition)

        // Update the selection range to include the marked text
        selectedTextRange = markedTextRange
    }

    func unmarkText() {
        if let markedRange = markedTextRange as? CustomTextRange {
            // Remove the marked text from the text storage
            textStorage.replaceCharacters(in: markedRange.nsRange, with: "")
            markedTextRange = nil
        }
    }

    func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        guard let fromPosition = fromPosition as? CustomTextPosition,
              let toPosition = toPosition as? CustomTextPosition else { return nil }
        return CustomTextRange(start: fromPosition, end: toPosition)
    }

    func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        guard let position = position as? CustomTextPosition else { return nil }
        let newOffset = position.offset + offset
        return CustomTextPosition(offset: newOffset)
    }

    func position(from position: UITextPosition, in direction: UITextLayoutDirection, offset: Int) -> UITextPosition? {
        guard let position = position as? CustomTextPosition else { return nil }
        let newOffset = position.offset + (direction == .right ? offset : -offset)
        return CustomTextPosition(offset: newOffset)
    }

    func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
        guard let position = position as? CustomTextPosition,
              let other = other as? CustomTextPosition else { return .orderedSame }
        if position.offset < other.offset {
            return .orderedAscending
        } else if position.offset > other.offset {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }

    func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        guard let from = from as? CustomTextPosition,
              let toPosition = toPosition as? CustomTextPosition else { return 0 }
        return toPosition.offset - from.offset
    }

    func position(within range: UITextRange, farthestIn direction: UITextLayoutDirection) -> UITextPosition? {
        guard let range = range as? CustomTextRange else { return nil }
        if direction == .right {
            return range.end
        } else {
            return range.start
        }
    }

    func characterRange(byExtending position: UITextPosition, in direction: UITextLayoutDirection) -> UITextRange? {
        guard let position = position as? CustomTextPosition else { return nil }
        let newOffset = direction == .right ? position.offset + 1 : position.offset - 1
        return CustomTextRange(start: position, end: CustomTextPosition(offset: newOffset))
    }

    func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> NSWritingDirection {
        return .leftToRight
    }

    func setBaseWritingDirection(_ writingDirection: NSWritingDirection, for range: UITextRange) {
        // No-op
        fatalError("TODO: WHEN IS THIS CALLED?")
    }

    func firstRect(for range: UITextRange) -> CGRect {
        guard let range = range as? CustomTextRange else { return .zero }
        let nsRange = range.nsRange
        let glyphRange = layoutManager.glyphRange(forCharacterRange: nsRange, actualCharacterRange: nil)
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }

    func caretRect(for position: UITextPosition) -> CGRect {
        guard let position = position as? CustomTextPosition else { return .zero }
        let index = position.offset

        // Get the caret rectangle for the given text position
        let glyphIndex = layoutManager.glyphIndexForCharacter(at: index)
        let caretRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)

        return caretRect
    }

    func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        guard let range = range as? CustomTextRange else { return [] }
        let nsRange = NSRange(location: range.start.offset, length: range.end.offset - range.start.offset)

        var selectionRects = [UITextSelectionRect]()
        layoutManager.enumerateEnclosingRects(forGlyphRange: nsRange, withinSelectedGlyphRange: nsRange, in: textContainer) { rect, _ in
            let selectionRect = CustomTextSelectionRect(rect: rect, containsStart: rect.origin.x == 0, containsEnd: rect.maxX == self.bounds.maxX, writingDirection: .leftToRight)
            selectionRects.append(selectionRect)
        }
        return selectionRects
    }

    func closestPosition(to point: CGPoint) -> UITextPosition? {
        let index = layoutManager.glyphIndex(for: point, in: textContainer)
        return CustomTextPosition(offset: index)
    }

    func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
        guard let range = range as? CustomTextRange else { return nil }
        let nsRange = range.nsRange
        let index = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: nil)
        if nsRange.contains(index) {
            return CustomTextPosition(offset: index)
        } else {
            return nil
        }
    }

    func characterRange(at point: CGPoint) -> UITextRange? {
        let index = layoutManager.glyphIndex(for: point, in: textContainer)
        return CustomTextRange(start: CustomTextPosition(offset: index), end: CustomTextPosition(offset: index + 1))
    }

    func insertText(_ text: String) {
        if let markedRange = markedTextRange as? CustomTextRange {
            // Replace the marked text with the new text
            let nsRange = markedRange.nsRange
            let attributedText = NSAttributedString(string: text, attributes: defaultFontAttributes)
            textStorage.replaceCharacters(in: nsRange, with: attributedText)
            selectedTextRange = CustomTextRange(start: CustomTextPosition(offset: nsRange.location + text.count), end: CustomTextPosition(offset: nsRange.location + text.count))
            unmarkText()
        } else if let selectedRange = selectedTextRange as? CustomTextRange {
            let nsRange = selectedRange.nsRange
            let attributedText = NSAttributedString(string: text, attributes: defaultFontAttributes)
            textStorage.replaceCharacters(in: nsRange, with: attributedText)
            selectedTextRange = CustomTextRange(start: CustomTextPosition(offset: nsRange.location + text.count), end: CustomTextPosition(offset: nsRange.location + text.count))
        }
    }

    func deleteBackward() {
        if let selectedRange = selectedTextRange as? CustomTextRange, !selectedRange.isEmpty {
            replace(selectedRange, withText: "")
            selectedTextRange = CustomTextRange(start: selectedRange.start, end: selectedRange.start)
        } else if let selectedRange = selectedTextRange as? CustomTextRange {
            let newPosition = CustomTextPosition(offset: max(0, selectedRange.start.offset - 1))
            selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
            replace(selectedRange, withText: "")
        }
    }

    // Draw the text
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let optimizeDrawing: Bool = { false }() // TURN OFF FOR DEBUGGING
        if optimizeDrawing {
            let visibleRange = layoutManager.glyphRange(forBoundingRect: rect, in: textContainer)
            layoutManager.drawBackground(forGlyphRange: visibleRange, at: .zero)
            layoutManager.drawGlyphs(forGlyphRange: visibleRange, at: .zero)
        } else {
            let range = NSRange(location: 0, length: textStorage.length)
            layoutManager.drawBackground(forGlyphRange: range, at: .zero)
            layoutManager.drawGlyphs(forGlyphRange: range, at: .zero)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update the text container size
        textContainer.size = bounds.size
        textSelectionInteraction?.setNeedsSelectionUpdate()
        // Mark the view as needing display
        setNeedsDisplay()
    }
    
    // MARK: - UITextInputTokenizer API -
    func rangeEnclosingPosition(_ position: UITextPosition, with granularity: UITextGranularity, inDirection direction: UITextDirection) -> UITextRange? {
        guard let position = position as? CustomTextPosition else { return nil }
        let offset = position.offset

        switch granularity {
        case .character:
            return CustomTextRange(start: position, end: CustomTextPosition(offset: offset + 1))
        case .word:
            return rangeEnclosingWord(at: offset)
        case .sentence:
            return rangeEnclosingSentence(at: offset)
        case .paragraph:
            return rangeEnclosingParagraph(at: offset)
        case .line:
            return rangeEnclosingLine(at: offset)
        case .document:
            return CustomTextRange(start: CustomTextPosition(offset: 0), end: CustomTextPosition(offset: textStorage.length))
        @unknown default:
            return nil
        }
    }

    func isPosition(_ position: UITextPosition, atBoundary granularity: UITextGranularity, inDirection direction: UITextDirection) -> Bool {
        guard let position = position as? CustomTextPosition else { return false }
        let offset = position.offset

        switch granularity {
        case .character:
            return true
        case .word:
            return isAtWordBoundary(at: offset, in: direction)
        case .sentence:
            return isAtSentenceBoundary(at: offset, in: direction)
        case .paragraph:
            return isAtParagraphBoundary(at: offset, in: direction)
        case .line:
            return isAtLineBoundary(at: offset, in: direction)
        case .document:
            return offset == 0 || offset == textStorage.length
        @unknown default:
            return false
        }
    }

    func position(from position: UITextPosition, toBoundary granularity: UITextGranularity, inDirection direction: UITextDirection) -> UITextPosition? {
        guard let position = position as? CustomTextPosition else { return nil }
        let offset = position.offset

        switch granularity {
        case .character:
            return CustomTextPosition(offset: offset + (direction.rawValue == UITextStorageDirection.forward.rawValue ? 1 : -1))
        case .word:
            return positionToWordBoundary(from: offset, in: direction)
        case .sentence:
            return positionToSentenceBoundary(from: offset, in: direction)
        case .paragraph:
            return positionToParagraphBoundary(from: offset, in: direction)
        case .line:
            return positionToLineBoundary(from: offset, in: direction)
        case .document:
            return direction.rawValue == UITextStorageDirection.forward.rawValue ? CustomTextPosition(offset: textStorage.length) : CustomTextPosition(offset: 0)
        @unknown default:
            return nil
        }
    }

    func isPosition(_ position: UITextPosition, withinTextUnit granularity: UITextGranularity, inDirection direction: UITextDirection) -> Bool {
        guard let position = position as? CustomTextPosition else { return false }
        let offset = position.offset

        switch granularity {
        case .character:
            return true
        case .word:
            return isWithinWord(at: offset, in: direction)
        case .sentence:
            return isWithinSentence(at: offset, in: direction)
        case .paragraph:
            return isWithinParagraph(at: offset, in: direction)
        case .line:
            return isWithinLine(at: offset, in: direction)
        case .document:
            return offset > 0 && offset < textStorage.length
        @unknown default:
            return false
        }
    }
    
    
    // MARK: - CONTEXT MENU INTERFACE -
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let copyAction = UIAction(title: "Copy", handler: { _ in
                self.handleCopy()
            })
            let cutAction = UIAction(title: "Cut", handler: { _ in
                self.handleCut()
            })
            let pasteAction = UIAction(title: "Paste", handler: { _ in
                self.handlePaste()
            })
            let selectAllAction = UIAction(title: "Select All", handler: { _ in
                self.handleSelectAll()
            })
            return UIMenu(title: "", children: [copyAction, cutAction, pasteAction, selectAllAction])
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) || action == #selector(cut(_:)) || action == #selector(paste(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }

    @objc override func copy(_ sender: Any?) {
        handleCopy()
    }

    @objc override func cut(_ sender: Any?) {
        handleCut()
    }

    @objc override func paste(_ sender: Any?) {
        handlePaste()
    }
    
    // MARK: - KEYBOARD COMMANDS -
    override var keyCommands: [UIKeyCommand]? {
        return [
            // Cursor Movement
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(keyCommandMoveCursorLeft)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(keyCommandMoveCursorRight)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(keyCommandMoveCursorUp)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(keyCommandMoveCursorDown)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .command, action: #selector(keyCommandMoveCursorToStartOfLine)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .command, action: #selector(keyCommandMoveCursorToEndOfLine)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: .command, action: #selector(keyCommandMoveCursorToStartOfDocument)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: .command, action: #selector(keyCommandMoveCursorToEndOfDocument)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .alternate, action: #selector(keyCommandMoveCursorByWordLeft)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .alternate, action: #selector(keyCommandMoveCursorByWordRight)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: .alternate, action: #selector(keyCommandMoveCursorToStartOfParagraph)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: .alternate, action: #selector(keyCommandMoveCursorToEndOfParagraph)),

            // Text Selection
            UIKeyCommand(input: "a", modifierFlags: .command, action: #selector(keyCommandSelectAll)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .shift, action: #selector(keyCommandExtendSelectionLeft)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .shift, action: #selector(keyCommandExtendSelectionRight)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: .shift, action: #selector(keyCommandExtendSelectionUp)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: .shift, action: #selector(keyCommandExtendSelectionDown)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [.command, .shift], action: #selector(keyCommandExtendSelectionToStartOfLine)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [.command, .shift], action: #selector(keyCommandExtendSelectionToEndOfLine)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [.command, .shift], action: #selector(keyCommandExtendSelectionToStartOfDocument)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [.command, .shift], action: #selector(keyCommandExtendSelectionToEndOfDocument)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [.alternate, .shift], action: #selector(keyCommandExtendSelectionByWordLeft)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [.alternate, .shift], action: #selector(keyCommandExtendSelectionByWordRight)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [.alternate, .shift], action: #selector(keyCommandExtendSelectionToStartOfParagraph)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [.alternate, .shift], action: #selector(keyCommandExtendSelectionToEndOfParagraph)),

            // Text Editing
            // TODO: REMOVE THIS - THIS IS MOSTLY A READ ONLY TEXT EDITOR FOR NOW
            UIKeyCommand(input: "x", modifierFlags: .command, action: #selector(keyCommandCut)),
            UIKeyCommand(input: "c", modifierFlags: .command, action: #selector(keyCommandCopy)),
            UIKeyCommand(input: "v", modifierFlags: .command, action: #selector(keyCommandPaste)),
            UIKeyCommand(input: "z", modifierFlags: .command, action: #selector(keyCommandUndo)),
            UIKeyCommand(input: "z", modifierFlags: [.command, .shift], action: #selector(keyCommandRedo)),
            UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: [], action: #selector(keyCommandDeleteForward)),
            UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: .alternate, action: #selector(keyCommandDeleteWordForward)),
            UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: .command, action: #selector(keyCommandDeleteToEndOfLine)),
            UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: .alternate, action: #selector(keyCommandDeleteWordBackward)),
            UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: .command, action: #selector(keyCommandDeleteToStartOfLine)),
        ]
    }

    @objc func keyCommandMoveCursorLeft() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let newPosition = CustomTextPosition(offset: max(0, selectedRange.start.offset - 1))
            selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
        }
    }

    @objc func keyCommandMoveCursorRight() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let newPosition = CustomTextPosition(offset: min(textStorage.length, selectedRange.start.offset + 1))
            selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
        }
    }

    @objc func keyCommandMoveCursorUp() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let caretRect = caretRect(for: selectedRange.start) // Get the caret rectangle
            let targetX = caretRect.midX // Desired horizontal position (x-coordinate)

            // Get the current line fragment rect and move to the previous one
            let glyphIndex = layoutManager.glyphIndexForCharacter(at: currentPosition)
            let currentLineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)

            // Move to the line fragment directly above
            let targetPoint = CGPoint(x: targetX, y: currentLineFragmentRect.origin.y - 1)
            let targetGlyphIndex = layoutManager.glyphIndex(for: targetPoint, in: textContainer)
            let targetCharacterIndex = layoutManager.characterIndexForGlyph(at: targetGlyphIndex)

            // Update the cursor position
            let newPosition = CustomTextPosition(offset: targetCharacterIndex)
            selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
        }
    }

    @objc func keyCommandMoveCursorDown() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let caretRect = caretRect(for: selectedRange.start) // Get the caret rectangle
            let targetX = caretRect.midX // Desired horizontal position (x-coordinate)

            // Get the current line fragment rect and move to the next one
            let glyphIndex = layoutManager.glyphIndexForCharacter(at: currentPosition)
            let currentLineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)

            // Move to the line fragment directly below
            let targetPoint = CGPoint(x: targetX, y: currentLineFragmentRect.maxY + 1)
            let targetGlyphIndex = layoutManager.glyphIndex(for: targetPoint, in: textContainer)
            let targetCharacterIndex = layoutManager.characterIndexForGlyph(at: targetGlyphIndex)

            // Update the cursor position
            let newPosition = CustomTextPosition(offset: targetCharacterIndex)
            selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
        }
    }

    

    @objc func keyCommandMoveCursorToStartOfLine() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentOffset = selectedRange.start.offset
            let glyphIndex = layoutManager.glyphIndexForCharacter(at: currentOffset)
            let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)

            // Find the first character in the current line fragment
            let targetPoint = CGPoint(x: lineFragmentRect.minX + 1, y: lineFragmentRect.midY)
            let targetGlyphIndex = layoutManager.glyphIndex(for: targetPoint, in: textContainer)
            let targetCharacterIndex = layoutManager.characterIndexForGlyph(at: targetGlyphIndex)

            let newPosition = CustomTextPosition(offset: targetCharacterIndex)
            selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
        }
    }

    @objc func keyCommandMoveCursorToEndOfLine() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentOffset = selectedRange.start.offset
            let glyphIndex = layoutManager.glyphIndexForCharacter(at: currentOffset)
            let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)

            // Find the last character in the current line fragment
            let targetPoint = CGPoint(x: lineFragmentRect.maxX - 1, y: lineFragmentRect.midY)
            let targetGlyphIndex = layoutManager.glyphIndex(for: targetPoint, in: textContainer)
            let targetCharacterIndex = layoutManager.characterIndexForGlyph(at: targetGlyphIndex)

            let newPosition = CustomTextPosition(offset: targetCharacterIndex)
            selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
        }
    }


    @objc func keyCommandMoveCursorToStartOfDocument() {
        let newPosition = CustomTextPosition(offset: 0)
        selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
    }

    @objc func keyCommandMoveCursorToEndOfDocument() {
        let newPosition = CustomTextPosition(offset: textStorage.length)
        selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
    }

    @objc func keyCommandMoveCursorByWordLeft() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentOffset = selectedRange.start.offset
            let wordRange = wordRange(for: currentOffset, direction: .backward)
            if let wordStart = wordRange?.location {
                let newPosition = CustomTextPosition(offset: wordStart)
                selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
            }
        }
    }

    @objc func keyCommandMoveCursorByWordRight() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentOffset = selectedRange.start.offset
            let wordRange = wordRange(for: currentOffset, direction: .forward)
            if let wordRangeLocation = wordRange?.location, let wordRangeLength = wordRange?.length {
                let wordEnd = wordRangeLocation + wordRangeLength
                let newPosition = CustomTextPosition(offset: wordEnd)
                selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
            }
        }
    }

    @objc func keyCommandMoveCursorToStartOfParagraph() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let paragraphRange = paragraphRange(for: currentPosition, direction: .backward)
            if let paragraphStart = paragraphRange?.location {
                let newPosition = CustomTextPosition(offset: paragraphStart)
                selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
            }
        }
    }

    @objc func keyCommandMoveCursorToEndOfParagraph() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let paragraphRange = paragraphRange(for: currentPosition, direction: .forward)
            if let paragraphEnd = paragraphRange?.location, let paragraphLength = paragraphRange?.length {
                let newPosition = CustomTextPosition(offset: paragraphEnd + paragraphLength)
                selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
            }
        }
    }

    @objc func keyCommandExtendSelectionLeft() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let newPosition = CustomTextPosition(offset: max(0, selectedRange.start.offset - 1))
            selectedTextRange = CustomTextRange(start: newPosition, end: selectedRange.end)
        }
    }

    @objc func keyCommandExtendSelectionRight() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let newPosition = CustomTextPosition(offset: min(textStorage.length, selectedRange.end.offset + 1))
            selectedTextRange = CustomTextRange(start: selectedRange.start, end: newPosition)
        }
    }

    @objc func keyCommandExtendSelectionUp() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let previousLineRange = lineRange(for: currentPosition, direction: .backward)
            if let previousLineStart = previousLineRange?.location {
                let newPosition = CustomTextPosition(offset: previousLineStart)
                selectedTextRange = CustomTextRange(start: newPosition, end: selectedRange.end)
            }
        }
    }

    @objc func keyCommandExtendSelectionDown() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.end.offset
            let nextLineRange = lineRange(for: currentPosition, direction: .forward)
            if let nextLineStart = nextLineRange?.location {
                let newPosition = CustomTextPosition(offset: nextLineStart)
                selectedTextRange = CustomTextRange(start: selectedRange.start, end: newPosition)
            }
        }
    }

    @objc func keyCommandExtendSelectionToStartOfLine() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentOffset = selectedRange.start.offset
            let glyphIndex = layoutManager.glyphIndexForCharacter(at: currentOffset)
            let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)

            // Extend selection to the start of the line
            let targetPoint = CGPoint(x: lineFragmentRect.minX + 1, y: lineFragmentRect.midY)
            let targetGlyphIndex = layoutManager.glyphIndex(for: targetPoint, in: textContainer)
            let targetCharacterIndex = layoutManager.characterIndexForGlyph(at: targetGlyphIndex)

            let newPosition = CustomTextPosition(offset: targetCharacterIndex)
            selectedTextRange = CustomTextRange(start: newPosition, end: selectedRange.end)
        }
    }

    @objc func keyCommandExtendSelectionToEndOfLine() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentOffset = selectedRange.end.offset
            let glyphIndex = layoutManager.glyphIndexForCharacter(at: currentOffset)
            let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil)

            // Extend selection to the end of the line
            let targetPoint = CGPoint(x: lineFragmentRect.maxX - 1, y: lineFragmentRect.midY)
            let targetGlyphIndex = layoutManager.glyphIndex(for: targetPoint, in: textContainer)
            let targetCharacterIndex = layoutManager.characterIndexForGlyph(at: targetGlyphIndex)

            let newPosition = CustomTextPosition(offset: targetCharacterIndex)
            selectedTextRange = CustomTextRange(start: selectedRange.start, end: newPosition)
        }
    }

    
    @objc func keyCommandExtendSelectionToStartOfDocument() {
        if let currentRange = selectedTextRange as? CustomTextRange {
            let newPosition = CustomTextPosition(offset: 0)
            selectedTextRange = CustomTextRange(start: newPosition, end: currentRange.end)
        }
    }

    @objc func keyCommandExtendSelectionToEndOfDocument() {
        if let currentRange = selectedTextRange as? CustomTextRange {
            let newPosition = CustomTextPosition(offset: textStorage.length)
            selectedTextRange = CustomTextRange(start: currentRange.start, end: newPosition)
        }
    }

    @objc func keyCommandExtendSelectionByWordLeft() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let wordRange = wordRange(for: currentPosition, direction: .backward)
            if let wordStart = wordRange?.location {
                let newPosition = CustomTextPosition(offset: wordStart)
                selectedTextRange = CustomTextRange(start: newPosition, end: selectedRange.end)
            }
        }
    }

    @objc func keyCommandExtendSelectionByWordRight() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.end.offset
            let wordRange = wordRange(for: currentPosition, direction: .forward)
            if let wordEnd = wordRange?.location, let wordLength = wordRange?.length {
                let newPosition = CustomTextPosition(offset: wordEnd + wordLength)
                selectedTextRange = CustomTextRange(start: selectedRange.start, end: newPosition)
            }
        }
    }

    @objc func keyCommandExtendSelectionToStartOfParagraph() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let paragraphRange = paragraphRange(for: currentPosition, direction: .backward)
            if let paragraphStart = paragraphRange?.location {
                let newPosition = CustomTextPosition(offset: paragraphStart)
                selectedTextRange = CustomTextRange(start: newPosition, end: selectedRange.end)
            }
        }
    }

    @objc func keyCommandExtendSelectionToEndOfParagraph() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.end.offset
            let paragraphRange = paragraphRange(for: currentPosition, direction: .forward)
            if let paragraphEnd = paragraphRange?.location, let paragraphLength = paragraphRange?.length {
                let newPosition = CustomTextPosition(offset: paragraphEnd + paragraphLength)
                selectedTextRange = CustomTextRange(start: selectedRange.start, end: newPosition)
            }
        }
    }

    @objc func keyCommandCut() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let selectedText = text(in: selectedRange)
            UIPasteboard.general.string = selectedText
            replace(selectedRange, withText: "")
        }
    }

    @objc func keyCommandCopy() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let selectedText = text(in: selectedRange)
            UIPasteboard.general.string = selectedText
        }
    }

    @objc func keyCommandPaste() {
        if let pasteboardText = UIPasteboard.general.string {
            insertText(pasteboardText)
        }
    }

    @objc func keyCommandUndo() {
        // Implement undo logic
    }

    @objc func keyCommandRedo() {
        // Implement redo logic
    }

    @objc func keyCommandDeleteForward() {
        if let selectedRange = selectedTextRange as? CustomTextRange, !selectedRange.isEmpty {
            replace(selectedRange, withText: "")
            selectedTextRange = CustomTextRange(start: selectedRange.start, end: selectedRange.start)
        } else if let selectedRange = selectedTextRange as? CustomTextRange {
            let newPosition = CustomTextPosition(offset: min(textStorage.length, selectedRange.start.offset + 1))
            selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
            replace(selectedRange, withText: "")
        }
    }

    @objc func keyCommandDeleteWordForward() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let wordRange = wordRange(for: currentPosition, direction: .forward)
            if let wordEnd = wordRange?.location, let wordLength = wordRange?.length {
                let newPosition = CustomTextPosition(offset: wordEnd + wordLength)
                selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
                replace(selectedRange, withText: "")
            }
        }
    }

    @objc func keyCommandDeleteToEndOfLine() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let lineRange = lineRange(for: currentPosition, direction: .forward)
            if let lineEnd = lineRange?.location, let lineLength = lineRange?.length {
                let newPosition = CustomTextPosition(offset: lineEnd + lineLength)
                selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
                replace(selectedRange, withText: "")
            }
        }
    }

    @objc func keyCommandDeleteWordBackward() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let wordRange = wordRange(for: currentPosition, direction: .backward)
            if let wordStart = wordRange?.location {
                let newPosition = CustomTextPosition(offset: wordStart)
                selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
                replace(selectedRange, withText: "")
            }
        }
    }

    @objc func keyCommandDeleteToStartOfLine() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let currentPosition = selectedRange.start.offset
            let lineRange = lineRange(for: currentPosition, direction: .backward)
            if let lineStart = lineRange?.location {
                let newPosition = CustomTextPosition(offset: lineStart)
                selectedTextRange = CustomTextRange(start: newPosition, end: newPosition)
                replace(selectedRange, withText: "")
            }
        }
    }

    // Helper methods to get the line, word, and paragraph ranges for a given position and direction
    private func lineRange(for offset: Int, direction: UITextDirection) -> NSRange? {
        let text = textStorage.string as NSString
        let currentLineRange = text.lineRange(for: NSRange(location: offset, length: 0))

        if direction == .backward {
            if currentLineRange.location == 0 {
                return nil // Already at the first line
            }
            let previousLineRange = text.lineRange(for: NSRange(location: currentLineRange.location - 1, length: 0))
            return previousLineRange
        } else { // forward
            if currentLineRange.location + currentLineRange.length >= text.length {
                return nil // Already at the last line
            }
            let nextLineRange = text.lineRange(for: NSRange(location: currentLineRange.location + currentLineRange.length, length: 0))
            return nextLineRange
        }
    }

    private func wordRange(for offset: Int, direction: UITextDirection) -> NSRange? {
        let text = textStorage.string as NSString
        let length = text.length

        if direction == .backward {
            // Find the start of the previous word
            var startOffset = offset
            while startOffset > 0 {
                let char = text.character(at: startOffset - 1)
                if isWhitespaceOrPunctuation(char: char) {
                    break
                }
                startOffset -= 1
            }
            if startOffset == offset {
                return nil // Already at the start of the word
            }
            return NSRange(location: startOffset, length: offset - startOffset)
        } else { // forward
            // Find the end of the next word
            var endOffset = offset
            while endOffset < length {
                let char = text.character(at: endOffset)
                if isWhitespaceOrPunctuation(char: char) {
                    break
                }
                endOffset += 1
            }
            if endOffset == offset {
                return nil // Already at the end of the word
            }
            return NSRange(location: offset, length: endOffset - offset)
        }
    }

    private func isWhitespaceOrPunctuation(char: unichar) -> Bool {
        let characterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        guard let unicodeScalar = UnicodeScalar(char) else { return false }
        let character = Unicode.Scalar(unicodeScalar)
        return characterSet.contains(character)
    }



    private func paragraphRange(for offset: Int, direction: UITextDirection) -> NSRange? {
        let text = textStorage.string as NSString
        let currentParagraphRange = text.paragraphRange(for: NSRange(location: offset, length: 0))

        if direction == .backward {
            if currentParagraphRange.location == 0 {
                return nil // Already at the first paragraph
            }
            let previousParagraphRange = text.paragraphRange(for: NSRange(location: currentParagraphRange.location - 1, length: 0))
            return previousParagraphRange
        } else { // forward
            if currentParagraphRange.location + currentParagraphRange.length >= text.length {
                return nil // Already at the last paragraph
            }
            let nextParagraphRange = text.paragraphRange(for: NSRange(location: currentParagraphRange.location + currentParagraphRange.length, length: 0))
            return nextParagraphRange
        }
    }
    

    @objc func keyCommandSelectAll() {
        let range = CustomTextRange(start: CustomTextPosition(offset: 0), end: CustomTextPosition(offset: textStorage.length))
        selectedTextRange = range
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let _ = becomeFirstResponder()
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Return false to prevent the gesture recognizer from intercepting the touch events
        return false
    }
}

extension RootDocumentView: UITextInputDelegate {
    func selectionWillChange(_ textInput: UITextInput) {
        // Called before the selection changes
        inputDelegate?.selectionWillChange(textInput)
    }

    func selectionDidChange(_ textInput: UITextInput) {
        // Called after the selection changes
        inputDelegate?.selectionDidChange(textInput)
    }

    func textWillChange(_ textInput: UITextInput?) {
        // Called before the text changes
        inputDelegate?.textWillChange(textInput)
    }

    func textDidChange(_ textInput: UITextInput?) {
        // Called after the text changes
        inputDelegate?.textDidChange(textInput)
    }

    func selectionWillChange(_ textInput: UITextInput?) {
        // Called before the selection changes
        inputDelegate?.selectionWillChange(textInput)
    }

    func selectionDidChange(_ textInput: UITextInput?) {
        // Called after the selection changes
        inputDelegate?.selectionDidChange(textInput)
    }
}

// Extension for handling menu actions
extension RootDocumentView {
    private func handleCopy() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let selectedText = text(in: selectedRange)
            UIPasteboard.general.string = selectedText
        }
    }

    private func handleCut() {
        if let selectedRange = selectedTextRange as? CustomTextRange {
            let selectedText = text(in: selectedRange)
            UIPasteboard.general.string = selectedText
            replace(selectedRange, withText: "")
        }
    }

    private func handlePaste() {
        if let pasteboardText = UIPasteboard.general.string {
            insertText(pasteboardText)
        }
    }

    private func handleSelectAll() {
        let range = CustomTextRange(start: CustomTextPosition(offset: 0), end: CustomTextPosition(offset: textStorage.length))
        selectedTextRange = range
    }
}

// MARK: - UITextInputTokenizer HELEPRS -
extension RootDocumentView {
    private func rangeEnclosingWord(at offset: Int) -> UITextRange? {
        let text = textStorage.string as NSString
        let range = text.rangeOfCharacter(from: .whitespacesAndNewlines, options: [], range: NSRange(location: 0, length: text.length))
        let start = range.location != NSNotFound ? range.location : 0
        let end = range.location != NSNotFound ? range.location + range.length : text.length
        return CustomTextRange(start: CustomTextPosition(offset: start), end: CustomTextPosition(offset: end))
    }

    private func rangeEnclosingSentence(at offset: Int) -> UITextRange? {
        let text = textStorage.string as NSString
        let range = text.rangeOfCharacter(from: .punctuationCharacters, options: [], range: NSRange(location: 0, length: text.length))
        let start = range.location != NSNotFound ? range.location : 0
        let end = range.location != NSNotFound ? range.location + range.length : text.length
        return CustomTextRange(start: CustomTextPosition(offset: start), end: CustomTextPosition(offset: end))
    }

    private func rangeEnclosingParagraph(at offset: Int) -> UITextRange? {
        let text = textStorage.string as NSString
        let range = text.paragraphRange(for: NSRange(location: offset, length: 0))
        return CustomTextRange(start: CustomTextPosition(offset: range.location), end: CustomTextPosition(offset: range.location + range.length))
    }

    private func rangeEnclosingLine(at offset: Int) -> UITextRange? {
        let text = textStorage.string as NSString
        let range = text.lineRange(for: NSRange(location: offset, length: 0))
        return CustomTextRange(start: CustomTextPosition(offset: range.location), end: CustomTextPosition(offset: range.location + range.length))
    }

    private func isAtWordBoundary(at offset: Int, in direction: UITextDirection) -> Bool {
        let text = textStorage.string as NSString
        let range = text.rangeOfCharacter(from: .whitespacesAndNewlines, options: [], range: NSRange(location: 0, length: text.length))
        return range.location == offset || range.location + range.length == offset
    }

    private func isAtSentenceBoundary(at offset: Int, in direction: UITextDirection) -> Bool {
        let text = textStorage.string as NSString
        let range = text.rangeOfCharacter(from: .punctuationCharacters, options: [], range: NSRange(location: 0, length: text.length))
        return range.location == offset || range.location + range.length == offset
    }

    private func isAtParagraphBoundary(at offset: Int, in direction: UITextDirection) -> Bool {
        let text = textStorage.string as NSString
        let range = text.paragraphRange(for: NSRange(location: offset, length: 0))
        return range.location == offset || range.location + range.length == offset
    }

    private func isAtLineBoundary(at offset: Int, in direction: UITextDirection) -> Bool {
        let text = textStorage.string as NSString
        let range = text.lineRange(for: NSRange(location: offset, length: 0))
        return range.location == offset || range.location + range.length == offset
    }

    private func positionToWordBoundary(from offset: Int, in direction: UITextDirection) -> UITextPosition? {
        let text = textStorage.string as NSString
        let range = text.rangeOfCharacter(from: .whitespacesAndNewlines, options: [], range: NSRange(location: 0, length: text.length))
        let newOffset = direction.rawValue == UITextStorageDirection.forward.rawValue ? range.location + range.length : range.location
        return CustomTextPosition(offset: newOffset)
    }

    private func positionToSentenceBoundary(from offset: Int, in direction: UITextDirection) -> UITextPosition? {
        let text = textStorage.string as NSString
        let range = text.rangeOfCharacter(from: .punctuationCharacters, options: [], range: NSRange(location: 0, length: text.length))
        let newOffset = direction.rawValue == UITextStorageDirection.forward.rawValue ? range.location + range.length : range.location
        return CustomTextPosition(offset: newOffset)
    }

    private func positionToParagraphBoundary(from offset: Int, in direction: UITextDirection) -> UITextPosition? {
        let text = textStorage.string as NSString
        let range = text.paragraphRange(for: NSRange(location: offset, length: 0))
        let newOffset = direction.rawValue == UITextStorageDirection.forward.rawValue ? range.location + range.length : range.location
        return CustomTextPosition(offset: newOffset)
    }

    private func positionToLineBoundary(from offset: Int, in direction: UITextDirection) -> UITextPosition? {
        let text = textStorage.string as NSString
        let range = text.lineRange(for: NSRange(location: offset, length: 0))
        let newOffset = direction.rawValue == UITextStorageDirection.forward.rawValue ? range.location + range.length : range.location
        return CustomTextPosition(offset: newOffset)
    }

    private func isWithinWord(at offset: Int, in direction: UITextDirection) -> Bool {
        let text = textStorage.string as NSString
        let range = text.rangeOfCharacter(from: .whitespacesAndNewlines, options: [], range: NSRange(location: 0, length: text.length))
        return range.contains(offset)
    }

    private func isWithinSentence(at offset: Int, in direction: UITextDirection) -> Bool {
        let text = textStorage.string as NSString
        let range = text.rangeOfCharacter(from: .punctuationCharacters, options: [], range: NSRange(location: 0, length: text.length))
        return range.contains(offset)
    }

    private func isWithinParagraph(at offset: Int, in direction: UITextDirection) -> Bool {
        let text = textStorage.string as NSString
        let range = text.paragraphRange(for: NSRange(location: offset, length: 0))
        return range.contains(offset)
    }

    private func isWithinLine(at offset: Int, in direction: UITextDirection) -> Bool {
        let text = textStorage.string as NSString
        let range = text.lineRange(for: NSRange(location: offset, length: 0))
        return range.contains(offset)
    }
}


fileprivate extension UITextDirection {
    static let forward: UITextDirection = UITextDirection(rawValue: 1)
    static let backward: UITextDirection = UITextDirection(rawValue: 0)
}



struct ActiveWorkspace: View {
    var body: some View {
        WrapView {
            RootDocumentView()
        }
//        Text("TODO")
    }
}
