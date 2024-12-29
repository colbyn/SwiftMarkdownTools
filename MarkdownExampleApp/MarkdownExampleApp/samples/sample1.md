# Markdown Parser Test Battery

## Basic Formatting
### Headings
# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

### Paragraphs
This is a single line paragraph.

This is a paragraph with multiple lines of text,
demonstrating how the parser handles soft breaks within a paragraph.

### Bold and Italic
*italic* and _italic_
**bold** and __bold__
***bold italic*** and ___bold italic___

### Strikethrough
~~strikethrough~~

### Escape Characters
\*Not italic\* and \*\*Not bold\*\*

## Links and Images
### Inline Links
[OpenAI](https://www.openai.com "OpenAI Homepage")

### Reference Links
[OpenAI][open-ai]

[open-ai]: https://www.openai.com "OpenAI Homepage"

### Images
![Alt text](https://example.com/image.png "Image Title")

### Reference Images
![Alt text][image]

[image]: https://example.com/image.png "Image Title"

## Lists
### Unordered Lists
- Item one
- Item two
  - Nested item one
  - Nested item two

### Ordered Lists
1. First item
2. Second item
   1. Subitem
   2. Subitem

### Task Lists (if supported)
- [x] Completed task
- [ ] Open task

## Extended Syntax
### Block-quotes
> This is a block-quote.
>
> Multiple paragraphs are supported.

### Code Blocks and Inline Code
`inline code`

```
block code
```

```javascript
console.log('syntax highlighted code');
```

### Tables
| Header 1 | Header 2 | Header 3 |
| -------- | -------- | -------- |
| Row 1    | Data     | Data     |
| Row 2    | Data     | Data     |

### Footnotes (if supported)
Here is a footnote reference[^1].

[^1]: Here is the footnote.

## Edge Cases
### Mixed Content
Here is **bold**, *italic*, and `code` in one sentence.

- This is a list containing [a link](https://example.com) and ![an image](https://example.com/image.png).

### Nested Structures
> **Note:** This is a block-quote containing **bold text** and a [link](https://example.com).
>
> - Mixed lists and block-quotes

### Complex Table with Formatting
| **Bold**    | *Italic*   | `Code` |
| :---------: | :--------: | :----: |
| Data 1      | Data 2     | Data 3 |
| More data 1 | More data 2| Data 4 |
