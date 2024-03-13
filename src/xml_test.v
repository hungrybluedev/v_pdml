module main

import pdml

fn test_single_node() {
	node := pdml.Node{
		name: 'test'
	}
	assert node.xml() == '<test/>'
}

fn test_empty_node_with_attributes() {
	node := pdml.Node{
		name: 'test'
		attributes: pdml.Attributes{
			children: [
				pdml.Attribute{
					name: 'attr1'
					value: 'value1'
				},
				pdml.Attribute{
					name: 'attr2'
					value: 'value2'
				},
			]
		}
	}
	assert node.xml() == '<test attr1="value1" attr2="value2"/>'
}

fn test_node_with_one_child() {
	node := pdml.Node{
		name: 'test'
		children: [
			pdml.Node{
				name: 'child'
			},
		]
	}
	assert node.xml() == '<test>\n\t<child/>\n</test>'
}

fn test_big_node_with_mixed_content_and_nested_nodes() {
	node := pdml.Node{
		name: 'document'
		attributes: pdml.Attributes{
			children: [
				pdml.Attribute{
					name: 'version'
					value: '1.0'
				},
			]
		}
		children: [
			pdml.Node{
				name: 'header'
				children: [
					pdml.Node{
						name: 'title'
						children: ['Document Title']
					},
				]
			},
			pdml.Node{
				name: 'body'
				children: [
					pdml.Node{
						name: 'p'
						children: ['This is a paragraph with ', pdml.Node{
							name: 'em'
							children: [
								'emphasized',
							]
						}, ' text.']
					},
				]
			},
		]
	}

	assert node.xml() == '<document version="1.0">\n\t<header>\n\t\t<title>\n\t\t\tDocument Title\n\t\t</title>\n\t</header>\n\t<body>\n\t\t<p>\n\t\t\tThis is a paragraph with \n\t\t\t<em>\n\t\t\t\temphasized\n\t\t\t</em>\n\t\t\t text.\n\t\t</p>\n\t</body>\n</document>'
}

fn test_end_to_end() ! {
	content := '[doc
	[title Small Document]
	[body
		[p This is a paragraph with [em emphasized] text.]
	]
]'
	doc := pdml.Document.parse_string(content)!
	assert doc.root.xml() == '<doc>\n\t<title>\n\t\tSmall Document\n\t</title>\n\t<body>\n\t\t<p>\n\t\t\tThis is a paragraph with\n\t\t\t<em>\n\t\t\t\temphasized\n\t\t\t</em>\n\t\t\ttext.\n\t\t</p>\n\t</body>\n</doc>'
}
