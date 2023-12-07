module spec

import pml { PMLDoc }

pub struct PMLTestCase {
pub:
	name     string
	desc     string
	input    string
	expected PMLDoc
}
