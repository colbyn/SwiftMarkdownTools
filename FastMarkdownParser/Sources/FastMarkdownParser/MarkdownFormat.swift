//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 12/27/24.
//

import Foundation

// MARK: - Markdown AST

public enum MarkdownNode {
    case text(Text)
    case newline(Newline)
    case emphasis(Emphasis)
    case strong(Strong)
    case strikethrough(Strikethrough)
    case image(Image)
    case imageReference(ImageReference)
    case link(Link)
    case linkReference(LinkReference)
    case codeBlock(CodeBlock)
    case inlineCode(InlineCode)
    case list(List)
    case listItem(ListItem)
    case heading(Heading)
    case table(Table)
    case tableRow(TableRow)
    case tableCell(TableCell)
    case horizontalDivider(HorizontalDivider)
    case definition(Definition)
    case paragraph(Paragraph)
    case blockquote(Blockquote)
    case footnoteReference(FootnoteReference)
    case footnoteDefinition(FootnoteDefinition)
    case displayMath(DisplayMath)
    case inlineMath(InlineMath)
    case toml(Toml)
    case yaml(Yaml)
    case html(Html)
}

extension MarkdownNode: Codable {
    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "Text":
            self = .text(try Text(from: decoder))
        case "Newline":
            self = .newline(try Newline(from: decoder))
        case "Emphasis":
            self = .emphasis(try Emphasis(from: decoder))
        case "Strong":
            self = .strong(try Strong(from: decoder))
        case "Strikethrough":
            self = .strikethrough(try Strikethrough(from: decoder))
        case "Image":
            self = .image(try Image(from: decoder))
        case "ImageReference":
            self = .imageReference(try ImageReference(from: decoder))
        case "Link":
            self = .link(try Link(from: decoder))
        case "LinkReference":
            self = .linkReference(try LinkReference(from: decoder))
        case "CodeBlock":
            self = .codeBlock(try CodeBlock(from: decoder))
        case "InlineCode":
            self = .inlineCode(try InlineCode(from: decoder))
        case "List":
            self = .list(try List(from: decoder))
        case "ListItem":
            self = .listItem(try ListItem(from: decoder))
        case "Heading":
            self = .heading(try Heading(from: decoder))
        case "Table":
            self = .table(try Table(from: decoder))
        case "TableRow":
            self = .tableRow(try TableRow(from: decoder))
        case "TableCell":
            self = .tableCell(try TableCell(from: decoder))
        case "HorizontalDivider":
            self = .horizontalDivider(try HorizontalDivider(from: decoder))
        case "Definition":
            self = .definition(try Definition(from: decoder))
        case "Paragraph":
            self = .paragraph(try Paragraph(from: decoder))
        case "Blockquote":
            self = .blockquote(try Blockquote(from: decoder))
        case "FootnoteReference":
            self = .footnoteReference(try FootnoteReference(from: decoder))
        case "FootnoteDefinition":
            self = .footnoteDefinition(try FootnoteDefinition(from: decoder))
        case "DisplayMath":
            self = .displayMath(try DisplayMath(from: decoder))
        case "InlineMath":
            self = .inlineMath(try InlineMath(from: decoder))
        case "Toml":
            self = .toml(try Toml(from: decoder))
        case "Yaml":
            self = .yaml(try Yaml(from: decoder))
        case "Html":
            self = .html(try Html(from: decoder))
        default:
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unknown node type: \(type)")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text(let text):
            try container.encode("Text", forKey: .type)
            try text.encode(to: encoder)
        case .newline(let newline):
            try container.encode("Newline", forKey: .type)
            try newline.encode(to: encoder)
        case .emphasis(let emphasis):
            try container.encode("Emphasis", forKey: .type)
            try emphasis.encode(to: encoder)
        case .strong(let strong):
            try container.encode("Strong", forKey: .type)
            try strong.encode(to: encoder)
        case .strikethrough(let strikethrough):
            try container.encode("Strikethrough", forKey: .type)
            try strikethrough.encode(to: encoder)
        case .image(let image):
            try container.encode("Image", forKey: .type)
            try image.encode(to: encoder)
        case .imageReference(let imageReference):
            try container.encode("ImageReference", forKey: .type)
            try imageReference.encode(to: encoder)
        case .link(let link):
            try container.encode("Link", forKey: .type)
            try link.encode(to: encoder)
        case .linkReference(let linkReference):
            try container.encode("LinkReference", forKey: .type)
            try linkReference.encode(to: encoder)
        case .codeBlock(let codeBlock):
            try container.encode("CodeBlock", forKey: .type)
            try codeBlock.encode(to: encoder)
        case .inlineCode(let inlineCode):
            try container.encode("InlineCode", forKey: .type)
            try inlineCode.encode(to: encoder)
        case .list(let list):
            try container.encode("List", forKey: .type)
            try list.encode(to: encoder)
        case .listItem(let listItem):
            try container.encode("ListItem", forKey: .type)
            try listItem.encode(to: encoder)
        case .heading(let heading):
            try container.encode("Heading", forKey: .type)
            try heading.encode(to: encoder)
        case .table(let table):
            try container.encode("Table", forKey: .type)
            try table.encode(to: encoder)
        case .tableRow(let tableRow):
            try container.encode("TableRow", forKey: .type)
            try tableRow.encode(to: encoder)
        case .tableCell(let tableCell):
            try container.encode("TableCell", forKey: .type)
            try tableCell.encode(to: encoder)
        case .horizontalDivider(let horizontalDivider):
            try container.encode("HorizontalDivider", forKey: .type)
            try horizontalDivider.encode(to: encoder)
        case .definition(let definition):
            try container.encode("Definition", forKey: .type)
            try definition.encode(to: encoder)
        case .paragraph(let paragraph):
            try container.encode("Paragraph", forKey: .type)
            try paragraph.encode(to: encoder)
        case .blockquote(let blockquote):
            try container.encode("Blockquote", forKey: .type)
            try blockquote.encode(to: encoder)
        case .footnoteReference(let footnoteReference):
            try container.encode("FootnoteReference", forKey: .type)
            try footnoteReference.encode(to: encoder)
        case .footnoteDefinition(let footnoteDefinition):
            try container.encode("FootnoteDefinition", forKey: .type)
            try footnoteDefinition.encode(to: encoder)
        case .displayMath(let displayMath):
            try container.encode("DisplayMath", forKey: .type)
            try displayMath.encode(to: encoder)
        case .inlineMath(let inlineMath):
            try container.encode("InlineMath", forKey: .type)
            try inlineMath.encode(to: encoder)
        case .toml(let toml):
            try container.encode("Toml", forKey: .type)
            try toml.encode(to: encoder)
        case .yaml(let yaml):
            try container.encode("Yaml", forKey: .type)
            try yaml.encode(to: encoder)
        case .html(let html):
            try container.encode("Html", forKey: .type)
            try html.encode(to: encoder)
        }
    }
}

extension MarkdownNode {
    // MARK: - Inline Nodes

    public struct Text: Codable {
        public let position: SourceRange?
        public let value: String
    }

    public struct Newline: Codable {
        public let position: SourceRange?
    }

    // MARK: - Inline Formatting

    public struct Strong: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
    }

    public struct Emphasis: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
    }

    public struct Strikethrough: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
    }

    // MARK: - Code

    public struct CodeBlock: Codable {
        public let position: SourceRange?
        public let value: String
        public let lang: String?
        public let meta: String?
    }

    public struct InlineCode: Codable {
        public let position: SourceRange?
        public let value: String
    }

    // MARK: - Math

    public struct DisplayMath: Codable {
        public let position: SourceRange?
        public let value: String
        public let meta: String?
    }

    public struct InlineMath: Codable {
        public let position: SourceRange?
        public let value: String
    }

    // MARK: - Links & Images

    public struct Link: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
        public let url: String
        public let title: String?
    }

    public struct LinkReference: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
        public let referenceKind: ReferenceKind
        public let identifier: String
        public let label: String?
    }

    public struct Image: Codable {
        public let position: SourceRange?
        public let alt: String
        public let url: String
        public let title: String?
    }

    public struct ImageReference: Codable {
        public let position: SourceRange?
        public let alt: String
        public let referenceKind: ReferenceKind
        public let identifier: String
        public let label: String?
    }

    // MARK: - Markup

    public struct Toml: Codable {
        public let position: SourceRange?
        public let value: String
    }

    public struct Yaml: Codable {
        public let position: SourceRange?
        public let value: String
    }

    public struct Html: Codable {
        public let position: SourceRange?
        public let value: String
    }

    // MARK: - Block Nodes

    public struct Blockquote: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
    }

    public struct Paragraph: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
    }

    public struct Heading: Codable {
        public let position: SourceRange?
        public let level: HeadingLevel
        public let children: [MarkdownNode]
    }

    public struct Definition: Codable {
        public let position: SourceRange?
        public let url: String
        public let title: String?
        public let identifier: String
        public let label: String?
    }

    public struct FootnoteDefinition: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
        public let identifier: String
        public let label: String?
    }

    public struct FootnoteReference: Codable {
        public let position: SourceRange?
        public let identifier: String
        public let label: String?
    }

    public struct HorizontalDivider: Codable {
        public let position: SourceRange?
    }

    // MARK: - Tables

    public struct Table: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
        public let alignment: [AlignKind]
    }

    public struct TableRow: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
    }

    public struct TableCell: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
    }

    // MARK: - Lists

    public struct List: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
        public let ordered: Bool
        public let start: UInt32?
        public let spread: Bool
    }

    public struct ListItem: Codable {
        public let position: SourceRange?
        public let children: [MarkdownNode]
        public let spread: Bool
        public let checked: Bool?
    }

    public enum ListType: String, Codable {
        case ordered
        case unordered
    }

    // MARK: - Common Enums

    public enum ReferenceKind: String, Codable {
        /// The reference is implicit, its identifier inferred from its content.
        case shortcut = "shortcut"
        /// The reference is explicit, its identifier inferred from its content.
        case collapsed = "collapsed"
        /// The reference is explicit, its identifier explicitly set.
        case full = "full"
    }

    public enum HeadingLevel: String, Codable {
        case h1 = "h1"
        case h2 = "h2"
        case h3 = "h3"
        case h4 = "h4"
        case h5 = "h5"
        case h6 = "h6"
    }

    public enum AlignKind: String, Codable {
        case left = "left"
        case right = "right"
        case center = "center"
        case none = "none"
    }

    // MARK: - SourceRange

    public struct SourceRange: Codable {
        public let start: Position
        public let end: Position
    }

    public struct Position: Codable {
        public let line: UInt
        public let column: UInt
    }
}
