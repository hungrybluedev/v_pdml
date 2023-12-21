module cases

import spec { PMLTestCase, PMLTestSuite }
import pml { Node, PMLDoc }

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
	]
}
