module cases

import spec { PMLTestCase, PMLTestSuite }
import pml { Attribute, Attributes, Node, PMLDoc }

pub const user_manual = PMLTestSuite{
	name: 'User Manual Test Cases'
	desc: 'Contains all of the examples presented in the user manual for PML.'
	cases: [
		PMLTestCase{
			name: 'First Example'
			desc: 'Simple example with a document, title, and italicised text.'
			input: '
		[doc [title First test]
			This is a [i simple] example.
		]'
			expected: PMLDoc{
				root: Node{
					name: 'doc'
					children: [
						Node{
							name: 'title'
							children: [
								'First test',
							]
						},
						'This is a',
						Node{
							name: 'i'
							children: [
								'simple',
							]
						},
						'example.',
					]
				}
			}
		},
		PMLTestCase{
			name: 'Second Example'
			desc: 'Example with a document, title, and a list.'
			input: '
		[doc [title PML Document Example]
		    [ch [title Chapter 1]
		        Text of paragraph 1.
		        Text of paragraph 2.
		        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
		    ]
		    [ch [title Chapter 2]
		        Paragraph
		        [image (source = images/strawberries.jpg)]
		    ]
		]'
			expected: PMLDoc{
				root: Node{
					name: 'doc'
					children: [
						Node{
							name: 'title'
							children: [
								'PML Document Example',
							]
						},
						Node{
							name: 'ch'
							children: [
								Node{
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
						Node{
							name: 'ch'
							children: [
								Node{
									name: 'title'
									children: [
										'Chapter 2',
									]
								},
								'Paragraph',
								Node{
									name: 'image'
									attributes: Attributes{
										contents: [
											Attribute{
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
		},
		PMLTestCase{
			name: 'Third Example'
			desc: 'Paragraph with quoted attribute.'
			input: '[p (html_style = "color:red; border:1px dashed blue")
    It is important to note that ...
]'
			expected: PMLDoc{
				root: Node{
					name: 'p'
					attributes: Attributes{
						contents: [
							Attribute{
								name: 'html_style'
								value: 'color:red; border:1px dashed blue'
							},
						]
					}
					children: [
						'It is important to note that ...',
					]
				}
			}
		},
	]
}
