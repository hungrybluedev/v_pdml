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
	line_break_threshold int    = pml.default_line_break_threshold
}

pub fn (comment Comment) str() string {
	return comment_to_string(comment, offset: '')
}

fn join_parts(parts []string, prefix string, suffix string, config EncodingConfig) string {
	mut line_length := 0
	for part in parts {
		line_length += part.len
		if part.contains('\n') {
			line_length += config.line_break_threshold
		}
	}

	too_long := line_length > config.line_break_threshold

	joiner := if too_long {
		'\n' + config.offset + config.indent
	} else {
		' '
	}

	combined := parts.join(joiner)
	return if too_long {
		new_line_offset := '\n' + config.offset

		prefix + new_line_offset + config.indent + combined + new_line_offset + suffix
	} else {
		prefix + combined + suffix
	}
}

fn attributes_to_string(attributes Attributes, config EncodingConfig) string {
	if attributes.contents.len == 0 {
		return ''
	}
	mut attr_strings := []string{}

	for content in attributes.contents {
		// optionally_quote(name) + ' = ' + optionally_quote(value)
		attr_strings << match content {
			Comment {
				comment_to_string(content, config)
			}
			Attribute {
				optionally_quote(content.name) + ' = ' + optionally_quote(content.value)
			}
		}
	}

	return join_parts(attr_strings, '(', ')', offset: config.offset + config.indent)
}

fn comment_to_string(comment Comment, config EncodingConfig) string {
	if comment.content.len == 0 {
		return ''
	}
	mut comment_outputs := []string{}
	for child in comment.content {
		comment_outputs << match child {
			Comment {
				comment_to_string(child, config)
			}
			string {
				child.trim_space()
			}
		}
	}

	return join_parts(comment_outputs, '[- ', ' -]', config)
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

fn children_to_string(children []Child, config EncodingConfig) string {
	if children.len == 0 {
		return ''
	}

	mut children_strings := []string{}
	for child in children {
		children_strings << match child {
			string {
				escape_plaintext(child.trim_space())
			}
			Node {
				child.recursive_str(config)
			}
			Comment {
				child.str()
			}
		}
	}

	return join_parts(children_strings, '', '', config)
}

fn (node Node) recursive_str(config EncodingConfig) string {
	mut output_parts := []string{}
	output_parts << node.name
	if node.attributes.contents.len > 0 {
		output_parts << attributes_to_string(node.attributes, config)
	}
	if node.children.len > 0 {
		output_parts << children_to_string(node.children, config)
	}
	return join_parts(output_parts, '[', ']', config)
}

pub fn (node Node) str() string {
	return node.recursive_str(offset: '')
}
