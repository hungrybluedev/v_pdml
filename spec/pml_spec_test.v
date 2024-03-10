module main

import pdml
import spec.cases

const test_suites = [
	cases.user_manual,
]

fn test_all_cases() ! {
	for suite in test_suites {
		for case in suite.cases {
			parsed_doc := pdml.Document.parse_string(case.input) or {
				assert false, 'Failed to parse document for ${case.name}: ${err}'
				// Dummy return value. The test will fail and won't use this.
				pdml.Document{
					root: pdml.Node{
						name: 'ignore'
					}
				}
			}
			assert parsed_doc == case.expected, 'Parsed document does not match for ${case.name}'
		}
	}
}
