module main

import pdml

fn test_get_children_by_name_flat() {
	node := pdml.Node{
		name: 'root'
		children: [
			pdml.Node{
				name: 'first_kind'
			},
			pdml.Node{
				name: 'second_kind'
			},
			pdml.Node{
				name: 'first_kind'
			},
			pdml.Node{
				name: 'third_kind'
			},
			pdml.Node{
				name: 'second_kind'
			},
			pdml.Node{
				name: 'second_kind'
			},
			pdml.Node{
				name: 'third_kind'
			},
		]
	}
	first_kind := node.get_children_by_name('first_kind')
	second_kind := node.get_children_by_name('second_kind')
	third_kind := node.get_children_by_name('third_kind')

	assert first_kind.len == 2
	assert second_kind.len == 3
	assert third_kind.len == 2
}

fn test_get_children_by_name_nested() {
	node := pdml.Node{
		name: 'root'
		children: [
			pdml.Node{
				name: 'first_kind'
				children: [
					pdml.Node{
						name: 'second_kind'
					},
					pdml.Node{
						name: 'first_kind'
					},
					pdml.Node{
						name: 'third_kind'
					},
				]
			},
			pdml.Node{
				name: 'second_kind'
				children: [
					pdml.Node{
						name: 'second_kind'
					},
					pdml.Node{
						name: 'third_kind'
					},
				]
			},
			pdml.Node{
				name: 'first_kind'
				children: [
					pdml.Node{
						name: 'second_kind'
					},
					pdml.Node{
						name: 'first_kind'
					},
					pdml.Node{
						name: 'third_kind'
					},
				]
			},
			pdml.Node{
				name: 'third_kind'
				children: [
					pdml.Node{
						name: 'second_kind'
					},
					pdml.Node{
						name: 'first_kind'
					},
					pdml.Node{
						name: 'third_kind'
					},
				]
			},
			pdml.Node{
				name: 'second_kind'
				children: [
					pdml.Node{
						name: 'second_kind'
					},
					pdml.Node{
						name: 'third_kind'
					},
				]
			},
			pdml.Node{
				name: 'second_kind'
				children: [
					pdml.Node{
						name: 'second_kind'
					},
					pdml.Node{
						name: 'third_kind'
					},
				]
			},
			pdml.Node{
				name: 'third_kind'
				children: [
					pdml.Node{
						name: 'second_kind'
					},
					pdml.Node{
						name: 'first_kind'
					},
					pdml.Node{
						name: 'third_kind'
					},
				]
			},
		]
	}
	first_kind := node.get_children_by_name('first_kind')
	second_kind := node.get_children_by_name('second_kind')
	third_kind := node.get_children_by_name('third_kind')

	assert first_kind.len == 6
	assert second_kind.len == 10
	assert third_kind.len == 9
}

fn test_get_children_by_attribute_flat() {
	node := pdml.Node{
		name: 'root'
		children: [
			pdml.Node{
				name: 'first_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val1'
						},
					]
				}
			},
			pdml.Node{
				name: 'second_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val1'
						},
					]
				}
			},
			pdml.Node{
				name: 'first_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val2'
						},
					]
				}
			},
			pdml.Node{
				name: 'third_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val1'
						},
					]
				}
			},
			pdml.Node{
				name: 'second_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val2'
						},
					]
				}
			},
			pdml.Node{
				name: 'second_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val1'
						},
					]
				}
			},
			pdml.Node{
				name: 'third_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val2'
						},
					]
				}
			},
		]
	}
	target_val1 := node.get_children_by_attribute('target', 'val1')
	target_val2 := node.get_children_by_attribute('target', 'val2')

	assert target_val1.len == 4
	assert target_val2.len == 3
}

fn test_get_children_by_attribute_nested() {
	node := pdml.Node{
		name: 'root'
		children: [
			pdml.Node{
				name: 'first_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val1'
						},
					]
				}
				children: [
					pdml.Node{
						name: 'second_kind'
						attributes: pdml.Attributes{
							children: [
								pdml.Attribute{
									name: 'target'
									value: 'val1'
								},
							]
						}
					},
					pdml.Node{
						name: 'first_kind'
						attributes: pdml.Attributes{
							children: [
								pdml.Attribute{
									name: 'target'
									value: 'val2'
								},
							]
						}
					},
					pdml.Node{
						name: 'third_kind'
						attributes: pdml.Attributes{
							children: [
								pdml.Attribute{
									name: 'target'
									value: 'val1'
								},
							]
						}
					},
				]
			},
			pdml.Node{
				name: 'second_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val1'
						},
					]
				}
				children: [
					pdml.Node{
						name: 'second_kind'
						attributes: pdml.Attributes{
							children: [
								pdml.Attribute{
									name: 'target'
									value: 'val2'
								},
							]
						}
					},
					pdml.Node{
						name: 'third_kind'
						attributes: pdml.Attributes{
							children: [
								pdml.Attribute{
									name: 'target'
									value: 'val1'
								},
							]
						}
					},
				]
			},
			pdml.Node{
				name: 'first_kind'
				attributes: pdml.Attributes{
					children: [
						pdml.Attribute{
							name: 'target'
							value: 'val2'
						},
					]
				}
				children: [
					pdml.Node{
						name: 'second_kind'
						attributes: pdml.Attributes{
							children: [
								pdml.Attribute{
									name: 'target'
									value: 'val1'
								},
							]
						}
					},
				]
			},
		]
	}

	target_val1 := node.get_children_by_attribute('target', 'val1')
	target_val2 := node.get_children_by_attribute('target', 'val2')

	assert target_val1.len == 6
	assert target_val2.len == 3
}
