import pml

fn main() {
	sample := '[doc
	[title Hello, World!]
	[author Subhomoy Haldar]
	[body
		[paragraph A sample paragraph for demonstration.]
		[paragraph Another paragraph.]
	]
]'
	doc := pml.PMLDoc.parse_string(sample)!
	println(doc)
}
