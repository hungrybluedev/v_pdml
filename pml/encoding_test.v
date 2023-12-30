module main

import pml

fn test_empty_node() {
	node := pml.Node{
		name: 'nl'
	}
	assert node.str() == '[nl]'
}

fn test_non_empty_nodes() {
	nodes := [
		pml.Node{
			name: 'i'
			children: [
				'huge',
			]
		},
		pml.Node{
			name: 'image'
			attributes: pml.Attributes{
				children: [
					pml.Attribute{
						name: 'source'
						value: 'strawberries.jpg'
					},
				]
			}
		},
		pml.Node{
			name: 'div'
			children: [
				'A ',
				pml.Node{
					name: 'i'
					children: [
						pml.Node{
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
		pml.Comment{
			children: ['This is a comment.']
		},
		pml.Comment{
			children: ['This is a comment.', 'This is another comment.']
		},
		pml.Comment{
			children: ['Text', pml.Comment{
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
		pml.Node{
			name: 'text'
			children: [
				'Bob',
			]
		},
		pml.Node{
			name: 'text'
			children: [
				'3.14',
			]
		},
		pml.Node{
			name: 'text'
			children: [
				'We want simplicity.',
			]
		},
		pml.Node{
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
	sample_node := pml.Node{
		name: 'test'
		attributes: pml.Attributes{
			children: [
				pml.Attribute{
					name: 'title'
					value: 'A planet'
				},
				pml.Comment{
					children: ['size in mm']
				},
				pml.Attribute{
					name: 'width'
					value: '400'
				},
				pml.Attribute{
					name: 'height'
					value: '248'
				},
				pml.Attribute{
					name: 'path1'
					value: '/root/foo/bar'
				},
				pml.Attribute{
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
	sample_node := pml.Node{
		name: 'test'
		attributes: pml.Attributes{
			children: [
				pml.Attribute{
					name: 'colour'
					value: '"yellow"'
				},
				pml.Attribute{
					name: 'colour'
					value: '"light yellow"'
				},
				pml.Attribute{
					name: 'path'
					value: '"/root/foo/bar"'
				},
				pml.Attribute{
					name: 'path'
					value: '"C:\\\\config.txt"'
				},
				pml.Attribute{
					name: 'list'
					value: '"list[3]"'
				},
				pml.Attribute{
					name: 'list'
					value: '"list\\[3\\]"'
				},
				pml.Attribute{
					name: 'quote'
					value: '"He said\n\\"That\'s ok\\""'
				},
				pml.Attribute{
					name: 'quote'
					value: '"Tim\nTom\nTam"'
				},
				pml.Attribute{
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
	sample_doc := pml.PMLDoc{
		root: pml.Node{
			name: 'doc'
			children: [
				pml.Node{
					name: 'title'
					children: [
						'PML Document Example',
					]
				},
				pml.Node{
					name: 'ch'
					children: [
						pml.Node{
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
				pml.Node{
					name: 'ch'
					children: [
						pml.Node{
							name: 'title'
							children: [
								'Chapter 2',
							]
						},
						'Paragraph',
						pml.Node{
							name: 'image'
							attributes: pml.Attributes{
								children: [
									pml.Attribute{
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
