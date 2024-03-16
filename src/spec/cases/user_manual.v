module cases

import spec { PMLTestCase, PMLTestSuite }
import pdml

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
			expected: pdml.Document{
				root: pdml.Node{
					name: 'doc'
					children: [
						pdml.Node{
							name: 'title'
							children: [
								'First test',
							]
						},
						'This is a',
						pdml.Node{
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
			expected: pdml.Document{
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
								'Text of paragraph 1.\n\t\tText of paragraph 2.\n\t\tLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
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
		},
		PMLTestCase{
			name: 'Third Example'
			desc: 'Paragraph with quoted attribute.'
			input: '[p (html_style = "color:red; border:1px dashed blue")
				    It is important to note that ...
				]'
			expected: pdml.Document{
				root: pdml.Node{
					name: 'p'
					attributes: pdml.Attributes{
						children: [
							pdml.Attribute{
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
			expected: pdml.Document{
				root: pdml.Node{
					name: 'sample'
					children: [
						'This is',
						pdml.Comment{
							children: [
								'good',
							]
						},
						'awesome.',
						pdml.Comment{
							children: [
								'TODO: explain why',
							]
						},
						'Text',
						pdml.Comment{
							children: [
								'This [i bad] text not show.',
								pdml.Comment{
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
			expected: pdml.Document{
				root: pdml.Node{
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
			expected: pdml.Document{
				root: pdml.Node{
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
			expected: pdml.Document{
				root: pdml.Node{
					name: 'image'
					attributes: pdml.Attributes{
						children: [
							pdml.Attribute{
								name: 'source'
								value: 'images/juicy apple.png'
							},
							pdml.Attribute{
								name: 'width'
								value: '400'
							},
						]
					}
				}
			}
		},
		PMLTestCase{
			name: 'Eighth Example'
			desc: 'Simple monospace node with text.'
			input: '
[sample
[header A Pascal Triangle]
[monospace
      1
    1   1
  1   2   1
1   3   3   1
]
]'
			expected: pdml.Document{
				root: pdml.Node{
					name: 'sample'
					children: [
						pdml.Node{
							name: 'header'
							children: [
								'A Pascal Triangle',
							]
						},
						pdml.Node{
							name: 'monospace'
							children: [
								'      1
    1   1
  1   2   1
1   3   3   1
',
							]
						},
					]
				}
			}
		},
		PMLTestCase{
			name: 'Ninth Example'
			desc: 'Node with escaped characters.'
			input: r'[foo Characters \[, \], and \\ must be escaped.]'
			expected: pdml.Document{
				root: pdml.Node{
					name: 'foo'
					children: [
						'Characters [, ], and \\ must be escaped.',
					]
				}
			}
		},
	]
}
