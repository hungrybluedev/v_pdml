module pml

pub type Child = Comment | Node | string

pub type CommentChild = Comment | string

pub struct Comment {
	content []CommentChild
}

pub type AttributeChild = Attribute | Comment

pub struct Attribute {
	name  string
	value string
}

pub struct Attributes {
	contents []AttributeChild
}

pub struct Node {
	name       string     @[required]
	attributes Attributes
	children   []Child
}

pub struct PMLDoc {
	root Node
}
