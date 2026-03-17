package lines_core

import "../../pos"
import tok "../../tokenizer"

Span_Lines_Options :: struct {
	before: int,
	after:  int,
}

default_span_lines_options: Span_Lines_Options : {before = 1, after = 1}

// by given a span the procedure returns lines where the span is.
// optionally if given options it can return some lines before or after the span.
get_span_lines :: proc(
	source: string,
	span: pos.Span,
	options: Span_Lines_Options = default_span_lines_options,
	allocator := context.allocator,
) -> [dynamic]Line {
	result := make([dynamic]Line, allocator)

	// 1. first we go the start or end of the span
	t_start := create_tokenizer(source)
	for {
		line, err := advance(&t_start)
		if err != .None {
			break
		}
		if span.x >= line.span.x && span.x <= line.span.y {
			rollback(&t_start)
			break
		}
	}

	t_end := t_start
	for {
		line, err := advance(&t_end)
		if err != .None {
			break
		}
		if span.y >= line.span.x && span.y <= line.span.y {
			rollback(&t_end)
			break
		}
	}

	// 2. then we rollback/advance to the lines before or after the span
	for i in 0 ..< options.before {
		_, err := rollback(&t_start)
		if err != .None {
			break
		}
	}

	for i in 0 ..< (1 + options.after) {
		_, err := advance(&t_end)
		if err != .None {
			break
		}
	}

	// 3. then we collect the lines between the start and end tokens
	for {
		if t_start.index >= t_end.index {
			break
		}

		line, err := advance(&t_start)
		if err == .None {
			append(&result, line)
		} else {
			break
		}
	}

	return result
}


move_to_start_of_line :: proc(t: ^Tokenizer) {
	if !is_start_of_line(t) {
		for {
			if t.index == 0 || tok.get_prev(t) == '\n' {
				break
			}
			tok.rollback(t)
		}
	}
}
