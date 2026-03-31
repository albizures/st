package st_src

import "core:mem"
import "core:slice"

Visitor_Test :: union {
	Kind_Test,
	Node_Test,
}

Visitor_Kind :: enum {
	Pre_Order,
}

Visitor_State :: struct {
	parent: Parent,
	index:  int,
}

Visitor :: struct {
	allocator: mem.Allocator,
	tree:      Tree,
	path:      [dynamic]Visitor_State,
	level:     int,
	kind:      Visitor_Kind,
	test:      Visitor_Test,
	reverse:   bool,
}

create_visitor :: proc(tree: Tree, kind: Visitor_Kind, reverse := false, allocator := context.allocator) -> Visitor {
	v := Visitor {
		allocator = allocator,
		tree      = tree,
		path      = make([dynamic]Visitor_State, allocator),
		level     = 0,
		kind      = kind,
		reverse   = reverse,
	}
	return v
}

destroy_visitor :: proc(v: Visitor) {
	delete(v.path)
}


next :: proc(v: ^Visitor) -> (node: Node, ok: bool) {
	switch v.kind {
	case .Pre_Order:
		return next_pre_order(v)
	}

	ok = false
	return
}

next_pre_order :: proc(v: ^Visitor) -> (node: Node, ok: bool) {
	if len(v.path) == 0 {
		if v.level == 0 {
			append(
				&v.path,
				Visitor_State {
					parent = v.tree.root,
					index = v.reverse ? len(v.tree.root.children) - 1 : 0,
				},
			)
			ok = true
			node = to_node(v.tree.root)
			return
		}

		ok = false
		return
	}

	state := &v.path[len(v.path) - 1]

	if state.index >= len(state.parent.children) || (v.reverse && state.index < 0) {
		// we need to backtrack
		pop(&v.path)
		v.level -= 1
		if len(v.path) == 0 {
			ok = false
			return
		}

		return next_pre_order(v)
	}

	// check if the current node has children
	current := state.parent.children[state.index]
	state.index += v.reverse ? -1 : 1

	switch cur in current {
	case Parent:
		append(&v.path, Visitor_State{parent = cur, index = v.reverse ? len(cur.children) - 1 : 0})
		v.level += 1
		ok = true
		node = to_node(current)
		return node, ok
	case Node:
		ok = true
		node = to_node(current)
		return node, ok
	}

	return
}

to_node :: proc(node: Child) -> Node {
	switch n in node {
	case Parent:
		return n
	case Node:
		return n
	}

	panic("Invalid state")
}
