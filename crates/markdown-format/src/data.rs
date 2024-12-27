//! Markdown AST.
pub use crate::common::{SourceRange, Point};

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MARKDOWN AST
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
/// A general enumeration of Markdown elements.
#[derive(Debug, Clone, serde::Serialize)]
pub enum Node {
    Text(Text),
    Newline(Newline),
    Emphasis(Emphasis),
    Strong(Strong),
    Strikethrough(Strikethrough),
    Image(Image),
    ImageReference(ImageReference),
    Link(Link),
    LinkReference(LinkReference),
    CodeBlock(CodeBlock),
    InlineCode(InlineCode),
    List(List),
    ListItem(ListItem),
    Heading(Heading),
    Table(Table),
    TableRow(TableRow),
    TableCell(TableCell),
    HorizontalDivider(HorizontalDivider),
    Definition(Definition),
    Paragraph(Paragraph),
    BlockQuote(BlockQuote),
    FootnoteReference(FootnoteReference),
    FootnoteDefinition(FootnoteDefinition),
    DisplayMath(DisplayMath),
    InlineMath(InlineMath),
    Toml(Toml),
    Yaml(Yaml),
    Html(Html),
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct Fragment(pub Vec<Node>);

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// # INLINE NODES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Debug, Clone, serde::Serialize)]
pub struct Text {
    /// Content model.
    pub value: String,
    /// Positional info.
    pub position: Option<SourceRange>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct Newline {
    /// Positional info.
    pub position: Option<SourceRange>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ## INLINE FORMATTING
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

/// Strong.
///
/// ```markdown
/// > | **a**
///     ^^^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct Strong {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
}

/// Emphasis.
///
/// ```markdown
/// > | *a*
///     ^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct Emphasis {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
}

/// GFM: delete.
///
/// ```markdown
/// > | ~~a~~
///     ^^^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct Strikethrough {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// CODE
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
/// Code (flow).
///
/// ```markdown
/// > | ~~~
///     ^^^
/// > | a
///     ^
/// > | ~~~
///     ^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct CodeBlock {
    // Text.
    /// Content model.
    pub value: String,
    /// Positional info.
    pub position: Option<SourceRange>,
    // Extra.
    /// The language of computer code being marked up.
    pub lang: Option<String>,
    /// Custom info relating to the node.
    pub meta: Option<String>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct InlineCode {
    // Text.
    /// Content model.
    pub value: String,
    /// Positional info.
    pub position: Option<SourceRange>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MATH
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
/// Math (flow).
///
/// ```markdown
/// > | $$
///     ^^
/// > | a
///     ^
/// > | $$
///     ^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct DisplayMath {
    // Text.
    /// Content model.
    pub value: String,
    /// Positional info.
    pub position: Option<SourceRange>,
    // Extra.
    /// Custom info relating to the node.
    pub meta: Option<String>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct InlineMath {
    // Text.
    /// Content model.
    pub value: String,
    /// Positional info.
    pub position: Option<SourceRange>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// LINKS & IMAGES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Debug, Clone, serde::Serialize)]
pub struct Link {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
    // Resource.
    /// URL to the referenced resource.
    pub url: String,
    /// Advisory info for the resource, such as something that would be
    /// appropriate for a tooltip.
    pub title: Option<String>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct LinkReference {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
    // Reference.
    /// Explicitness of a reference.
    pub reference_kind: crate::common::ReferenceKind,
    // Association.
    /// Value that can match another node.
    /// `identifier` is a source value: character escapes and character references
    /// are *not* parsed.
    /// Its value must be normalized.
    pub identifier: String,
    /// `label` is a string value: it works just like `title` on a link or a
    /// `lang` on code: character escapes and character references are parsed.
    ///
    /// To normalize a value, collapse markdown whitespace (`[\t\n\r ]+`) to a
    /// space, trim the optional initial and/or final space, and perform
    /// case-folding.
    pub label: Option<String>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct Image {
    // Void.
    /// Positional info.
    pub position: Option<SourceRange>,
    // Alternative.
    /// Equivalent content for environments that cannot represent the node as
    /// intended.
    pub alt: String,
    // Resource.
    /// URL to the referenced resource.
    pub url: String,
    /// Advisory info for the resource, such as something that would be
    /// appropriate for a tooltip.
    pub title: Option<String>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct ImageReference {
    // Void.
    /// Positional info.
    pub position: Option<SourceRange>,
    // Alternative.
    /// Equivalent content for environments that cannot represent the node as
    /// intended.
    pub alt: String,
    // Reference.
    /// Explicitness of a reference.
    pub reference_kind: crate::common::ReferenceKind,
    // Association.
    /// Value that can match another node.
    /// `identifier` is a source value: character escapes and character references
    /// are *not* parsed.
    /// Its value must be normalized.
    pub identifier: String,
    /// `label` is a string value: it works just like `title` on a link or a
    /// `lang` on code: character escapes and character references are parsed.
    ///
    /// To normalize a value, collapse markdown whitespace (`[\t\n\r ]+`) to a
    /// space, trim the optional initial and/or final space, and perform
    /// case-folding.
    pub label: Option<String>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// MARKUP
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
/// Frontmatter: toml.
///
/// ```markdown
/// > | +++
///     ^^^
/// > | a: b
///     ^^^^
/// > | +++
///     ^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct Toml {
    // Void.
    /// Content model.
    pub value: String,
    /// Positional info.
    pub position: Option<SourceRange>,
}

/// Frontmatter: yaml.
///
/// ```markdown
/// > | ---
///     ^^^
/// > | a: b
///     ^^^^
/// > | ---
///     ^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct Yaml {
    // Void.
    /// Content model.
    pub value: String,
    /// Positional info.
    pub position: Option<SourceRange>,
}

/// Html (flow or phrasing).
///
/// ```markdown
/// > | <a>
///     ^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct Html {
    // Text.
    /// Content model.
    pub value: String,
    /// Positional info.
    pub position: Option<SourceRange>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// # BLOCK NODES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Debug, Clone, serde::Serialize)]
pub struct BlockQuote {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct Paragraph {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct Heading {
    pub level: crate::common::HeadingLevel,
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
}

/// Definition.
///
/// ```markdown
/// > | [a]: b
///     ^^^^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct Definition {
    // Void.
    /// Positional info.
    pub position: Option<SourceRange>,
    // Resource.
    /// URL to the referenced resource.
    pub url: String,
    /// Advisory info for the resource, such as something that would be
    /// appropriate for a tooltip.
    pub title: Option<String>,
    // Association.
    /// Value that can match another node.
    /// `identifier` is a source value: character escapes and character references
    /// are *not* parsed.
    /// Its value must be normalized.
    pub identifier: String,
    /// `label` is a string value: it works just like `title` on a link or a
    /// `lang` on code: character escapes and character references are parsed.
    ///
    /// To normalize a value, collapse markdown whitespace (`[\t\n\r ]+`) to a
    /// space, trim the optional initial and/or final space, and perform
    /// case-folding.
    pub label: Option<String>,
}

/// GFM: footnote definition.
///
/// ```markdown
/// > | [^a]: b
///     ^^^^^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct FootnoteDefinition {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
    // Association.
    /// Value that can match another node.
    /// `identifier` is a source value: character escapes and character references
    /// are *not* parsed.
    /// Its value must be normalized.
    pub identifier: String,
    /// `label` is a string value: it works just like `title` on a link or a
    /// `lang` on code: character escapes and character references are parsed.
    ///
    /// To normalize a value, collapse markdown whitespace (`[\t\n\r ]+`) to a
    /// space, trim the optional initial and/or final space, and perform
    /// case-folding.
    pub label: Option<String>,
}

/// GFM: footnote reference.
///
/// ```markdown
/// > | [^a]
///     ^^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct FootnoteReference {
    // Void.
    /// Positional info.
    pub position: Option<SourceRange>,
    // Association.
    /// Value that can match another node.
    /// `identifier` is a source value: character escapes and character references
    /// are *not* parsed.
    /// Its value must be normalized.
    pub identifier: String,
    /// `label` is a string value: it works just like `title` on a link or a
    /// `lang` on code: character escapes and character references are parsed.
    ///
    /// To normalize a value, collapse markdown whitespace (`[\t\n\r ]+`) to a
    /// space, trim the optional initial and/or final space, and perform
    /// case-folding.
    pub label: Option<String>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct HorizontalDivider {
    // Void.
    /// Positional info.
    pub position: Option<SourceRange>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ## TABLES
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
/// GFM: table.
///
/// ```markdown
/// > | | a |
///     ^^^^^
/// > | | - |
///     ^^^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct Table {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
    // Extra.
    /// Represents how cells in columns are aligned.
    pub alignment: Vec<crate::common::AlignKind>,
}

/// GFM: table row.
///
/// ```markdown
/// > | | a |
///     ^^^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct TableRow {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
}

/// GFM: table cell.
///
/// ```markdown
/// > | | a |
///     ^^^^^
/// ```
#[derive(Debug, Clone, serde::Serialize)]
pub struct TableCell {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
}

//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// ## LISTS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
#[derive(Debug, Clone, serde::Serialize)]
pub struct List {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
    // Extra.
    /// Ordered (`true`) or unordered (`false`).
    pub ordered: bool,
    /// Starting number of the list.
    /// `None` when unordered.
    pub start: Option<u32>,
    /// One or more of its children are separated with a blank line from its
    /// siblings (when `true`), or not (when `false`).
    pub spread: bool,
}

#[derive(Debug, Clone, serde::Serialize)]
pub struct ListItem {
    // Parent.
    /// Content model.
    pub children: Vec<Node>,
    /// Positional info.
    pub position: Option<SourceRange>,
    // Extra.
    /// The item contains two or more children separated by a blank line
    /// (when `true`), or not (when `false`).
    pub spread: bool,
    /// GFM: whether the item is done (when `true`), not done (when `false`),
    /// or indeterminate or not applicable (`None`).
    pub checked: Option<bool>,
}

#[derive(Debug, Clone, serde::Serialize)]
pub enum ListType {
    Ordered,
    Unordered,
}

#[derive(Debug, Clone, serde::Serialize)]
pub enum ListItemType {
    Ordered,
    Unordered,
    Task { checked: bool },
}