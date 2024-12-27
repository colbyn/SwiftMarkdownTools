/// Location of a node in a source file.
#[derive(Debug, Clone, serde::Serialize)]
pub struct SourceRange {
    /// Represents the place of the first character of the parsed source region.
    pub start: Point,
    /// Represents the place of the first character after the parsed source
    /// region, whether it exists or not.
    pub end: Point,
}

/// One place in a source file.
#[derive(Debug, Clone, serde::Serialize)]
pub struct Point {
    /// 1-indexed integer representing a line in a source file.
    pub line: usize,
    /// 1-indexed integer representing a column in a source file.
    pub column: usize,
    /// 0-indexed integer representing a character in a source file.
    pub offset: usize,
}

#[derive(Debug, Clone, serde::Serialize)]
pub enum ReferenceKind {
    /// The reference is implicit, its identifier inferred from its content.
    Shortcut,
    /// The reference is explicit, its identifier inferred from its content.
    Collapsed,
    /// The reference is explicit, its identifier explicitly set.
    Full,
}

#[derive(Debug, Clone, serde::Serialize)]
pub enum HeadingLevel {
    H1, H2, H3, H4, H5, H6
}

#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize)]
pub enum AlignKind {
    /// Left alignment.
    Left,
    /// Right alignment.
    Right,
    /// Center alignment.
    Center,
    /// No alignment.
    None,
}


//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
// DEBUG HELPERS
//―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
impl pretty_tree::ToPrettyTree for crate::common::ReferenceKind {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        match self {
            Self::Collapsed => pretty_tree::value(String::from("Self::Collapsed")),
            Self::Full => pretty_tree::value(String::from("Self::Full")),
            Self::Shortcut => pretty_tree::value(String::from("Self::Shortcut")),
        }
    }
}
impl pretty_tree::ToPrettyTree for crate::common::HeadingLevel {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        match self {
            Self::H1 => pretty_tree::value("HeadingLevel::H1"),
            Self::H2 => pretty_tree::value("HeadingLevel::H2"),
            Self::H3 => pretty_tree::value("HeadingLevel::H3"),
            Self::H4 => pretty_tree::value("HeadingLevel::H4"),
            Self::H5 => pretty_tree::value("HeadingLevel::H5"),
            Self::H6 => pretty_tree::value("HeadingLevel::H6"),
        }
    }
}
impl pretty_tree::ToPrettyTree for crate::common::AlignKind {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        match self {
            Self::Left => pretty_tree::value("AlignKind::Left"),
            Self::Right => pretty_tree::value("AlignKind::Right"),
            Self::Center => pretty_tree::value("AlignKind::Center"),
            Self::None => pretty_tree::value("AlignKind::None"),
        }
    }
}
