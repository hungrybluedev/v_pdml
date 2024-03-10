import pdml
import os

fn main() {
	path := os.join_path(os.dir(@FILE), 'sample.pml')
	doc := pdml.Document.parse_file(path)!
	println(doc)
}
