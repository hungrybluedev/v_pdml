# v_pdml

## About

**`v_pdml`** is a custom implementation of the [PDML (Practical Data and Markup Language)][1]
documentation standard in the V programming language. Think of it as a LISP-like alternative
to Markdown which is less verbose than XML and more readable than JSON.

## Features

- Support for parsing and generating PDML files.
- Easy-to-use API for working with PDML data.
- Flyweight recursive-descent parser implementation using `io.Reader`.

Most features of the PDML standard are supported. If there are any missing features that
you would like to see, please open an issue and if possible, a pull request.

## Getting Started

### Prequisites

Ensure that you have the latest version of the V programming language installed on your system.
Refer to the installation instructions [here][2].

### Installation

To install the `v_pdml` module, run the following command:

```bash
v install --git https://github.com/hungrybluedev/v_pdml
```

### Usage

Import `pdml` if you installed from GitHub.

```v
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
```

Check the **examples** directory for more examples.

## Acknowledgements

I would like to thank Christian Neumanns (@pdml-lang) for creating the PDML and PML standard
and for his help in the development of this module.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact and Support

If you like my work, and would want to discuss how I can help you, you can book a call
with me.

[![Book a call](https://img.shields.io/badge/Book%20a%20call-Consulting-blue?style=for-the-badge)](https://tidycal.com/hungrybluedev)

[1]: https://pml-lang.dev/index.html
[2]: https://github.com/vlang/v/?tab=readme-ov-file#installing-v-from-source
