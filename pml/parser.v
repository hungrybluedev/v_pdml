module pml

import io
import os

pub fn PMLDoc.parse_string(content string) !PMLDoc {
	mut reader := FullBufferReader{
		contents: content.bytes()
	}
	return PMLDoc.parse_reader(mut reader)
}

pub fn PMLDoc.parse_file(path string) !PMLDoc {
	mut file_reader := os.open(path) or { return error('Failed to open "${path}" for reading.') }
	return PMLDoc.parse_reader(mut file_reader)
}

pub fn PMLDoc.parse_reader(mut reader io.Reader) !PMLDoc {
	return error('Not implemented.')
}
