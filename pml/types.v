module pml

pub type Child = Comment | Node | string

pub type CommentChild = Comment | string

pub struct Comment {
	content []CommentChild
}

pub struct Node {
	name       string            @[required]
	attributes map[string]string
	children   []Child
}

pub struct PMLDoc {
	root Node
}
