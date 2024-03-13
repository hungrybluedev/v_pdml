module pdml

pub fn (node Node) get_children_by_name(name string) []Node {
	mut result := []Node{}
	if node.name == name {
		result << node
	}
	for child in node.children {
		match child {
			Node {
				result << child.get_children_by_name(name)
			}
			else {
				// Ignore
			}
		}
	}
	return result
}

pub fn (node Node) get_children_by_attribute(name string, value string) []Node {
	mut result := []Node{}
	for child in node.attributes.children {
		match child {
			Attribute {
				if child.name == name && child.value == value {
					result << node
				}
			}
			else {
				// Ignore
			}
		}
	}
	for child in node.children {
		match child {
			Node {
				result << child.get_children_by_attribute(name, value)
			}
			else {
				// Ignore
			}
		}
	}
	return result
}

pub fn (doc Document) get_children_by_name(name string) []Node {
	return doc.root.get_children_by_name(name)
}

pub fn (doc Document) get_children_by_attribute(name string, value string) []Node {
	return doc.root.get_children_by_attribute(name, value)
}
