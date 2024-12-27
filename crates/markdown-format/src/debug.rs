use itertools::Itertools;
use pretty_tree::ToPrettyTree;
use super::data::*;

impl ToPrettyTree for SourceRange {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Position", vec![
            pretty_tree::field("start", &self.start),
            pretty_tree::field("end", &self.end),
        ])
    }
}
impl ToPrettyTree for Point {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Point", vec![
            pretty_tree::field("line", &self.line),
            pretty_tree::field("column", &self.column),
            pretty_tree::field("offset", &self.offset),
        ])
    }
}

impl ToPrettyTree for Node {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        match self {
            Self::Text(x) => x.to_pretty_tree(),
            Self::Newline(x) => x.to_pretty_tree(),
            Self::Emphasis(x) => x.to_pretty_tree(),
            Self::Strong(x) => x.to_pretty_tree(),
            Self::Strikethrough(x) => x.to_pretty_tree(),
            Self::Image(x) => x.to_pretty_tree(),
            Self::ImageReference(x) => x.to_pretty_tree(),
            Self::Link(x) => x.to_pretty_tree(),
            Self::LinkReference(x) => x.to_pretty_tree(),
            Self::CodeBlock(x) => x.to_pretty_tree(),
            Self::InlineCode(x) => x.to_pretty_tree(),
            Self::List(x) => x.to_pretty_tree(),
            Self::ListItem(x) => x.to_pretty_tree(),
            Self::Heading(x) => x.to_pretty_tree(),
            Self::Table(x) => x.to_pretty_tree(),
            Self::TableRow(x) => x.to_pretty_tree(),
            Self::TableCell(x) => x.to_pretty_tree(),
            Self::HorizontalDivider(x) => x.to_pretty_tree(),
            Self::Definition(x) => x.to_pretty_tree(),
            Self::Paragraph(x) => x.to_pretty_tree(),
            Self::BlockQuote(x) => x.to_pretty_tree(),
            Self::FootnoteReference(x) => x.to_pretty_tree(),
            Self::FootnoteDefinition(x) => x.to_pretty_tree(),
            Self::Toml(x) => x.to_pretty_tree(),
            Self::Yaml(x) => x.to_pretty_tree(),
            Self::Html(x) => x.to_pretty_tree(),
            Self::DisplayMath(x) => x.to_pretty_tree(),
            Self::InlineMath(x) => x.to_pretty_tree(),
        }
    }
}

impl ToPrettyTree for Text {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Text", vec![
            pretty_tree::field("value", &self.value),
            // pretty_tree::field("position", &self.position),
        ])
    }
}
impl ToPrettyTree for Newline {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of::<pretty_tree::PrettyTree>("Newline", vec![
            // pretty_tree::field("position", &self.position),
        ])
    }
}
impl ToPrettyTree for Strong {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Strong", vec![
            // pretty_tree::field("position", &self.position),
            children("children", &self.children),
        ])
    }
}
impl ToPrettyTree for Emphasis {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Emphasis", vec![
            // pretty_tree::field("position", &self.position),
            children("children", &self.children),
        ])
    }
}
impl ToPrettyTree for Strikethrough {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Strikethrough", vec![
            // pretty_tree::field("position", &self.position),
            children("children", &self.children),
        ])
    }
}
impl ToPrettyTree for CodeBlock {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("DisplayCode", vec![
            pretty_tree::field("value", &self.value),
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("lang", &self.lang),
            pretty_tree::field("meta", &self.meta),
        ])
    }
}
impl ToPrettyTree for InlineCode {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("InlineCode", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("value", &self.value),
        ])
    }
}
impl ToPrettyTree for DisplayMath {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("DisplayMath", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("value", &self.value),
            pretty_tree::field("meta", &self.meta),
        ])
    }
}
impl ToPrettyTree for InlineMath {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("InlineMath", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("value", &self.value),
        ])
    }
}
impl ToPrettyTree for Link {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Link", vec![
            children("children", &self.children),
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("url", &self.url),
            pretty_tree::field("title", &self.title),
        ])
    }
}
impl ToPrettyTree for LinkReference {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("LinkReference", vec![
            children("children", &self.children),
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("reference_kind", &self.reference_kind),
            pretty_tree::field("identifier", &self.identifier),
            pretty_tree::field("label", &self.label),
        ])
    }
}
impl ToPrettyTree for Image {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Image", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("alt", &self.alt),
            pretty_tree::field("url", &self.url),
            pretty_tree::field("title", &self.title),
        ])
    }
}
impl ToPrettyTree for ImageReference {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("ImageReference", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("alt", &self.alt),
            pretty_tree::field("reference_kind", &self.reference_kind),
            pretty_tree::field("identifier", &self.identifier),
            pretty_tree::field("label", &self.label),
        ])
    }
}
impl ToPrettyTree for Toml {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Toml", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("value", &self.value),
        ])
    }
}
impl ToPrettyTree for Yaml {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Yaml", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("value", &self.value),
        ])
    }
}
impl ToPrettyTree for Html {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Html", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("value", &self.value),
        ])
    }
}
impl ToPrettyTree for BlockQuote {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("BlockQuote", vec![
            // pretty_tree::field("position", &self.position),
            children("children", &self.children),
        ])
    }
}
impl ToPrettyTree for Paragraph {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Paragraph", vec![
            // pretty_tree::field("position", &self.position),
            children("children", &self.children),
        ])
    }
}
impl ToPrettyTree for Heading {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Heading", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("level", &self.level),
            children("children", &self.children),
        ])
    }
}
impl ToPrettyTree for Definition {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Definition", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("url", &self.url),
            pretty_tree::field("title", &self.title),
            pretty_tree::field("identifier", &self.identifier),
            pretty_tree::field("label", &self.label),
        ])
    }
}
impl ToPrettyTree for FootnoteDefinition {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("FootnoteDefinition", vec![
            children("children", &self.children),
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("identifier", &self.identifier),
            pretty_tree::field("label", &self.label),
        ])
    }
}
impl ToPrettyTree for FootnoteReference {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("FootnoteReference", vec![
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("identifier", &self.identifier),
            pretty_tree::field("label", &self.label),
        ])
    }
}
impl ToPrettyTree for HorizontalDivider {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of::<pretty_tree::PrettyTree>("HorizontalDivider", vec![
            // pretty_tree::field("position", &self.position),
        ])
    }
}
impl ToPrettyTree for Table {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("Table", vec![
            // pretty_tree::field("position", &self.position),
            children("children", &self.children),
            pretty_tree::field("align", &self.alignment),
        ])
    }
}
impl ToPrettyTree for TableRow {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("TableRow", vec![
            // pretty_tree::field("position", &self.position),
            children("children", &self.children),
        ])
    }
}
impl ToPrettyTree for TableCell {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("TableCell", vec![
            // pretty_tree::field("position", &self.position),
            children("children", &self.children),
        ])
    }
}
impl ToPrettyTree for List {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("List", vec![
            children("children", &self.children),
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("ordered", &self.ordered),
            pretty_tree::field("start", &self.start),
            pretty_tree::field("spread", &self.spread),
        ])
    }
}
impl ToPrettyTree for ListItem {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        pretty_tree::branch_of("ListItem", vec![
            children("children", &self.children),
            // pretty_tree::field("position", &self.position),
            pretty_tree::field("spread", &self.spread),
            pretty_tree::field("checked", &self.checked),
        ])
    }
}

fn children<T: pretty_tree::ToPrettyTree>(field_name: &str, children: &[T]) -> pretty_tree::PrettyTree {
    let children = children
        .into_iter()
        .map(|x| x.to_pretty_tree())
        .collect_vec();
    pretty_tree::PrettyTree::branch_of(field_name, children)
}