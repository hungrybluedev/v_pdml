module cases

import spec { PMLTestCase, PMLTestSuite }
import pml

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
			expected: pml.PMLDoc{
				root: pml.Node{
					name: 'doc'
					children: [
						pml.Node{
							name: 'title'
							children: [
								'First test',
							]
						},
						'This is a',
						pml.Node{
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
			expected: pml.PMLDoc{
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
		},
		PMLTestCase{
			name: 'Third Example'
			desc: 'Paragraph with quoted attribute.'
			input: '[p (html_style = "color:red; border:1px dashed blue")
		    It is important to note that ...
		]'
			expected: pml.PMLDoc{
				root: pml.Node{
					name: 'p'
					attributes: pml.Attributes{
						children: [
							pml.Attribute{
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
		PMLTestCase{
			name: 'Fourth Example'
			desc: 'Text and multiple comments, some nested.'
			input: '[sample
This is [- good -] awesome.
[- TODO: explain why -]

Text
[-
    This [i bad] text not show.
    [- a
        nested
        comment -]
-]

More text]'
			expected: pml.PMLDoc{
				root: pml.Node{
					name: 'sample'
					children: [
						'This is',
						pml.Comment{
							children: [
								'good',
							]
						},
						'awesome.',
						pml.Comment{
							children: [
								'TODO: explain why',
							]
						},
						'Text',
						pml.Comment{
							children: [
								'This [i bad] text not show.',
								pml.Comment{
									children: [
										'a',
										'nested',
										'comment',
									]
								},
							]
						},
						'More text',
					]
				}
			}
		},
		PMLTestCase{
			name: 'Fifth Example'
			desc: 'Empty attribute list.'
			input: '[div () text]'
			expected: pml.PMLDoc{
				root: pml.Node{
					name: 'div'
					children: [
						'text',
					]
				}
			}
		},
		PMLTestCase{
			name: 'Sixth Example'
			desc: 'Node with children having text starting with parentheses.'
			input: '[i() (organic = healthy)]'
			expected: pml.PMLDoc{
				root: pml.Node{
					name: 'i'
					children: [
						'(organic = healthy)',
					]
				}
			}
		},
		PMLTestCase{
			name: 'Seventh Example'
			desc: 'Node with no children and no parentheses around attributes.'
			input: '[image source="images/juicy apple.png" width=400]'
			expected: pml.PMLDoc{
				root: pml.Node{
					name: 'image'
					attributes: pml.Attributes{
						children: [
							pml.Attribute{
								name: 'source'
								value: 'images/juicy apple.png'
							},
							pml.Attribute{
								name: 'width'
								value: '400'
							},
						]
					}
				}
			}
		},
	]
}
