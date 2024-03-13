module main

import pdml

fn test_empty_node() {
	node := pdml.Node{
		name: 'nl'
	}
	assert node.str() == '[nl]'
}

fn test_non_empty_nodes() {
	nodes := [
		pdml.Node{
			name: 'i'
			children: [
				'huge',
			]
		},
		pdml.Node{
			name: 'image'
			attributes: pdml.Attributes{
				children: [
					pdml.Attribute{
						name: 'source'
						value: 'strawberries.jpg'
					},
				]
			}
		},
		pdml.Node{
			name: 'div'
			children: [
				'A ',
				pdml.Node{
					name: 'i'
					children: [
						pdml.Node{
							name: 'b'
							children: [
								'nice',
							]
						},
					]
				},
				' dog.',
			]
		},
	]
	outputs := [
		'[i huge]',
		'[image (source = strawberries.jpg)]',
		'[div A [i [b nice]] dog.]',
	]

	for index, node in nodes {
		assert node.str() == outputs[index]
	}
}

fn test_comment() {
	comments := [
		pdml.Comment{
			children: ['This is a comment.']
		},
		pdml.Comment{
			children: ['This is a comment.', 'This is another comment.']
		},
		pdml.Comment{
			children: ['Text', pdml.Comment{
				children: ['More text.']
			}]
		},
	]
	outputs := [
		'[- This is a comment. -]',
		'[- This is a comment. This is another comment. -]',
		'[- Text [- More text. -] -]',
	]
	for index, comment in comments {
		assert comment.str() == outputs[index]
	}
}

fn test_common_elements() {
	sample_texts := [
		pdml.Node{
			name: 'text'
			children: [
				'Bob',
			]
		},
		pdml.Node{
			name: 'text'
			children: [
				'3.14',
			]
		},
		pdml.Node{
			name: 'text'
			children: [
				'We want simplicity.',
			]
		},
		pdml.Node{
			name: 'text'
			children: [
				'root\\config["port"]',
			]
		},
	]
	outputs := [
		'[text Bob]',
		'[text 3.14]',
		'[text We want simplicity.]',
		'[text root\\\\config\\[\\"port\\"\\]]',
	]
	for index, text in sample_texts {
		assert text.str() == outputs[index]
	}
}

fn test_attributes() {
	sample_node := pdml.Node{
		name: 'test'
		attributes: pdml.Attributes{
			children: [
				pdml.Attribute{
					name: 'title'
					value: 'A planet'
				},
				pdml.Comment{
					children: ['size in mm']
				},
				pdml.Attribute{
					name: 'width'
					value: '400'
				},
				pdml.Attribute{
					name: 'height'
					value: '248'
				},
				pdml.Attribute{
					name: 'path1'
					value: '/root/foo/bar'
				},
				pdml.Attribute{
					name: 'path2'
					value: 'C:\\\\config.txt'
				},
			]
		}
	}
	assert sample_node.str() == '[test
	(
		title = "A planet"
		[- size in mm -]
		width = 400
		height = 248
		path1 = /root/foo/bar
		path2 = "C:\\\\config.txt"
	)
]'
}

fn test_quoted_value_attributes() {
	sample_node := pdml.Node{
		name: 'test'
		attributes: pdml.Attributes{
			children: [
				pdml.Attribute{
					name: 'colour'
					value: '"yellow"'
				},
				pdml.Attribute{
					name: 'colour'
					value: '"light yellow"'
				},
				pdml.Attribute{
					name: 'path'
					value: '"/root/foo/bar"'
				},
				pdml.Attribute{
					name: 'path'
					value: '"C:\\\\config.txt"'
				},
				pdml.Attribute{
					name: 'list'
					value: '"list[3]"'
				},
				pdml.Attribute{
					name: 'list'
					value: '"list\\[3\\]"'
				},
				pdml.Attribute{
					name: 'quote'
					value: '"He said\n\\"That\'s ok\\""'
				},
				pdml.Attribute{
					name: 'quote'
					value: '"Tim\nTom\nTam"'
				},
				pdml.Attribute{
					name: 'empty'
					value: '""'
				},
			]
		}
	}
	assert sample_node.str() == '[test
	(
		colour = "yellow"
		colour = "light yellow"
		path = "/root/foo/bar"
		path = "C:\\\\config.txt"
		list = "list[3]"
		list = "list\\[3\\]"
		quote = "He said\n\\"That\'s ok\\""
		quote = "Tim\nTom\nTam"
		empty = ""
	)
]'
}

fn test_medium_document() {
	sample_doc := pdml.Document{
		root: pdml.Node{
			name: 'doc'
			children: [
				pdml.Node{
					name: 'title'
					children: [
						'PML Document Example',
					]
				},
				pdml.Node{
					name: 'ch'
					children: [
						pdml.Node{
							name: 'title'
							children: [
								'Chapter 1',
							]
						},
						'Text of paragraph 1.',
						'Text of paragraph 2.',
						'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
					]
				},
				pdml.Node{
					name: 'ch'
					children: [
						pdml.Node{
							name: 'title'
							children: [
								'Chapter 2',
							]
						},
						'Paragraph',
						pdml.Node{
							name: 'image'
							attributes: pdml.Attributes{
								children: [
									pdml.Attribute{
										name: 'source'
										value: 'images/strawberries.jpg'
									},
								]
							}
						},
					]
				},
			]
		}
	}
	expected_output := '[doc
	[title PML Document Example]
	[ch
		[title Chapter 1]
		Text of paragraph 1.
		Text of paragraph 2.
		Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
	]
	[ch [title Chapter 2] Paragraph [image (source = images/strawberries.jpg)]]
]'
	assert sample_doc.str() == expected_output, 'Sample document does not match expected output.'
}
