package ast_core

Node_Kind :: distinct u32

CUSTOM_OFFSET :: 100

Pos :: struct {
	start: u32,
	end:   u32,
}

Node :: struct {
	using pos: Pos,
	kind:      Node_Kind,
}
