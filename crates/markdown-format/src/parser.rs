use itertools::Itertools;
use markdown::mdast;
use crate as ast;

pub fn parse(source: impl AsRef<str>) -> Result<Vec<ast::Node>, Box<dyn std::error::Error>> {
    let source = source.as_ref();
    let options = ::markdown::ParseOptions {
        constructs: ::markdown::Constructs {
            attention: true,
            autolink: true,
            block_quote: true,
            character_escape: true,
            character_reference: true,
            code_indented: true,
            code_fenced: true,
            code_text: true,
            definition: false,
            gfm_strikethrough: true,
            gfm_table: true,
            gfm_task_list_item: false,
            hard_break_escape: true,
            hard_break_trailing: true,
            heading_atx: true,
            heading_setext: true,
            html_flow: true,
            html_text: true,
            label_start_image: true,
            label_start_link: true,
            label_end: true,
            list_item: true,
            math_flow: true,
            math_text: true,
            thematic_break: true,
            ..Default::default()
        },
        ..Default::default()
    };
    let node: ::markdown::mdast::Node = ::markdown::to_mdast(source, &options).map_err(ParserError)?;
    Ok(convert_node(&node))
}

#[derive(Debug)]
pub struct ParserError(::markdown::message::Message);

impl std::fmt::Display for ParserError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result { self.0.fmt(f) }
}
impl std::error::Error for ParserError {}

fn convert_node(node: &mdast::Node) -> Vec<ast::Node> {
    match node {
        mdast::Node::Root(root) => {
            root.children.iter().flat_map(convert_node).collect_vec()
        }
        mdast::Node::Blockquote(mdast::Blockquote {position, children}) => {
            let position = position.to_owned().map(Into::into);
            let children = children
                .iter()
                .flat_map(convert_node)
                .collect_vec();
            vec![
                ast::Node::BlockQuote(ast::BlockQuote {
                    position,
                    children,
                })
            ]
        }
        mdast::Node::FootnoteDefinition(node) => {
            let children = node.children
                .iter()
                .flat_map(convert_node)
                .collect_vec();
            let position = node.position.clone().map(Into::into);
            let identifier = node.identifier.clone();
            let label = node.label.clone();
            vec![
                ast::Node::FootnoteDefinition(ast::FootnoteDefinition {
                    children,
                    position,
                    identifier,
                    label,
                })
            ]
        }
        mdast::Node::List(node) => {
            let children = node.children
                .iter()
                .flat_map(convert_node)
                .collect_vec();
            let position = node.position.clone().map(Into::into);
            let ordered = node.ordered.clone();
            let start = node.start.clone();
            let spread = node.spread.clone();
            vec![
                ast::Node::List(ast::List {
                    children,
                    position,
                    ordered,
                    start,
                    spread,
                })
            ]
        }
        mdast::Node::Toml(node) => {
            let value = node.value.clone();
            let position = node.position.clone().map(Into::into);
            vec![
                ast::Node::Toml(ast::Toml { value, position })
            ]
        }
        mdast::Node::Yaml(node) => {
            let value = node.value.clone();
            let position = node.position.clone().map(Into::into);
            vec![
                ast::Node::Yaml(ast::Yaml { value, position })
            ]
        }
        mdast::Node::Html(node) => {
            let value = node.value.clone();
            let position = node.position.clone().map(Into::into);
            vec![
                ast::Node::Html(ast::Html { value, position })
            ]
        }
        mdast::Node::Break(mdast::Break {position}) => {
            let position = position.clone().map(Into::into);
            vec![
                ast::Node::Newline(ast::Newline { position })
            ]
        }
        mdast::Node::InlineCode(node) => {
            let value = node.value.clone();
            let position = node.position.clone().map(Into::into);
            vec![
                ast::Node::InlineCode(ast::InlineCode { value, position })
            ]
        }
        mdast::Node::InlineMath(node) => {
            let value = node.value.clone();
            let position = node.position.clone().map(Into::into);
            vec![
                ast::Node::InlineCode(ast::InlineCode { value, position })
            ]
        }
        mdast::Node::Delete(node) => {
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            let position = node.position.clone().map(Into::into);
            vec![
                ast::Node::Strikethrough(ast::Strikethrough { children, position })
            ]
        }
        mdast::Node::Emphasis(node) => {
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            let position = node.position.clone().map(Into::into);
            vec![
                ast::Node::Strikethrough(ast::Strikethrough { children, position })
            ]
        }
        mdast::Node::FootnoteReference(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let identifier = node.identifier.clone();
            let label = node.label.clone();
            vec![
                ast::Node::FootnoteReference(ast::FootnoteReference{
                    position,
                    identifier,
                    label,
                })
            ]
        }
        mdast::Node::Image(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let alt = node.alt.clone();
            let url = node.url.clone();
            let title = node.title.clone();
            vec![
                ast::Node::Image(ast::Image {
                    position,
                    alt,
                    url,
                    title,
                })
            ]
        }
        mdast::Node::ImageReference(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let alt = node.alt.clone();
            let reference_kind = node.reference_kind.clone().into();
            let identifier = node.identifier.clone();
            let label = node.label.clone();
            vec![
                ast::Node::ImageReference(ast::ImageReference {
                    position,
                    alt,
                    reference_kind,
                    identifier,
                    label,
                })
            ]
        }
        mdast::Node::Link(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            let url = node.url.clone();
            let title = node.title.clone();
            vec![
                ast::Node::Link(ast::Link {
                    position,
                    children,
                    url,
                    title,
                })
            ]
        }
        mdast::Node::LinkReference(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            let reference_kind = node.reference_kind.into();
            let identifier = node.identifier.clone();
            let label = node.label.clone();
            vec![
                ast::Node::LinkReference(ast::LinkReference {
                    position,
                    children,
                    reference_kind,
                    identifier,
                    label,
                })
            ]
        }
        mdast::Node::Strong(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            vec![
                ast::Node::Strong(ast::Strong { position, children })
            ]
        }
        mdast::Node::Text(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let value = node.value.clone();
            vec![
                ast::Node::Text(ast::Text {
                    value,
                    position,
                })
            ]
        }
        mdast::Node::Code(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let value = node.value.clone();
            let lang = node.lang.clone();
            let meta = node.meta.clone();
            vec![
                ast::Node::CodeBlock(ast::CodeBlock {
                    position,
                    value,
                    lang,
                    meta,
                })
            ]
        }
        mdast::Node::Math(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let value = node.value.clone();
            let meta = node.meta.clone();
            vec![
                ast::Node::DisplayMath(ast::DisplayMath {
                    position,
                    value,
                    meta,
                })
            ]
        }
        mdast::Node::Heading(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            let level = match node.depth {
                1 => crate::common::HeadingLevel::H1,
                2 => crate::common::HeadingLevel::H2,
                3 => crate::common::HeadingLevel::H3,
                4 => crate::common::HeadingLevel::H4,
                5 => crate::common::HeadingLevel::H5,
                6 => crate::common::HeadingLevel::H6,
                _ => crate::common::HeadingLevel::H1,
            };
            vec![
                ast::Node::Heading(ast::Heading {
                    level,
                    children,
                    position,
                })
            ]
        }
        mdast::Node::Table(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            let alignment = node.align.clone().into_iter().map(Into::into).collect_vec();
            vec![
                ast::Node::Table(ast::Table {
                    position,
                    children,
                    alignment,
                })
            ]
        }
        mdast::Node::ThematicBreak(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            vec![
                ast::Node::HorizontalDivider(ast::HorizontalDivider { position })
            ]
        }
        mdast::Node::TableRow(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            vec![
                ast::Node::TableRow(ast::TableRow {
                    position,
                    children,
                })
            ]
        }
        mdast::Node::TableCell(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            vec![
                ast::Node::TableCell(ast::TableCell {
                    position,
                    children,
                })
            ]
        }
        mdast::Node::ListItem(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            let spread = node.spread.clone();
            let checked = node.checked.clone();
            vec![
                ast::Node::ListItem(ast::ListItem { children, position, spread, checked })
            ]
        }
        mdast::Node::Definition(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let url = node.url.clone();
            let title = node.title.clone();
            let identifier = node.identifier.clone();
            let label = node.label.clone();
            vec![
                ast::Node::Definition(ast::Definition {
                    position,
                    url,
                    title,
                    identifier,
                    label,
                })
            ]
        }
        mdast::Node::Paragraph(node) => {
            let position = node.position.clone().map(Into::<ast::SourceRange>::into);
            let children = node.children.iter().flat_map(convert_node).collect_vec();
            vec![
                ast::Node::Paragraph(ast::Paragraph { position, children })
            ]
        }
        mdast::Node::MdxJsxFlowElement(_) => Default::default(),
        mdast::Node::MdxTextExpression(_) => Default::default(),
        mdast::Node::MdxJsxTextElement(_) => Default::default(),
        mdast::Node::MdxFlowExpression(_) => Default::default(),
        mdast::Node::MdxjsEsm(_) => Default::default(),
    }
}

impl From<::markdown::unist::Position> for ast::SourceRange {
    fn from(value: ::markdown::unist::Position) -> Self {
        ast::SourceRange {
            start: value.start.into(),
            end: value.end.into(),
        }
    }
}
impl From<::markdown::unist::Point> for ast::Point {
    fn from(::markdown::unist::Point {line, column, offset}: ::markdown::unist::Point) -> Self {
        Self {
            line,
            column,
            offset,
        }
    }
}
impl From<::markdown::mdast::ReferenceKind> for crate::common::ReferenceKind {
    fn from(value: ::markdown::mdast::ReferenceKind) -> Self {
        match value {
            ::markdown::mdast::ReferenceKind::Collapsed => crate::common::ReferenceKind::Collapsed,
            ::markdown::mdast::ReferenceKind::Full => crate::common::ReferenceKind::Full,
            ::markdown::mdast::ReferenceKind::Shortcut => crate::common::ReferenceKind::Shortcut,
        }
    }
}
impl From<::markdown::mdast::AlignKind> for crate::common::AlignKind {
    fn from(value: ::markdown::mdast::AlignKind) -> Self {
        match value {
            ::markdown::mdast::AlignKind::Left => crate::common::AlignKind::Left,
            ::markdown::mdast::AlignKind::Right => crate::common::AlignKind::Right,
            ::markdown::mdast::AlignKind::Center => crate::common::AlignKind::Center,
            ::markdown::mdast::AlignKind::None => crate::common::AlignKind::None,
        }
    }
}