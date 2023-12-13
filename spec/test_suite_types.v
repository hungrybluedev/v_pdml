module spec

import pml { PMLDoc }

pub struct PMLTestSuite {
pub:
	name  string
	desc  string
	cases []PMLTestCase
}

pub struct PMLTestCase {
pub:
	name     string
	desc     string
	input    string
	expected PMLDoc
}
