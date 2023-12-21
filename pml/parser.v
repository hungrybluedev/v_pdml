module pml

import io
import os
import strings

const default_builder_length = 16

pub fn PMLDoc.parse_string(content string) !PMLDoc {
	mut reader := FullBufferReader{
		contents: content.bytes()
	}
	return PMLDoc.parse_reader(mut reader)
}

pub fn PMLDoc.parse_file(path string) !PMLDoc {
	mut file_reader := os.open(path) or { return error('Failed to open "${path}" for reading.') }
	return PMLDoc.parse_reader(mut file_reader)
}

pub fn PMLDoc.parse_reader(mut reader io.Reader) !PMLDoc {
	return PMLDoc{
		root: parse_single_node(mut reader)!
	}
}

fn parse_attributes(mut reader io.Reader) !Attributes {
	mut local_buf := [u8(0)]
	for {
		ch := next_char(mut reader, mut local_buf)!
		match ch {
			`)` {
				return Attributes{}
			}
			else {
				// Skip
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

fn parse_node_after_bracket(mut reader io.Reader) !Node {
	mut local_buf := [u8(0)]
	mut current_state := NodeParserState.waiting_for_node_name

	mut name_buffer := strings.new_builder(pml.default_builder_length)
	mut general_child_content := strings.new_builder(pml.default_builder_length)

	mut attributes := Attributes{}
	mut children := []Child{}

	for {
		ch := next_char(mut reader, mut local_buf)!
		match ch {
			` `, `\t`, `\n` {
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
						general_child_content.write_u8(ch)
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
						attributes = parse_attributes(mut reader)!
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
						children << Child(general_child_content.str().trim_space())
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
					.reading_node_name, .waiting_for_attributes, .waiting_for_child {
						// We encountered an empty node.
						return Node{
							name: name_buffer.str()
							attributes: attributes
						}
					}
					.reading_child_string_content {
						children << Child(general_child_content.str().trim_space())
						return Node{
							name: name_buffer.str()
							attributes: attributes
							children: children
						}
					}
				}
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
				return parse_node_after_bracket(mut reader)!
			}
			else {
				return error('Expected opening bracket, found "${ch.ascii_str()}".')
			}
		}
	}
	return error('Unexpected end of content.')
}
