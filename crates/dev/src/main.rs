use std::path::{Path, PathBuf};
use pretty_tree::ToPrettyTree;

fn main() {
    wax::Glob::new("*.md")
        .unwrap()
        .walk("samples")
        .into_iter()
        .map(|x| x.unwrap())
        .map(|x| x.into_path())
        .for_each(process_sample_markdown_file);
}

fn process_sample_markdown_file(file_path: impl AsRef<Path>) {
    let markdown_file = MarkdownFile::open(file_path);
    let formatter_style = pretty_tree::FormatterStyle::default().use_color(false);
    let formatter = pretty_tree::Formatter::new(formatter_style);
    let markdown_file = markdown_file.to_pretty_tree().format(&formatter);
    println!("{markdown_file}")
}

struct MarkdownFile {
    file_path: PathBuf,
    nodes: Vec<markdown_format::Node>,
}

impl MarkdownFile {
    pub fn open(file_path: impl AsRef<Path>) -> Self {
        let file_path = file_path.as_ref().to_path_buf();
        let source = std::fs::read_to_string(&file_path).unwrap();
        let nodes = ::markdown_format::parse(source).unwrap();
        Self { file_path, nodes }
    }
}

impl pretty_tree::ToPrettyTree for MarkdownFile {
    fn to_pretty_tree(&self) -> pretty_tree::PrettyTree {
        let file_path = self.file_path.to_str().unwrap().to_owned();
        pretty_tree::PrettyTree::branch_of("MarkdownFile", vec![
            pretty_tree::field("file_path", &file_path),
            pretty_tree::branch_of("nodes", &self.nodes),
        ])
    }
}


