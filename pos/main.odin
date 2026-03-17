package pos

import "src"


// structs

Span :: src.Span
Pos :: src.Pos
Loc :: src.Loc

// procs

get_content :: proc {
	src.get_content_from_loc,
	src.get_content_from_span,
}
