module pml

import strings

const default_line_break_threshold = 80

fn optionally_quote(content string) string {
	trigger := content.contains_any(" \t\\'")
	return if trigger {
		is_double_quoted := content[0] == `"` && content[content.len - 1] == `"`
		cleaned_content := if is_double_quoted {
			mut cleaned_buffer := strings.new_builder(content.len - 2)
			mut is_escaped := false

			for i := 1; i < content.len - 1; i++ {
				ch := content[i]
				if is_escaped {
					is_escaped = false
					cleaned_buffer.write_u8(`\\`)
					cleaned_buffer.write_u8(ch)
				} else if ch == `\\` {
					is_escaped = true
				} else if ch == `"` {
					cleaned_buffer.write_u8(`\\`)
					cleaned_buffer.write_u8(`"`)
				} else {
					cleaned_buffer.write_u8(ch)
				}
			}

			cleaned_buffer.str()
		} else {
			content
		}
		'"' + cleaned_content + '"'
	} else {
		content
	}
}

@[params]
pub struct EncodingConfig {
	offset               string
	indent               string = '\t'
	spacing              string = ' '
	line_break_threshold int    = pml.default_line_break_threshold
}

fn escape_plaintext(content string) string {
	return content.replace_each([
		'\\',
		'\\\\',
		'\n',
		'\\n',
		'\r',
		'\\r',
		'\t',
		'\\t',
		'"',
		'\\"',
		'[',
		'\\[',
		']',
		'\\]',
	])
}

type EncodingNodeChild = EncodingNode | string

struct EncodingNode {
	prefix string
	suffix string
	items  []EncodingNodeChild
}

pub fn (comment Comment) encode() EncodingNode {
	mut items := []EncodingNodeChild{cap: comment.content.len}
	for child in comment.content {
		items << match child {
			Comment {
				EncodingNodeChild(child.encode())
			}
			string {
				EncodingNodeChild(child.trim_space())
			}
		}
	}

	return EncodingNode{
		prefix: '[-'
		suffix: ' -]'
		items: items
	}
}

pub fn (attributes Attributes) encode() EncodingNode {
	mut items := []EncodingNodeChild{cap: attributes.contents.len}
	for content in attributes.contents {
		items << match content {
			Comment {
				EncodingNodeChild(content.encode())
			}
			Attribute {
				EncodingNodeChild(optionally_quote(content.name) + ' = ' +
					optionally_quote(content.value))
			}
		}
	}

	return EncodingNode{
		prefix: '('
		suffix: ')'
		items: items
	}
}

// encode converts a PML node into an EncodingNode that is used to
// generate well-formatted PML output.
pub fn (node Node) encode() EncodingNode {
	mut items := []EncodingNodeChild{cap: node.children.len}
	if node.attributes.contents.len > 0 {
		items << node.attributes.encode()
	}
	for child in node.children {
		items << match child {
			Comment, Node {
				EncodingNodeChild(child.encode())
			}
			string {
				EncodingNodeChild(escape_plaintext(child.trim_space()))
			}
		}
	}

	return EncodingNode{
		prefix: '[' + node.name
		suffix: ']'
		items: items
	}
}

// size is a heuristic for the number of chatacters needed to encode the node.
fn (node EncodingNode) size(config EncodingConfig) int {
	mut size := node.prefix.len + node.suffix.len
	for item in node.items {
		size += match item {
			EncodingNode {
				item.size(config)
			}
			string {
				if item.contains('\n') {
					size += config.line_break_threshold
				}
				item.len
			}
		}
	}
	return size
}

fn (node EncodingNode) single_line_output(size int, config EncodingConfig) string {
	mut output := strings.new_builder(size)

	output.write_string(config.offset)
	output.write_string(node.prefix)
	if node.items.len > 0 && node.prefix.len > 1 {
		output.write_string(config.spacing)
	}

	for index, item in node.items {
		if index != 0 {
			output.write_u8(` `)
		}
		output.write_string(match item {
			EncodingNode {
				item.single_line_output(size, offset: '', indent: '')
			}
			string {
				item
			}
		})
	}

	output.write_string(node.suffix)

	return output.str()
}

fn (node EncodingNode) multi_line_output(size int, config EncodingConfig) string {
	mut output := strings.new_builder(size)

	output.write_string(config.offset)
	output.write_string(node.prefix)

	for item in node.items {
		output.write_u8(`\n`)
		output.write_string(config.offset)
		output.write_string(match item {
			EncodingNode {
				item.output(
					offset: config.indent
					indent: config.indent
				)
			}
			string {
				output.write_string(config.indent)
				item
			}
		})
	}

	output.write_u8(`\n`)
	output.write_string(config.offset)
	output.write_string(node.suffix)

	return output.str()
}

fn (node EncodingNode) output(config EncodingConfig) string {
	content_size := node.size(config)
	return if content_size <= config.line_break_threshold {
		node.single_line_output(content_size, config)
	} else {
		node.multi_line_output(content_size, config)
	}
}

pub fn (attributes Attributes) output(config EncodingConfig) string {
	return attributes.encode().output(config)
}

pub fn (comment Comment) str() string {
	return comment.encode().output()
}

pub fn (node Node) str() string {
	return node.encode().output()
}

pub fn (doc PMLDoc) str() string {
	return doc.root.str()
}
