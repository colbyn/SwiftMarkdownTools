//
//  MarkdownFormatDebug.swift
//
//
//  Created by Colbyn Wadman on 12/27/24.
//

import Foundation
import SwiftPrettyTree

extension MarkdownNode: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        switch self {
        case .text(let text): return text.asPrettyTree
        case .newline(let newline): return newline.asPrettyTree
        case .emphasis(let emphasis): return emphasis.asPrettyTree
        case .strong(let strong): return strong.asPrettyTree
        case .strikethrough(let strikethrough): return strikethrough.asPrettyTree
        case .image(let image): return image.asPrettyTree
        case .imageReference(let imageReference): return imageReference.asPrettyTree
        case .link(let link): return link.asPrettyTree
        case .linkReference(let linkReference): return linkReference.asPrettyTree
        case .codeBlock(let codeBlock): return codeBlock.asPrettyTree
        case .inlineCode(let inlineCode): return inlineCode.asPrettyTree
        case .list(let list): return list.asPrettyTree
        case .listItem(let listItem): return listItem.asPrettyTree
        case .heading(let heading): return heading.asPrettyTree
        case .table(let table): return table.asPrettyTree
        case .tableRow(let tableRow): return tableRow.asPrettyTree
        case .tableCell(let tableCell): return tableCell.asPrettyTree
        case .horizontalDivider(let horizontalDivider): return horizontalDivider.asPrettyTree
        case .definition(let definition): return definition.asPrettyTree
        case .paragraph(let paragraph): return paragraph.asPrettyTree
        case .blockquote(let blockquote): return blockquote.asPrettyTree
        case .footnoteReference(let footnoteReference): return footnoteReference.asPrettyTree
        case .footnoteDefinition(let footnoteDefinition): return footnoteDefinition.asPrettyTree
        case .displayMath(let displayMath): return displayMath.asPrettyTree
        case .inlineMath(let inlineMath): return inlineMath.asPrettyTree
        case .toml(let toml): return toml.asPrettyTree
        case .yaml(let yaml): return yaml.asPrettyTree
        case .html(let html): return html.asPrettyTree
        }
    }
}

extension MarkdownNode.Text: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(key: "Text", value: PrettyTree(string: self.value))
    }
}
extension MarkdownNode.Newline: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(value: "Newline")
    }
}
extension MarkdownNode.Emphasis: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Emphasis", children: self.children.map { $0.asPrettyTree })
    }
}
extension MarkdownNode.Strong: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Strong", children: self.children.map { $0.asPrettyTree })
    }
}
extension MarkdownNode.Strikethrough: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Strikethrough", children: self.children.map { $0.asPrettyTree })
    }
}
extension MarkdownNode.Image: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Image", children: [
            PrettyTree(key: "alt", value: alt),
            PrettyTree(key: "url", value: url),
            PrettyTree(key: "title", value: title),
        ])
    }
}
extension MarkdownNode.ImageReference: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "ImageReference", children: [
            PrettyTree(key: "alt", value: alt),
            PrettyTree(key: "referenceKind", value: referenceKind.rawValue),
            PrettyTree(key: "identifier", value: identifier),
            PrettyTree(key: "label", value: label),
        ])
    }
}
extension MarkdownNode.Link: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Link", children: [
            PrettyTree(key: "url", value: url),
            PrettyTree(key: "title", value: title),
            PrettyTree(label: "children", children: self.children.map({$0.asPrettyTree})),
        ])
    }
}
extension MarkdownNode.LinkReference: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "LinkReference", children: [
            PrettyTree(key: "referenceKind", value: referenceKind.rawValue),
            PrettyTree(key: "identifier", value: identifier),
            PrettyTree(key: "label", value: label),
            PrettyTree(label: "children", children: self.children.map({$0.asPrettyTree})),
        ])
    }
}
extension MarkdownNode.CodeBlock: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "CodeBlock", children: [
            PrettyTree(key: "value", value: value),
            PrettyTree(key: "lang", value: lang),
            PrettyTree(key: "meta", value: meta),
        ])
    }
}
extension MarkdownNode.InlineCode: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "InlineCode", children: [
            PrettyTree(key: "value", value: value),
        ])
    }
}
extension MarkdownNode.List: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        let bool2PP: (Bool) -> PrettyTree = {
            if $0 {
                return PrettyTree.value("True")
            } else {
                return PrettyTree.value("False")
            }
        }
        let start2PP: (UInt32?) -> PrettyTree = {
            if let x = $0 {
                return PrettyTree(value: x.description)
            } else {
                return PrettyTree(value: "nil")
            }
        }
        return PrettyTree.init(label: "List", children: [
            PrettyTree(key: "ordered", value: bool2PP(ordered)),
            PrettyTree(key: "start", value: start2PP(start)),
            PrettyTree(key: "spread", value: bool2PP(spread)),
            PrettyTree(label: "children", children: children.map({$0.asPrettyTree})),
        ])
    }
}
extension MarkdownNode.ListItem: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        let bool2PP: (Bool?) -> PrettyTree = {
            switch $0 {
            case .some(true): return PrettyTree.value("true")
            case .some(false): return PrettyTree.value("false")
            case .none: return PrettyTree.value("nil")
            }
        }
        return PrettyTree(label: "ListItem", children: [
            PrettyTree(key: "spread", value: bool2PP(spread)),
            PrettyTree(key: "checked", value: bool2PP(checked)),
            PrettyTree(label: "children", children: children.map({$0.asPrettyTree})),
        ])
    }
}
extension MarkdownNode.Heading: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Heading.\(self.level.rawValue)", children: self.children.map { $0.asPrettyTree })
    }
}
extension MarkdownNode.Table: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "Table", children: [
            PrettyTree(label: "children", children: children.map {$0.asPrettyTree} ),
            PrettyTree(label: "alignment", children: alignment.map {$0.rawValue.asPrettyTree} ),
        ])
    }
}
extension MarkdownNode.TableRow: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "TableRow", children: self.children.map { $0.asPrettyTree })
    }
}
extension MarkdownNode.TableCell: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        return PrettyTree(label: "TableCell", children: self.children.map { $0.asPrettyTree })
    }
}
extension MarkdownNode.HorizontalDivider: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(value: "HorizontalDivider")
    }
}
extension MarkdownNode.Definition: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Definition", children: [
            PrettyTree(key: "url", value: url),
            PrettyTree(key: "title", value: title),
            PrettyTree(key: "identifier", value: identifier),
            PrettyTree(key: "label", value: label),
        ])
    }
}
extension MarkdownNode.Paragraph: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Paragraph", children: self.children.map { $0.asPrettyTree })
    }
}
extension MarkdownNode.Blockquote: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "Blockquote", children: self.children.map { $0.asPrettyTree })
    }
}
extension MarkdownNode.FootnoteReference: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "FootnoteReference", children: [
            PrettyTree(key: "identifier", value: identifier),
            PrettyTree(key: "label", value: label),
        ])
    }
}
extension MarkdownNode.FootnoteDefinition: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "FootnoteDefinition", children: [
            PrettyTree(key: "identifier", value: identifier),
            PrettyTree(key: "label", value: label),
            PrettyTree(label: "children", children: children.map { $0.asPrettyTree })
        ])
    }
}
extension MarkdownNode.DisplayMath: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "DisplayMath", children: [
            PrettyTree(key: "value", value: value),
            PrettyTree(key: "meta", value: meta),
        ])
    }
}
extension MarkdownNode.InlineMath: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "InlineMath", children: [
            PrettyTree(key: "value", value: value)
        ])
    }
}
extension MarkdownNode.Toml: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "InlineMath", children: [
            PrettyTree(key: "value", value: value)
        ])
    }
}
extension MarkdownNode.Yaml: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "InlineMath", children: [
            PrettyTree(key: "value", value: value)
        ])
    }
}
extension MarkdownNode.Html: ToPrettyTree {
    public var asPrettyTree: PrettyTree {
        PrettyTree(label: "InlineMath", children: [
            PrettyTree(key: "value", value: value)
        ])
    }
}
