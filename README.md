# v_pml

## About

**`v_pml`** is an implementation of the [PML (Practical Markup Language)][1] documentation standard in the V programming language. Think of it as a LISP-like alternative to Markdown which is less verbose than XML and more readable than JSON.

## Features

- Support for parsing and generating PML files.
- Easy-to-use API for working with PML data.
- Flyweight recursive-descent parser implementation using `io.Reader`.

## Getting Started

### Prequisites

Ensure that you have the latest version of the V programming language installed on your system. Refer to the installation instructions [here][2].

### Installation

To install the `v_pml` module, run the following command:

```bash
v install --git https://github.com/hungrybluedev/v_pml
```

### Usage

Import `pml` if you installed from GitHub.

```v
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
```

Check the **examples** directory for more examples.


## Acknowledgements

I would like to thank Christian Neumanns (@pml-lang) for creating the PML standard and for his help in the development of this module.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact and Support

If you like my work, please consider sponsoring me on [GitHub][3].

[1]: https://pml-lang.dev/index.html
[2]: https://github.com/vlang/v/?tab=readme-ov-file#installing-v-from-source
[3]: https://github.com/sponsors/hungrybluedev
