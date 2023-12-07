module pml

const default_line_break_threshold = 80

fn optionally_quote(content string) string {
	return if content.contains_any(' \t') {
		'"' + content + '"'
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

fn join_parts(parts []string, config EncodingConfig) string {
	mut line_length := 0
	for part in parts {
		line_length += part.len
	}

	joiner := if line_length > config.line_break_threshold {
		'\n' + config.offset + config.indent
	} else {
		' '
	}
	return parts.join(joiner)
}

fn attributes_to_string(attributes map[string]string, config EncodingConfig) string {
	if attributes.len == 0 {
		return ''
	}
	mut attr_strings := []string{}

	for name, value in attributes {
		attr_strings << optionally_quote(name) + ' = ' + optionally_quote(value)
	}

	return '(' + join_parts(attr_strings, config) + ')'
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

	return '[- ' + join_parts(comment_outputs, config) + ' -]'
}

fn children_to_string(children []Child, config EncodingConfig) string {
	if children.len == 0 {
		return ''
	}

	mut children_strings := []string{}
	for child in children {
		children_strings << match child {
			string {
				child.trim_space()
			}
			Node {
				child.recursive_str(config)
			}
			Comment {
				child.str()
			}
		}
	}

	return join_parts(children_strings, config)
}

fn (node Node) recursive_str(config EncodingConfig) string {
	mut output_parts := []string{}
	output_parts << node.name
	if node.attributes.len > 0 {
		output_parts << attributes_to_string(node.attributes, config)
	}
	if node.children.len > 0 {
		output_parts << children_to_string(node.children, config)
	}
	return '[' + join_parts(output_parts, config) + ']'
}

pub fn (node Node) str() string {
	return node.recursive_str(offset: '')
}
