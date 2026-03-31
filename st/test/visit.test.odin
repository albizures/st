package st_test

import "core:testing"
import "core:mem"
import st "../src"

@(test)
test_visitor_pre_order :: proc(t: ^testing.T) {
	root_node := st.Node{kind = 1}
	child_a := st.Node{kind = 2}
	child_b_node := st.Node{kind = 3}
	child_c := st.Node{kind = 4}

	child_b := st.Parent{
		node = child_b_node,
		children = make([dynamic]st.Child, context.allocator),
	}
	append(&child_b.children, st.Child(child_c))

	root := st.Parent{
		node = root_node,
		children = make([dynamic]st.Child, context.allocator),
	}
	append(&root.children, st.Child(child_a))
	append(&root.children, st.Child(child_b))

	tree := st.Tree{
		allocator = context.allocator,
		root = root,
	}

	defer {
		delete(root.children)
		delete(child_b.children)
	}

	visitor := st.create_visitor(tree, .Pre_Order)
	defer st.destroy_visitor(visitor)

	// Pre-order traversal visits parent, then children.
	// The root itself IS visited, so the first node should be 1.

	n: st.Node
	ok: bool

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 1) // root

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 2) // child_a

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 3) // child_b's node

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 4) // child_c

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, false)

	visitor.reverse = true
	// reset path
	clear(&visitor.path)
	visitor.level = 0
	
	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 1) // root
	
	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 3) // child_b
	
	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 4) // child_c
	
	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 2) // child_a
	
	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, false)
}

@(test)
test_create_reverse_visitor :: proc(t: ^testing.T) {
	root_node := st.Node{kind = 1}
	child_a := st.Node{kind = 2}
	child_b_node := st.Node{kind = 3}
	child_c := st.Node{kind = 4}

	child_b := st.Parent{
		node = child_b_node,
		children = make([dynamic]st.Child, context.allocator),
	}
	append(&child_b.children, st.Child(child_c))

	root := st.Parent{
		node = root_node,
		children = make([dynamic]st.Child, context.allocator),
	}
	append(&root.children, st.Child(child_a))
	append(&root.children, st.Child(child_b))

	tree := st.Tree{
		allocator = context.allocator,
		root = root,
	}

	defer {
		delete(root.children)
		delete(child_b.children)
	}

	visitor := st.create_visitor(tree, .Pre_Order, reverse = true)
	defer st.destroy_visitor(visitor)

	n: st.Node
	ok: bool

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 1) // root

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 3) // child_b

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 4) // child_c

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, true)
	testing.expect_value(t, n.kind, 2) // child_a

	n, ok = st.next(&visitor)
	testing.expect_value(t, ok, false)
}
