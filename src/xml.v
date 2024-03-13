module pdml

import encoding.xml

pub fn (attributes Attributes) xml() map[string]string {
	mut xml_attributes := map[string]string{}
	for item in attributes.children {
		match item {
			Attribute {
				xml_attributes[item.name] = item.value
			}
			else {
				// Ignore comments
			}
		}
	}
	return xml_attributes
}

fn (child Child) xml(depth int) xml.XMLNodeContents {
	return match child {
		Node {
			child.xml_node(depth)
		}
		string {
			xml.XMLNodeContents(child)
		}
		else {
			xml.XMLNodeContents('')
		}
	}
}

pub fn (node Node) xml_node(depth int) xml.XMLNode {
	return xml.XMLNode{
		name: node.name
		attributes: node.attributes.xml()
		children: node.children.map(it.xml(depth + 1))
	}
}

pub fn (node Node) xml() string {
	return node.xml_node(0).pretty_str('\t', 0, xml.default_entities_reverse)
}
