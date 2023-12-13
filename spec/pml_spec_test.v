module main

import pml
import spec.cases

const test_suites = [
	cases.user_manual,
]

fn test_all_cases() ! {
	for suite in test_suites {
		for case in suite.cases {
			parsed_doc := pml.PMLDoc.parse_string(case.input)!
			assert parsed_doc == case.expected, 'Parsed document does not match for ${case.name}'
		}
	}
}
