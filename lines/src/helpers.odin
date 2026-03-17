package lines_core

import "../../pos"
import tok "../../tokenizer"

Marker_Lines_Options :: struct {
	before: int,
	after:  int,
}


default_marker_lines_options: Marker_Lines_Options : {before = 1, after = 1}

// by given a span the procedure returns lines where the span is.
// optionally if given options it can return some lines before or after the span.
get_marker_lines :: proc(
	source: string,
	span: pos.Span,
	options: Marker_Lines_Options = default_marker_lines_options,
	allocator := context.allocator,
) -> [dynamic]Line {
	result := make([dynamic]Line, allocator)

	t := create_tokenizer(source)

	for !tok.is_eof(t) {
		if t.index >= span.x {
			if t.index <= span.y {
				break
			} else {
				start := t.index
				line, err := advance(&t)
				if err != .None {
					break
				}
				append(&result, line)
			}
		} else {
			advance(&t)
		}
	}


	return result
}
