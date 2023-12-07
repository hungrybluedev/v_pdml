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
				contents: [
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
			content: ['This is a comment.']
		},
		pml.Comment{
			content: ['This is a comment.', 'This is another comment.']
		},
		pml.Comment{
			content: ['Text', pml.Comment{
				content: ['More text.']
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
		// attributes: {
		// 	'colour1': 'yellow'
		// 	'colour2': 'blue'
		// }
	}
}
