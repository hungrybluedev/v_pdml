import pdml

fn main() {
	sample := '[doc
	[title Hello, World!]
	[author Subhomoy Haldar]
	[body
		[paragraph A sample paragraph for demonstration.]
		[paragraph Another paragraph.]
	]
]'
	doc := pdml.Document.parse_string(sample)!
	println(doc)
}
