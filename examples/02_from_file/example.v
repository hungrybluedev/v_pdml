import pml
import os

fn main() {
	path := os.join_path(os.dir(@FILE), 'sample.pml')
	doc := pml.PMLDoc.parse_file(path)!
	println(doc)
}
