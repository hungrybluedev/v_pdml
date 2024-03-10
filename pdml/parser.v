module pdml

import io
import os
import strings

const default_builder_length = 16
const nodes_without_children = ['image']

// Document.parse_string attempts to parse the given string as a PML document.
pub fn Document.parse_string(content string) !Document {
	mut reader := FullBufferReader{
		contents: content.bytes()
	}
	return Document.parse_reader(mut reader)
}

// Document.parse_file attempts to parse the given file as a PML document.
pub fn Document.parse_file(path string) !Document {
	mut file_reader := os.open(path) or { return error('Failed to open "${path}" for reading.') }
	return Document.parse_reader(mut file_reader)
}

// Document.parse_reader attempts to parse the contents from the reader interface as a PML document.
pub fn Document.parse_reader(mut reader io.Reader) !Document {
	return Document{
		root: parse_single_node(mut reader)!
	}
}

// AttributeParserState is an enum that lists all of the possible states that the attribute parser can be in.
enum AttributeParserState {
	waiting_for_attribute_name
	reading_attribute_name
	waiting_for_equal_sign
	waiting_for_attribute_value
	reading_attribute_value
}

fn parse_attributes(mut reader io.Reader, skipped_parenthesis bool) !Attributes {
	mut local_buf := [u8(0)]
	mut current_state := AttributeParserState.waiting_for_attribute_name

	mut attribute_name_buffer := strings.new_builder(pdml.default_builder_length)
	mut attribute_value_buffer := strings.new_builder(pdml.default_builder_length)
	mut attribute_children := []AttributeChild{}

	for {
		ch := next_char(mut reader, mut local_buf)!
		match ch {
			` `, `\t`, `\n` {
				match current_state {
					.waiting_for_attribute_name, .waiting_for_equal_sign,
					.waiting_for_attribute_value {
						// We skip whitespace
					}
					.reading_attribute_name {
						// We are done reading the attribute name.
						current_state = .waiting_for_equal_sign
					}
					.reading_attribute_value {
						// We are done reading the attribute value.
						name := attribute_name_buffer.str().all_after_first('(')
						value := attribute_value_buffer.str()
						if name.len > 0 && value.len > 0 {
							attribute_children << AttributeChild(Attribute{
								name: name
								value: value
							})
						}
						current_state = .waiting_for_attribute_name
					}
				}
			}
			`[` {
				match current_state {
					.waiting_for_attribute_name {
						attribute_children << AttributeChild(parse_comment(mut reader)!)
					}
					else {
						return error('Unexpected "[" while parsing attribute.')
					}
				}
			}
			`]`, `)` {
				if ch == `]` && !skipped_parenthesis {
					return error('Unexpected "]" while parsing attribute.')
				}
				match current_state {
					.reading_attribute_name {
						if attribute_children.len > 0 || attribute_name_buffer.len > 0 {
							return error('Unexpected ")" while reading attribute name.')
						} else {
							// Empty attribute list.
							return Attributes{}
						}
					}
					.waiting_for_equal_sign {
						return error('Expected "=" to follow immediately after attribute name.')
					}
					.waiting_for_attribute_value {
						return error('Expected attribute value to follow immediately after "=".')
					}
					.waiting_for_attribute_name, .reading_attribute_value {
						// We are done reading the attribute value.
						name := attribute_name_buffer.str().all_after_first('(')
						value := attribute_value_buffer.str()
						if name.len > 0 && value.len > 0 {
							attribute_children << AttributeChild(Attribute{
								name: name
								value: value
							})
						}
						return Attributes{
							children: attribute_children
						}
					}
				}
			}
			`=` {
				match current_state {
					.waiting_for_attribute_name {
						return error('Expected attribute name to follow immediately after opening bracket.')
					}
					.reading_attribute_name, .waiting_for_equal_sign {
						current_state = .waiting_for_attribute_value
					}
					.waiting_for_attribute_value {
						return error('Found "=" twice. Expected to find attribute value.')
					}
					.reading_attribute_value {
						return error('Found "=" twice. Expected to find attribute name or comment.')
					}
				}
			}
			`'`, `"` {
				// This is guaranteed to be the start of a quoted string.
				// We process it until we find the end.
				match current_state {
					.reading_attribute_name {
						return error('Unexpected start of quoted string while reading attribute name.')
					}
					.reading_attribute_value {
						return error('Unexpected start of quoted string while reading attribute value.')
					}
					.waiting_for_equal_sign {
						return error('Expected "=" to follow immediately after attribute name.')
					}
					.waiting_for_attribute_name {
						current_state = .reading_attribute_name
						for {
							inner_ch := next_char(mut reader, mut local_buf)!
							match inner_ch {
								ch {
									// We found the end of the quoted string.
									current_state = .waiting_for_equal_sign
									break
								}
								else {
									attribute_name_buffer.write_u8(inner_ch)
								}
							}
						}
					}
					.waiting_for_attribute_value {
						current_state = .reading_attribute_value
						for {
							inner_ch := next_char(mut reader, mut local_buf)!
							match inner_ch {
								ch {
									current_state = .waiting_for_attribute_name
									name := attribute_name_buffer.str()
									value := attribute_value_buffer.str()
									if name.len > 0 && value.len > 0 {
										attribute_children << AttributeChild(Attribute{
											name: name
											value: value
										})
									}
									break
								}
								else {
									attribute_value_buffer.write_u8(inner_ch)
								}
							}
						}
					}
				}
			}
			else {
				match current_state {
					.waiting_for_attribute_name {
						current_state = .reading_attribute_name
						attribute_name_buffer.write_u8(ch)
					}
					.reading_attribute_name {
						attribute_name_buffer.write_u8(ch)
					}
					.waiting_for_equal_sign {
						return error('Expected "=" to follow immediately after attribute name.')
					}
					.waiting_for_attribute_value {
						current_state = .reading_attribute_value
						attribute_value_buffer.write_u8(ch)
					}
					.reading_attribute_value {
						attribute_value_buffer.write_u8(ch)
					}
				}
			}
		}
	}
	return error('Unexpected end of content.')
}

enum CommentParserState {
	found_dash
	reading_comment
}

fn parse_comment(mut reader io.Reader) !Comment {
	mut local_buf := [u8(0)]
	mut comment_buffer := strings.new_builder(pdml.default_builder_length)
	mut children := []CommentChild{}

	mut current_state := CommentParserState.found_dash
	for {
		ch := next_char(mut reader, mut local_buf)!
		match ch {
			`[` {
				next_ch := next_char(mut reader, mut local_buf)!
				if next_ch != `-` {
					comment_buffer.write_u8(ch)
					comment_buffer.write_u8(next_ch)
					current_state = .reading_comment
					continue
				}
				collected_content := comment_buffer.str().trim_space()
				if collected_content.len > 0 {
					children << CommentChild(collected_content)
				}
				children << parse_comment(mut reader)!
				current_state = .reading_comment
			}
			`-` {
				match current_state {
					.found_dash {
						current_state = .reading_comment
						// Write the dash twice to the buffer.
						comment_buffer.write_u8(ch)
						comment_buffer.write_u8(ch)
					}
					.reading_comment {
						current_state = .found_dash
					}
				}
			}
			`]` {
				match current_state {
					.found_dash {
						collected_content := comment_buffer.str().trim_space()
						if collected_content.len > 0 {
							children << CommentChild(collected_content)
						}
						return Comment{
							children: children
						}
					}
					.reading_comment {
						comment_buffer.write_u8(ch)
					}
				}
			}
			`\n` {
				collected_content := comment_buffer.str().trim_space()
				if collected_content.len > 0 {
					children << CommentChild(collected_content)
				}
			}
			else {
				comment_buffer.write_u8(ch)
				current_state = .reading_comment
			}
		}
	}
	return error('Unexpected end of content.')
}

enum NodeParserState {
	waiting_for_node_name
	reading_node_name
	waiting_for_attributes
	waiting_for_child
	reading_child_string_content
}

fn parse_node_after_bracket(mut reader io.Reader) !Child {
	mut local_buf := [u8(0)]
	mut current_state := NodeParserState.waiting_for_node_name

	mut name_buffer := strings.new_builder(pdml.default_builder_length)
	mut general_child_content := strings.new_builder(pdml.default_builder_length)

	mut attributes := Attributes{}
	mut children := []Child{}

	mut reading_monospace := false
	mut found_slash := false

	for {
		ch := next_char(mut reader, mut local_buf)!
		if found_slash {
			general_child_content.write_u8(ch)
			found_slash = false
			continue
		}
		match ch {
			`\\` {
				found_slash = true
				general_child_content.write_u8(ch)
				continue
			}
			` `, `\t` {
				if reading_monospace {
					general_child_content.write_u8(ch)
					continue
				}
				match current_state {
					.waiting_for_node_name {
						return error('Expected node name to follow immediately after opening bracket.')
					}
					.reading_node_name {
						tag_name := name_buffer.str().to_lower()
						if tag_name == 'monospace' {
							reading_monospace = true
						} else if tag_name in pdml.nodes_without_children {
							// We do not need to wait for '(' to start parsing attributes.
							attributes = parse_attributes(mut reader, true)!
							return Node{
								name: tag_name
								attributes: attributes
							}
						}
						// We are done reading the node name.
						// Restore the tag name.
						name_buffer = strings.new_builder(pdml.default_builder_length)
						name_buffer.write_string(tag_name)
						current_state = .waiting_for_attributes
					}
					.waiting_for_attributes, .waiting_for_child {
						// We skip whitespace
					}
					.reading_child_string_content {
						general_child_content.write_u8(ch)
					}
				}
			}
			`-` {
				match current_state {
					.waiting_for_node_name {
						return parse_comment(mut reader)!
					}
					else {
						current_state = .reading_child_string_content
						general_child_content.write_u8(ch)
					}
				}
			}
			`\n` {
				if reading_monospace {
					general_child_content.write_u8(ch)
					continue
				}
				if children.len == 0 {
					tag_name := name_buffer.str().to_lower()
					if tag_name == 'monospace' {
						reading_monospace = true
					} else if tag_name in pdml.nodes_without_children {
						// We do not need to wait for '(' to start parsing attributes.
						attributes = parse_attributes(mut reader, true)!
						return Node{
							name: tag_name
							attributes: attributes
						}
					}
					// We are done reading the node name.
					// Restore the tag name.
					name_buffer = strings.new_builder(pdml.default_builder_length)
					name_buffer.write_string(tag_name)
					current_state = .reading_child_string_content
					if reading_monospace {
						general_child_content.write_u8(ch)
						continue
					}
				}
				match current_state {
					.waiting_for_node_name {
						return error('Expected node name to follow immediately after opening bracket.')
					}
					.reading_node_name {
						// We are done reading the node name.
						current_state = .waiting_for_attributes
					}
					.waiting_for_attributes, .waiting_for_child {
						// We skip whitespace
					}
					.reading_child_string_content {
						if general_child_content.len > 0 {
							if reading_monospace {
								children << Child(general_child_content.str())
							} else {
								trimmed_content := general_child_content.str().trim_space()
								if trimmed_content.len > 0 {
									children << Child(trimmed_content)
								}
							}
						}
					}
				}
			}
			`(` {
				match current_state {
					.waiting_for_node_name {
						return error('Expected node name to follow immediately after opening bracket.')
					}
					.reading_node_name, .waiting_for_attributes {
						// We are done reading the node name. We found the start of the attributes
						// so we can parse immediately.
						attributes = parse_attributes(mut reader, false)!
						current_state = .waiting_for_child
					}
					.waiting_for_child, .reading_child_string_content {
						// Consider this to be part of the general child content.
						general_child_content.write_u8(ch)
					}
				}
			}
			// TODO: Add support for escape sequences
			`[` {
				match current_state {
					.waiting_for_node_name {
						return error('Expected node name to follow immediately after opening bracket.')
					}
					.reading_node_name, .waiting_for_attributes, .waiting_for_child {
						// We are done reading the node name. We found the start of a child node.
						children << parse_node_after_bracket(mut reader)!
						current_state = .waiting_for_child
					}
					.reading_child_string_content {
						if general_child_content.len > 0 {
							trimmed_content := general_child_content.str().trim_space()
							if trimmed_content.len > 0 {
								children << Child(trimmed_content)
							}
						}
						children << parse_node_after_bracket(mut reader)!
						current_state = .waiting_for_child
					}
				}
			}
			`]` {
				match current_state {
					.waiting_for_node_name {
						return error('Expected node name to follow immediately after opening bracket.')
					}
					.reading_node_name {
						// We encountered an empty node.
						return Node{
							name: name_buffer.str()
							attributes: attributes
						}
					}
					.waiting_for_attributes, .waiting_for_child, .reading_child_string_content {
						if general_child_content.len > 0 {
							if reading_monospace {
								children << Child(general_child_content.str())
							} else {
								trimmed_content := general_child_content.str().trim_space()
								if trimmed_content.len > 0 {
									children << Child(trimmed_content)
								}
							}
						}
						return Node{
							name: name_buffer.str()
							attributes: attributes
							children: children
						}
					}
				}
				reading_monospace = false
			}
			else {
				match current_state {
					.waiting_for_node_name {
						current_state = .reading_node_name
						name_buffer.write_u8(ch)
					}
					.reading_node_name {
						name_buffer.write_u8(ch)
					}
					.waiting_for_attributes {
						// We found the start of a regular string
						current_state = .reading_child_string_content
						general_child_content.write_u8(ch)
					}
					.waiting_for_child {
						// We found the start of a child node.
						current_state = .reading_child_string_content
						general_child_content.write_u8(ch)
					}
					.reading_child_string_content {
						general_child_content.write_u8(ch)
					}
				}
			}
		}
	}

	return error('Unexpected end of content.')
}

pub fn parse_single_node(mut reader io.Reader) !Node {
	mut local_buf := [u8(0)]

	for {
		ch := next_char(mut reader, mut local_buf)!
		match ch {
			` `, `\t`, `\n` {
				// We skip whitespace
			}
			`[` {
				result := parse_node_after_bracket(mut reader)!
				if result !is Node {
					return error('Expected node, found "${result}".')
				}
				return result as Node
			}
			else {
				return error('Expected opening bracket, found "${ch.ascii_str()}".')
			}
		}
	}
	return error('Unexpected end of content.')
}
